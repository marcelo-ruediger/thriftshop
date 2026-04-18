import mysql.connector
from uuid import UUID
from models import Zustand


class ZustandDAO:
    def __init__(self, db_verbindung):
        """Initialisierung mit bestehender DB-Verbindung."""
        self.db = db_verbindung

    # Lesen ---
    def get_alle(self, limit: int = 50, offset: int = 0) -> list[Zustand]:
        """Gibt alle Zustände paginiert zurück."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT * FROM zustand
                    ORDER BY bezeichnung ASC
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset),
                )
                return [Zustand(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Zustände: {err}"
            ) from err

    def get_nach_id(self, zustand_id: UUID) -> Zustand | None:
        """Lädt einen Zustand anhand der UUID."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM zustand WHERE zustand_id = %s",
                    (str(zustand_id),),
                )
                row = cursor.fetchone()
                return Zustand(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden des Zustands: {err}"
            ) from err

    def get_nach_bezeichnung(self, bezeichnung: str) -> Zustand | None:
        """Lädt einen Zustand anhand der Bezeichnung."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM zustand WHERE bezeichnung = %s",
                    (bezeichnung,),
                )
                row = cursor.fetchone()
                return Zustand(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden des Zustands: {err}"
            ) from err

    # Schreiben ---
    def erstellen(self, zustand: Zustand) -> None:
        """Legt einen neuen Zustand an."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO zustand (
                        zustand_id, bezeichnung, beschreibung
                    ) VALUES (%s, %s, %s)
                    """,
                    (
                        str(zustand.zustand_id),
                        zustand.bezeichnung,
                        zustand.beschreibung,
                    ),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Erstellen des Zustands: {err}"
            ) from err

    def aktualisieren(self, zustand: Zustand) -> None:
        """Aktualisiert einen bestehenden Zustand."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    UPDATE zustand SET
                        bezeichnung = %s,
                        beschreibung = %s
                    WHERE zustand_id = %s
                    """,
                    (
                        zustand.bezeichnung,
                        zustand.beschreibung,
                        str(zustand.zustand_id),
                    ),
                )
                if cursor.rowcount == 0:
                    raise RuntimeError(
                        f"Kein Zustand mit der ID {zustand.zustand_id} gefunden"
                    )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Aktualisieren des Zustands: {err}"
            ) from err

    def loeschen(self, zustand_id: UUID) -> None:
        """Löscht einen Zustand, falls keine Produkte darauf verweisen."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    "DELETE FROM zustand WHERE zustand_id = %s", (str(zustand_id),)
                )
                if cursor.rowcount == 0:
                    raise RuntimeError(f"Kein Zustand mit der ID {zustand_id} gefunden")
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Löschen des Zustands: {err}"
            ) from err
