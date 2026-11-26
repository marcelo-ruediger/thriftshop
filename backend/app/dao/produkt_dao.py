"""
Datenzugriff für die Tabelle 'produkt' - SQL-Abfragen und -Mutationen.
"""

import sqlite3
from uuid import UUID

from app.models import Produkt

# Rabatt und Steuersatz der Kategorie werden für die Preisberechnung mitgeladen
_AUSWAHL = """
    SELECT p.*, k.kategorie_rabatt, k.steuersatz
    FROM produkt p
    JOIN kategorie k ON k.kategorie_id = p.kategorie_id
"""


class ProduktDAO:
    def __init__(self, db_verbindung: sqlite3.Connection):
        self.db = db_verbindung

    # Lesen
    def get_alle(self) -> list[Produkt]:
        """Gibt alle Produkte zurück (auch inaktive) - für die Produktverwaltung."""
        zeilen = self.db.execute(f"{_AUSWAHL} ORDER BY p.laufende_nr DESC").fetchall()
        return [Produkt(**zeile) for zeile in zeilen]

    def get_alle_aktiven(self) -> list[Produkt]:
        """Gibt nur aktive Produkte zurück - für den Onlineshop."""
        zeilen = self.db.execute(
            f"{_AUSWAHL} WHERE p.produkt_aktiv = 1 ORDER BY p.laufende_nr DESC"
        ).fetchall()
        return [Produkt(**zeile) for zeile in zeilen]

    def get_nach_id(self, produkt_id: UUID) -> Produkt | None:
        zeile = self.db.execute(
            f"{_AUSWAHL} WHERE p.produkt_id = ?", (produkt_id,)
        ).fetchone()
        return Produkt(**zeile) if zeile else None

    def get_nach_slug(self, slug: str) -> Produkt | None:
        """Sucht ein Produkt anhand des Slugs - für lesbare URLs."""
        zeile = self.db.execute(f"{_AUSWAHL} WHERE p.slug = ?", (slug,)).fetchone()
        return Produkt(**zeile) if zeile else None

    def slug_existiert(self, slug: str, ausser_produkt_id: UUID | None = None) -> bool:
        zeile = self.db.execute(
            "SELECT 1 FROM produkt WHERE slug = ? AND produkt_id IS NOT ?",
            (slug, ausser_produkt_id),
        ).fetchone()
        return zeile is not None

    # Schreiben
    def erstellen(self, produkt: Produkt) -> None:
        """Fügt ein neues Produkt ein. Die laufende Nummer vergibt die Datenbank."""
        self.db.execute(
            """
            INSERT INTO produkt (
                produkt_id, laufende_nr, erstellungsdatum, bezeichnung, slug, produkt_info,
                preis, produkt_rabatt, lagerbestand, zustand_id, kategorie_id, bildpfad, produkt_aktiv
            ) VALUES (
                ?, (SELECT COALESCE(MAX(laufende_nr), 0) + 1 FROM produkt),
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            )
            """,
            (
                produkt.produkt_id,
                produkt.erstellungsdatum,
                produkt.bezeichnung,
                produkt.slug,
                produkt.produkt_info,
                produkt.preis,
                produkt.produkt_rabatt,
                produkt.lagerbestand,
                produkt.zustand_id,
                produkt.kategorie_id,
                produkt.bildpfad,
                produkt.produkt_aktiv,
            ),
        )

    def aktualisieren(self, produkt: Produkt) -> None:
        self.db.execute(
            """
            UPDATE produkt SET
                bezeichnung = ?, slug = ?, produkt_info = ?, preis = ?, produkt_rabatt = ?,
                lagerbestand = ?, zustand_id = ?, kategorie_id = ?, bildpfad = ?, produkt_aktiv = ?
            WHERE produkt_id = ?
            """,
            (
                produkt.bezeichnung,
                produkt.slug,
                produkt.produkt_info,
                produkt.preis,
                produkt.produkt_rabatt,
                produkt.lagerbestand,
                produkt.zustand_id,
                produkt.kategorie_id,
                produkt.bildpfad,
                produkt.produkt_aktiv,
                produkt.produkt_id,
            ),
        )

    def deaktivieren(self, produkt_id: UUID) -> bool:
        """Deaktiviert ein Produkt (Soft-Delete) - bestehende Bestellungen bleiben intakt."""
        cursor = self.db.execute(
            "UPDATE produkt SET produkt_aktiv = 0 WHERE produkt_id = ?", (produkt_id,)
        )
        return cursor.rowcount > 0

    def bestand_reduzieren(self, produkt_id: UUID, menge: int) -> bool:
        """Bucht Ware aus. Gibt False zurück, wenn der Bestand nicht ausreicht."""
        cursor = self.db.execute(
            """
            UPDATE produkt SET lagerbestand = lagerbestand - ?
            WHERE produkt_id = ? AND lagerbestand >= ?
            """,
            (menge, produkt_id, menge),
        )
        return cursor.rowcount > 0

    def bestand_erhoehen(self, produkt_id: UUID, menge: int) -> None:
        """Bucht Ware zurück - z.B. nach einer Stornierung."""
        self.db.execute(
            "UPDATE produkt SET lagerbestand = lagerbestand + ? WHERE produkt_id = ?",
            (menge, produkt_id),
        )
