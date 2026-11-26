"""
Datenzugriff für die Tabellen 'bestellung' und 'bestellposition'.

Die Schreibmethoden committen nicht selbst: eine Bestellung besteht aus mehreren
Schritten (Kopf, Positionen, Lagerbuchung), die der Bestellservice in einer
gemeinsamen Transaktion ausführt.
"""

import sqlite3
from uuid import UUID

from app.models import Bestellposition, Bestellung

_AUSWAHL = """
    SELECT b.*, u.vorname || ' ' || u.nachname AS kunde_name, u.email AS kunde_email
    FROM bestellung b
    JOIN benutzer u ON u.benutzer_id = b.benutzer_id
"""


class BestellungDAO:
    def __init__(self, db_verbindung: sqlite3.Connection):
        self.db = db_verbindung

    # Lesen
    def _laden(
        self,
        bedingung: str = "",
        parameter: tuple = (),
        limit: int | None = None,
        offset: int = 0,
    ) -> list[Bestellung]:
        """Lädt Bestellungen samt ihrer Positionen - neueste zuerst."""
        seite = ""
        if limit is not None:
            seite = "LIMIT ? OFFSET ?"
            parameter = (*parameter, limit, offset)
        zeilen = self.db.execute(
            f"{_AUSWAHL} {bedingung} ORDER BY b.laufende_nr DESC {seite}", parameter
        ).fetchall()
        bestellungen = {zeile["bestellung_id"]: Bestellung(**zeile) for zeile in zeilen}
        if not bestellungen:
            return []

        platzhalter = ", ".join("?" * len(bestellungen))
        positionen = self.db.execute(
            f"""
            SELECT bp.*, p.bezeichnung, p.slug, p.bildpfad
            FROM bestellposition bp
            JOIN produkt p ON p.produkt_id = bp.produkt_id
            WHERE bp.bestellung_id IN ({platzhalter})
            ORDER BY bp.rowid
            """,
            tuple(bestellungen),
        ).fetchall()
        for zeile in positionen:
            bestellungen[zeile["bestellung_id"]].positionen.append(
                Bestellposition(**zeile)
            )
        return list(bestellungen.values())

    def get_alle(
        self, status: str | None = None, limit: int = 200, offset: int = 0
    ) -> list[Bestellung]:
        """Gibt Bestellungen seitenweise zurück - optional nach Status gefiltert."""
        if status:
            return self._laden("WHERE b.status = ?", (status,), limit, offset)
        return self._laden(limit=limit, offset=offset)

    def get_nach_id(self, bestellung_id: UUID) -> Bestellung | None:
        treffer = self._laden("WHERE b.bestellung_id = ?", (bestellung_id,))
        return treffer[0] if treffer else None

    def get_nach_benutzer(self, benutzer_id: UUID) -> list[Bestellung]:
        """Gibt die Bestellhistorie eines Kunden zurück."""
        return self._laden("WHERE b.benutzer_id = ?", (benutzer_id,))

    # Schreiben (ohne Commit - siehe Modulbeschreibung)
    def erstellen(self, bestellung: Bestellung) -> None:
        """Legt Bestellkopf und Positionen an. Die laufende Nummer vergibt die Datenbank."""
        self.db.execute(
            """
            INSERT INTO bestellung (
                bestellung_id, laufende_nr, bestelldatum, status, zahlungsart, anmerkung, benutzer_id
            ) VALUES (
                ?, (SELECT COALESCE(MAX(laufende_nr), 0) + 1 FROM bestellung), ?, ?, ?, ?, ?
            )
            """,
            (
                bestellung.bestellung_id,
                bestellung.bestelldatum,
                bestellung.status,
                bestellung.zahlungsart,
                bestellung.anmerkung,
                bestellung.benutzer_id,
            ),
        )
        self.db.executemany(
            """
            INSERT INTO bestellposition (
                bestellposition_id, menge, einzelpreis_gebucht, rabatt_angewendet,
                steuersatz_gebucht, bestellung_id, produkt_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    p.bestellposition_id,
                    p.menge,
                    p.einzelpreis_gebucht,
                    p.rabatt_angewendet,
                    p.steuersatz_gebucht,
                    p.bestellung_id,
                    p.produkt_id,
                )
                for p in bestellung.positionen
            ],
        )

    def status_aktualisieren(
        self, bestellung_id: UUID, neuer_status: str, bisheriger_status: str
    ) -> bool:
        """Setzt den Status nur, wenn er noch dem erwarteten entspricht.

        Gibt False zurück, wenn eine andere Anfrage den Status inzwischen geändert hat.
        """
        cursor = self.db.execute(
            "UPDATE bestellung SET status = ? WHERE bestellung_id = ? AND status = ?",
            (neuer_status, bestellung_id, bisheriger_status),
        )
        return cursor.rowcount > 0

    def anmerkungen_entfernen(self, benutzer_id: UUID) -> None:
        """Löscht die Freitext-Anmerkungen eines Kunden (können Personendaten enthalten)."""
        self.db.execute(
            "UPDATE bestellung SET anmerkung = NULL WHERE benutzer_id = ?", (benutzer_id,)
        )

    # Auswertung
    def statistik(self) -> dict:
        """Kennzahlen für das Admin-Dashboard."""
        je_status = {
            zeile["status"]: zeile["anzahl"]
            for zeile in self.db.execute(
                "SELECT status, COUNT(*) AS anzahl FROM bestellung GROUP BY status"
            )
        }
        umsatz = self.db.execute(
            """
            SELECT COALESCE(SUM((bp.einzelpreis_gebucht - bp.rabatt_angewendet) * bp.menge), 0)
            FROM bestellposition bp
            JOIN bestellung b ON b.bestellung_id = bp.bestellung_id
            WHERE b.status IN ('Offen', 'In Bearbeitung', 'Abgeschlossen')
            """
        ).fetchone()[0]
        produkte = self.db.execute(
            """
            SELECT
                COALESCE(SUM(produkt_aktiv = 1), 0) AS aktiv,
                COALESCE(SUM(produkt_aktiv = 1 AND lagerbestand = 0), 0) AS ausverkauft
            FROM produkt
            """
        ).fetchone()
        kunden = self.db.execute(
            "SELECT COUNT(*) FROM benutzer WHERE rolle = 'Kunde'"
        ).fetchone()[0]
        return {
            "umsatz": round(float(umsatz), 2),
            "bestellungen_gesamt": sum(je_status.values()),
            "bestellungen_je_status": je_status,
            "produkte_aktiv": produkte["aktiv"],
            "produkte_ausverkauft": produkte["ausverkauft"],
            "kunden": kunden,
        }
