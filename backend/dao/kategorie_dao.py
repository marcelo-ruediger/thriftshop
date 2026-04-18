import mysql.connector
from uuid import UUID
from models import Kategorie


class KategorieDAO:
    def __init__(self, db_verbindung):
        """Initialisierung mit bestehender DB-Verbindung."""
        self.db = db_verbindung

    # Lesen ---
    def get_alle(self, limit: int = 50, offset: int = 0) -> list[Kategorie]:
        """Gibt alle Kategorien paginiert zurück."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT * FROM kategorie
                    ORDER BY bezeichnung ASC
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset),
                )
                return [Kategorie(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Kategorien: {err}"
            ) from err

    def get_nach_id(self, kategorie_id: UUID) -> Kategorie | None:
        """Lädt eine Kategorie anhand der UUID."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM kategorie WHERE kategorie_id = %s",
                    (str(kategorie_id),),
                )
                row = cursor.fetchone()
                return Kategorie(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Kategorie: {err}"
            ) from err

    def get_nach_slug(self, slug: str) -> Kategorie | None:
        """Lädt eine Kategorie anhand des Slugs."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT * FROM kategorie WHERE slug = %s", (slug,))
                row = cursor.fetchone()
                return Kategorie(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Kategorie: {err}"
            ) from err

    # Schreiben ---
    def erstellen(self, kategorie: Kategorie) -> None:
        """Legt eine neue Kategorie an."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO kategorie (
                        kategorie_id, bezeichnung, slug, kategorie_rabatt, steuersatz
                    ) VALUES (%s, %s, %s, %s, %s)
                    """,
                    (
                        str(kategorie.kategorie_id),
                        kategorie.bezeichnung,
                        kategorie.slug,
                        kategorie.kategorie_rabatt,
                        kategorie.steuersatz,
                    ),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Erstellen der Kategorie: {err}"
            ) from err

    def aktualisieren(self, kategorie: Kategorie) -> None:
        """Aktualisiert eine bestehende Kategorie."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    UPDATE kategorie SET
                        bezeichnung = %s,
                        slug = %s,
                        kategorie_rabatt = %s,
                        steuersatz = %s
                    WHERE kategorie_id = %s
                    """,
                    (
                        kategorie.bezeichnung,
                        kategorie.slug,
                        kategorie.kategorie_rabatt,
                        kategorie.steuersatz,
                        str(kategorie.kategorie_id),
                    ),
                )
                if cursor.rowcount == 0:
                    raise RuntimeError(
                        f"Keine Kategorie mit der ID {kategorie.kategorie_id} gefunden"
                    )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Aktualisieren der Kategorie: {err}"
            ) from err

    def loeschen(self, kategorie_id: UUID) -> None:
        """Löscht eine Kategorie, falls keine Produkte darauf verweisen."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    "DELETE FROM kategorie WHERE kategorie_id = %s",
                    (str(kategorie_id),),
                )
                if cursor.rowcount == 0:
                    raise RuntimeError(
                        f"Keine Kategorie mit der ID {kategorie_id} gefunden"
                    )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Löschen der Kategorie: {err}"
            ) from err
