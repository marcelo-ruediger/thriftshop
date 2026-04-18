"""
Datezugriff für die Tabelle 'bestellposition' - SQL-Abfragen und -Mutationen.
"""

import mysql.connector
from uuid import UUID
from models import Bestellposition


class BestellpositionDAO:
    def __init__(self, db_verbindung):
        """Initialisierung mit bestehender DB-Verbindung."""
        self.db = db_verbindung

    # Lesen ---
    def get_alle(self, limit: int = 50, offset: int = 0) -> list[Bestellposition]:
        """Lädt alle Bestellpositionen."""
        try:
            with self.db.cursor(
                dictionary=True
            ) as cursor:  # JOIN um nach der Bestelllaufnummer zu sortieren
                cursor.execute(
                    """
                    SELECT bp.*
                    FROM bestellposition bp
                    JOIN bestellung b ON bp.bestellung_id = b.bestellung_id
                    ORDER BY b.laufende_nr DESC, bp.bestellposition_id ASC
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset),
                )
                return [Bestellposition(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellpositionen: {err}"
            ) from err

    def get_nach_id(self, bestellposition_id: UUID) -> Bestellposition | None:
        """Lädt eine Bestellposition anhand der UUID."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM bestellposition WHERE bestellposition_id = %s",
                    (str(bestellposition_id),),
                )
                row = cursor.fetchone()
                return Bestellposition(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellposition: {err}"
            ) from err

    def get_nach_bestellung(self, bestellung_id: UUID) -> list[Bestellposition]:
        """Lädt alle Positionen zu einer Bestellung."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM bestellposition WHERE bestellung_id = %s",
                    (str(bestellung_id),),
                )
                return [Bestellposition(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellpositionen: {err}"
            ) from err

    def get_nach_produkt(self, produkt_id: UUID) -> list[Bestellposition]:
        """Lädt alle Positionen zu einem Produkt."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM bestellposition WHERE produkt_id = %s",
                    (str(produkt_id),),
                )
                return [Bestellposition(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellpositionen: {err}"
            ) from err

    # Schreiben ---
    def erstellen(self, bestellposition: Bestellposition) -> None:
        """Legt eine neue Bestellposition an."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO bestellposition(
                        bestellposition_id, menge, einzelpreis_gebucht, rabatt_angewendet, steuersatz_gebucht, bestellung_id, produkt_id
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        str(bestellposition.bestellposition_id),
                        bestellposition.menge,
                        bestellposition.einzelpreis_gebucht,
                        bestellposition.rabatt_angewendet,
                        bestellposition.steuersatz_gebucht,
                        str(bestellposition.bestellung_id),
                        str(bestellposition.produkt_id),
                    ),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Erstellen der Bestellposition: {err}"
            ) from err

    def erstellen_mehrere(self, bestellpositionen: list[Bestellposition]) -> None:
        """Legt mehrere Bestellpositionen in einer Transaktion an."""
        if not bestellpositionen:
            return

        try:
            with self.db.cursor() as cursor:
                cursor.executemany(
                    """
                    INSERT INTO bestellposition(
                        bestellposition_id, menge, einzelpreis_gebucht, rabatt_angewendet, steuersatz_gebucht, bestellung_id, produkt_id    
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    [
                        (
                            str(p.bestellposition_id),
                            p.menge,
                            p.einzelpreis_gebucht,
                            p.rabatt_angewendet,
                            p.steuersatz_gebucht,
                            str(p.bestellung_id),
                            str(p.produkt_id),
                        )
                        for p in bestellpositionen
                    ],
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Erstellen mehrerer Bestellpositionen: {err}"
            ) from err
