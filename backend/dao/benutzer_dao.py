import mysql.connector
from uuid import UUID
from models import Benutzer


class BenutzerDAO:
    def __init__(self, db_verbindung):
        """Initialisierung mit bestehender DB-Verbindung."""
        self.db = db_verbindung

    # Lesen
    def get_alle(self, limit: int = 50, offset: int = 0) -> list[Benutzer]:
        """Gibt alle Benutzer paginiert zurück (Admin-Sicht)."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT * FROM benutzer
                    ORDER BY erstellt_am DESC, email ASC
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset),
                )
                return [Benutzer(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(f"Datenbankfehler beim Laden der Benutzer: {err}") from err

    def get_nach_id(self, benutzer_id: UUID) -> Benutzer | None:
        """Lädt einen Benutzer anhand der UUID."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM benutzer WHERE benutzer_id = %s",
                    (str(benutzer_id),),
                )
                row = cursor.fetchone()
                return Benutzer(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(f"Datenbankfehler beim Laden des Benutzers: {err}") from err

    def get_nach_email(self, email: str) -> Benutzer | None:
        """Lädt einen Benutzer anhand der E-Mail (für Login)."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT * FROM benutzer WHERE email = %s", (email,))
                row = cursor.fetchone()
                return Benutzer(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(f"Datenbankfehler beim Laden des Benutzers: {err}") from err

    # Schreiben
    def erstellen(self, benutzer: Benutzer) -> None:
        """Legt einen neuen Benutzer an."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO benutzer (
                        benutzer_id, vorname, nachname, email, telefon,
                        passwort_hash, rolle, erstellt_am, letzte_aenderung, letzter_login
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        str(benutzer.benutzer_id),
                        benutzer.vorname,
                        benutzer.nachname,
                        benutzer.email,
                        benutzer.telefon,
                        benutzer.passwort_hash,
                        benutzer.rolle,
                        benutzer.erstellt_am,
                        benutzer.letzte_aenderung,
                        benutzer.letzter_login,
                    ),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(f"Datenbankfehler beim Erstellen des Benutzers: {err}") from err

    def aktualisieren_stammdaten(self, benutzer: Benutzer) -> None:
        """Aktualisiert Name, Kontakt, Rolle und letzte_aenderung."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    UPDATE benutzer SET
                        vorname = %s,
                        nachname = %s,
                        email = %s,
                        telefon = %s,
                        rolle = %s,
                        letzte_aenderung = %s
                    WHERE benutzer_id = %s
                    """,
                    (
                        benutzer.vorname,
                        benutzer.nachname,
                        benutzer.email,
                        benutzer.telefon,
                        benutzer.rolle,
                        benutzer.letzte_aenderung,
                        str(benutzer.benutzer_id),
                    ),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(f"Datenbankfehler beim Aktualisieren des Benutzers: {err}") from err

    def passwort_setzen(self, benutzer_id: UUID, neues_passwort_hash: str) -> None:
        """Setzt einen neuen Passwort-Hash."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    UPDATE benutzer SET
                        passwort_hash = %s,
                        letzte_aenderung = NOW()
                    WHERE benutzer_id = %s
                    """,
                    (neues_passwort_hash, str(benutzer_id)),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(f"Datenbankfehler beim Aktualisieren des Passworts: {err}") from err

    def letzter_login_setzen(self, benutzer_id: UUID) -> None:
        """Aktualisiert den Zeitpunkt des letzten Logins."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    "UPDATE benutzer SET letzter_login = NOW() WHERE benutzer_id = %s",
                    (str(benutzer_id),),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(f"Datenbankfehler beim Aktualisieren des letzten Logins: {err}") from err

    def loeschen(self, benutzer_id: UUID) -> None:
        """Löscht einen Benutzer (hartes Löschen, falls FK-Regeln es zulassen)."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute("DELETE FROM benutzer WHERE benutzer_id = %s", (str(benutzer_id),))
                if cursor.rowcount == 0:
                    raise RuntimeError(f"Kein Benutzer mit der ID {benutzer_id} gefunden")
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(f"Datenbankfehler beim Löschen des Benutzers: {err}") from err