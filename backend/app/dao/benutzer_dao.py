"""
Datenzugriff für die Tabelle 'benutzer' - SQL-Abfragen und -Mutationen.
"""

import sqlite3
from uuid import UUID

from app.core.datenbank import jetzt
from app.models import Benutzer


class BenutzerDAO:
    def __init__(self, db_verbindung: sqlite3.Connection):
        """Initialisierung mit bestehender DB-Verbindung."""
        self.db = db_verbindung

    # Lesen
    def get_alle(self) -> list[Benutzer]:
        """Gibt alle Benutzer zurück (Admin-Sicht)."""
        zeilen = self.db.execute(
            "SELECT * FROM benutzer ORDER BY erstellt_am DESC, email ASC"
        ).fetchall()
        return [Benutzer(**zeile) for zeile in zeilen]

    def get_nach_id(self, benutzer_id: UUID) -> Benutzer | None:
        """Lädt einen Benutzer anhand der UUID."""
        zeile = self.db.execute(
            "SELECT * FROM benutzer WHERE benutzer_id = ?", (benutzer_id,)
        ).fetchone()
        return Benutzer(**zeile) if zeile else None

    def get_nach_email(self, email: str) -> Benutzer | None:
        """Lädt einen Benutzer anhand der E-Mail (für Login)."""
        zeile = self.db.execute(
            "SELECT * FROM benutzer WHERE email = ?", (email,)
        ).fetchone()
        return Benutzer(**zeile) if zeile else None

    def anzahl_bestellungen(self, benutzer_id: UUID) -> int:
        """Anzahl der Bestellungen eines Benutzers - entscheidet über Löschen oder Anonymisieren."""
        return self.db.execute(
            "SELECT COUNT(*) FROM bestellung WHERE benutzer_id = ?", (benutzer_id,)
        ).fetchone()[0]

    # Schreiben
    def erstellen(self, benutzer: Benutzer) -> None:
        """Legt einen neuen Benutzer an."""
        zeitpunkt = jetzt()
        benutzer.erstellt_am = benutzer.erstellt_am or zeitpunkt
        benutzer.letzte_aenderung = zeitpunkt
        self.db.execute(
            """
            INSERT INTO benutzer (
                benutzer_id, vorname, nachname, email, telefon,
                passwort_hash, rolle, erstellt_am, letzte_aenderung
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                benutzer.benutzer_id,
                benutzer.vorname,
                benutzer.nachname,
                benutzer.email,
                benutzer.telefon,
                benutzer.passwort_hash,
                benutzer.rolle,
                benutzer.erstellt_am,
                benutzer.letzte_aenderung,
            ),
        )
        self.db.commit()

    def aktualisieren_stammdaten(self, benutzer: Benutzer) -> None:
        """Aktualisiert Name, Kontaktdaten und Rolle."""
        benutzer.letzte_aenderung = jetzt()
        self.db.execute(
            """
            UPDATE benutzer SET
                vorname = ?, nachname = ?, email = ?, telefon = ?,
                rolle = ?, letzte_aenderung = ?
            WHERE benutzer_id = ?
            """,
            (
                benutzer.vorname,
                benutzer.nachname,
                benutzer.email,
                benutzer.telefon,
                benutzer.rolle,
                benutzer.letzte_aenderung,
                benutzer.benutzer_id,
            ),
        )
        self.db.commit()

    def passwort_setzen(self, benutzer_id: UUID, neuer_passwort_hash: str) -> None:
        """Setzt einen neuen Passwort-Hash."""
        self.db.execute(
            "UPDATE benutzer SET passwort_hash = ?, letzte_aenderung = ? WHERE benutzer_id = ?",
            (neuer_passwort_hash, jetzt(), benutzer_id),
        )
        self.db.commit()

    def letzter_login_setzen(self, benutzer_id: UUID) -> None:
        """Aktualisiert den Zeitpunkt des letzten Logins."""
        self.db.execute(
            "UPDATE benutzer SET letzter_login = ? WHERE benutzer_id = ?",
            (jetzt(), benutzer_id),
        )
        self.db.commit()

    def loeschen(self, benutzer_id: UUID) -> None:
        """Löscht einen Benutzer endgültig (nur möglich ohne Bestellungen)."""
        self.db.execute("DELETE FROM benutzer WHERE benutzer_id = ?", (benutzer_id,))
        self.db.commit()

    def anonymisieren(self, benutzer_id: UUID) -> None:
        """Entfernt alle personenbezogenen Daten, behält aber den Datensatz.

        Wird statt des Löschens verwendet, wenn Bestellungen existieren, die aus
        buchhalterischen Gründen erhalten bleiben müssen (DSGVO Art. 17 Abs. 3).
        """
        self.db.execute(
            """
            UPDATE benutzer SET
                vorname = 'Gelöschter', nachname = 'Benutzer',
                email = ?, telefon = NULL, passwort_hash = '', rolle = 'Kunde',
                letzte_aenderung = ?
            WHERE benutzer_id = ?
            """,
            (f"geloescht-{benutzer_id}@thriftshop.invalid", jetzt(), benutzer_id),
        )
        self.db.commit()
