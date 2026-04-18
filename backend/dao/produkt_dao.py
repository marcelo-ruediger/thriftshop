"""
Datezugriff für die Tabelle 'produkt' - SQL-Abfragen und -Mutationen.
"""

import mysql.connector
from uuid import UUID
from models import Produkt


class ProduktDAO:
    def __init__(self, db_verbindung):
        """Initialisierung mit einer bestehenden DB-Verbindung."""
        self.db = db_verbindung

    def get_alle(self, limit: int = 50, offset: int = 0) -> list[Produkt]:
        """Gibt alle Produkte zurück (auch inaktive) - für Admin-Dashboard."""
        try:
            with (
                self.db.cursor(dictionary=True) as cursor
            ):  # 'with' stellt sicher, dass cursor.close() am Ende ausgeführt wird
                cursor.execute(
                    "SELECT * FROM produkt ORDER BY laufende_nr DESC LIMIT %s OFFSET %s",
                    (limit, offset),
                )
                return [Produkt(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Produkte: {err}"
            ) from err  # from err = Exception Chaining - den ursprünglichen Fehler wird nicht verschluckt

    def get_all_aktiven(self) -> list[Produkt]:
        """Gibt nur aktive Produkte zurück - für den Onlineshop."""
        try:
            with (
                self.db.cursor(dictionary=True) as cursor
            ):  # Gibt ein Dictionary mit den Spaltennamen als Keys zurück, statt eines Tupels
                cursor.execute(
                    "SELECT * FROM produkt WHERE produkt_aktiv = TRUE ORDER BY laufende_nr DESC"
                )
                return [Produkt(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Produkte: {err}"
            ) from err

    def get_nach_id(self, produkt_id: UUID) -> Produkt | None:
        """Sucht ein Produkt anhand der UUID."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM produkt WHERE produkt_id = %s", (str(produkt_id),)
                )  # str() weil manche Datenbanktreiber nicht automatisch mit UUID-Objekten umgehen können
                row = cursor.fetchone()
                return Produkt(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden des Produkts: {err}"
            ) from err

    def get_nach_slug(self, slug: str) -> Produkt | None:
        """Sucht ein Produkt anhand des Slugs - für SEO-URLs."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT * FROM produkt WHERE slug = %s", (slug,))
                row = cursor.fetchone()
                return Produkt(**row) if row else None
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden des Produkts: {err}"
            ) from err

    def get_nach_kategorie_aktiv(self, kategorie: UUID) -> list[Produkt]:
        """Gibt nur aktiven Produkte einer Kategorie zurück - für den Onlineshop."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM produkt WHERE kategorie_id = %s AND produkt_aktiv = TRUE ORDER BY laufende_nr DESC",
                    (str(kategorie),),
                )
                return [Produkt(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Produkte: {err}"
            ) from err

    def get_nach_kategorie_alle(self, kategorie: UUID) -> list[Produkt]:
        """Gibt alle Produkte einer Kategorie zurück - für Admin-Dashboard."""
        try:
            with self.db.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT * FROM produkt WHERE kategorie_id = %s ORDER BY laufende_nr DESC",
                    (str(kategorie),),
                )
                return [Produkt(**row) for row in cursor.fetchall()]
        except mysql.connector.Error as err:
            raise RuntimeError(
                f"Datenbankfehler beim Laden der Produkte: {err}"
            ) from err

    # Schreiben – benötigt Rollback bei Exceptions
    def erstellen(self, produkt: Produkt) -> None:
        """Fügt ein neues Produkt in die Datenbank ein."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO produkt (
                        produkt_id, laufende_nr, bezeichnung, slug, produkt_info,
                        preis, produkt_rabatt, lagerbestand,
                        zustand_id, kategorie_id, produkt_aktiv, erstellungsdatum
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        str(produkt.produkt_id),
                        produkt.laufende_nr,
                        produkt.bezeichnung,
                        produkt.slug,
                        produkt.produkt_info,
                        produkt.preis,
                        produkt.produkt_rabatt,
                        produkt.lagerbestand,
                        str(produkt.zustand_id),
                        str(produkt.kategorie_id),
                        produkt.produkt_aktiv,
                        produkt.erstellungsdatum,
                    ),
                )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Erstellen des Produkts: {err}"
            ) from err

    def aktualisieren(self, produkt: Produkt) -> None:
        """Aktualisiert ein bestehendes Produkt in der Datenbank."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    """
                    UPDATE produkt SET
                        bezeichnung = %s,
                        slug = %s,
                        produkt_info = %s,
                        preis = %s,
                        produkt_rabatt = %s,
                        lagerbestand = %s,
                        zustand_id = %s,
                        kategorie_id = %s,
                        produkt_aktiv = %s
                    WHERE produkt_id = %s
                    """,
                    (
                        produkt.bezeichnung,
                        produkt.slug,
                        produkt.produkt_info,
                        produkt.preis,
                        produkt.produkt_rabatt,
                        produkt.lagerbestand,
                        str(produkt.zustand_id),
                        str(produkt.kategorie_id),
                        produkt.produkt_aktiv,
                        str(produkt.produkt_id),
                    ),
                )
                if cursor.rowcount == 0:
                    raise RuntimeError(
                        f"Kein Produkt mit der ID {produkt.produkt_id} gefunden"
                    )
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Aktualisieren des Produkts {produkt.produktnr}: {err}"
            ) from err

    def deaktivieren(self, produkt_id: UUID) -> None:
        """Deaktiviert ein Produkt (Soft-Delete) - verhindert Datenverlust bei bestehenden Bestellungen."""
        try:
            with self.db.cursor() as cursor:
                cursor.execute(
                    "UPDATE produkt SET produkt_aktiv = FALSE WHERE produkt_id = %s",
                    (str(produkt_id),),
                )
                if cursor.rowcount == 0:
                    raise RuntimeError(f"Kein Produkt mit der ID {produkt_id} gefunden")
            self.db.commit()
        except mysql.connector.Error as err:
            self.db.rollback()
            raise RuntimeError(
                f"Datenbankfehler beim Deaktivieren des Produkts: {err}"
            ) from err
