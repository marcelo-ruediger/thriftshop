import mysql.connector
from uuid import UUID
from models import Bestellung


class BestellungDAO:
    def __init__(self, db_verbindung):
        """Initialisierung mit einer bestehenden DB-Verbindung."""
        self.db = db_verbindung

    # Lesen
    def get_alle(self, limit: int = 50, offset: int = 0) -> list[Bestellung]:
        """Gibt alle Bestellungen paginiert für das Admin-Dashboard zurück."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM bestellung ORDER BY laufende_nr DESC LIMIT %s OFFSET %s",
                    (limit, offset),
                )
                return [Bestellung(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellungen: {err}"
            ) from err  # Exception Chaining – verknüpft die neue Exception mit der ursprünglichen Ursache

    def get_nach_id(self, bestellung_id: UUID) -> Bestellung | None:
        """Sucht eine Bestellung anhand der UUID."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM bestellung WHERE bestellung_id = %s",
                    (str(bestellung_id),),
                )
                row = cursor.fetchone()
                return Bestellung(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellung: {err}"
            ) from err

    def get_nach_benutzer(self, benutzer_id: UUID) -> list[Bestellung]:
        """Gibt die Bestellhistorie eines Kunden zurück."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM bestellung WHERE benutzer_id = %s ORDER BY laufende_nr DESC",
                    (str(benutzer_id),),
                )
                return [Bestellung(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellungen: {err}"
            ) from err

    def get_nach_status(self, status: str) -> list[Bestellung]:
        """Gibt alle Bestellungen basierend auf dem Status zurück."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM bestellung WHERE status = %s ORDER BY laufende_nr DESC",
                    (status,),
                )
                return [Bestellung(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Bestellungen: {err}"
            ) from err

    # Schreiben – benötigt Rollback bei Exceptions
    def erstellen(self, bestellung: Bestellung) -> None:
        """Neue Bestellung anlegen"""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO bestellung (
                        bestellung_id, laufende_nr, bestelldatum, status, benutzer_id
                    ) VALUES (%s, %s, %s, %s, %s)
                    """,
                    (
                        str(bestellung.bestellung_id),
                        bestellung.laufende_nr,
                        bestellung.bestelldatum,
                        bestellung.status,
                        str(bestellung.benutzer_id),
                    ),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Erstellen der Bestellung: {err}"
            ) from err

    def status_aktualisieren(self, bestellung_id: UUID, neuer_status: str) -> None:
        """Status aktualisieren/ ändern. Valide Werte: Offen, In Bearbeitung, Abgeschlossen, Storniert und Erstattet."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    UPDATE bestellung SET
                        status = %s
                    WHERE bestellung_id = %s
                    """,
                    (
                        neuer_status,
                        str(bestellung_id),
                    ),
                )
                if cursor.rowcount == 0:
                    raise RuntimeError(
                        f"Keine Bestellung mit der ID {bestellung_id} gefunden"
                    )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Aktualisieren der Bestellung: {err}"
            ) from err
