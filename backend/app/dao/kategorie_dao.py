"""
Datenzugriff für die Tabelle 'kategorie' - SQL-Abfragen und -Mutationen.
"""

import sqlite3
from uuid import UUID

from app.models import Kategorie


class KategorieDAO:
    def __init__(self, db_verbindung: sqlite3.Connection):
        self.db = db_verbindung

    def get_alle(self) -> list[Kategorie]:
        """Gibt alle Kategorien alphabetisch sortiert zurück."""
        zeilen = self.db.execute(
            "SELECT * FROM kategorie ORDER BY bezeichnung COLLATE NOCASE"
        ).fetchall()
        return [Kategorie(**zeile) for zeile in zeilen]

    def get_nach_id(self, kategorie_id: UUID) -> Kategorie | None:
        zeile = self.db.execute(
            "SELECT * FROM kategorie WHERE kategorie_id = ?", (kategorie_id,)
        ).fetchone()
        return Kategorie(**zeile) if zeile else None

    def erstellen(self, kategorie: Kategorie) -> None:
        self.db.execute(
            """
            INSERT INTO kategorie (kategorie_id, bezeichnung, slug, kategorie_rabatt, steuersatz)
            VALUES (?, ?, ?, ?, ?)
            """,
            (
                kategorie.kategorie_id,
                kategorie.bezeichnung,
                kategorie.slug,
                kategorie.kategorie_rabatt,
                kategorie.steuersatz,
            ),
        )
        self.db.commit()

    def aktualisieren(self, kategorie: Kategorie) -> bool:
        cursor = self.db.execute(
            """
            UPDATE kategorie SET bezeichnung = ?, slug = ?, kategorie_rabatt = ?, steuersatz = ?
            WHERE kategorie_id = ?
            """,
            (
                kategorie.bezeichnung,
                kategorie.slug,
                kategorie.kategorie_rabatt,
                kategorie.steuersatz,
                kategorie.kategorie_id,
            ),
        )
        self.db.commit()
        return cursor.rowcount > 0

    def loeschen(self, kategorie_id: UUID) -> bool:
        """Löscht eine Kategorie. Schlägt fehl, solange Produkte sie referenzieren (ON DELETE RESTRICT)."""
        cursor = self.db.execute(
            "DELETE FROM kategorie WHERE kategorie_id = ?", (kategorie_id,)
        )
        self.db.commit()
        return cursor.rowcount > 0
