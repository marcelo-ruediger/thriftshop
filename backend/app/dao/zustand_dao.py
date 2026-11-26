"""
Datenzugriff für die Tabelle 'zustand' - SQL-Abfragen und -Mutationen.
"""

import sqlite3
from uuid import UUID

from app.models import Zustand


class ZustandDAO:
    def __init__(self, db_verbindung: sqlite3.Connection):
        self.db = db_verbindung

    def get_alle(self) -> list[Zustand]:
        """Gibt alle Zustände zurück - vom besten zum schlechtesten (Reihenfolge des Anlegens)."""
        zeilen = self.db.execute("SELECT * FROM zustand ORDER BY rowid").fetchall()
        return [Zustand(**zeile) for zeile in zeilen]

    def get_nach_id(self, zustand_id: UUID) -> Zustand | None:
        zeile = self.db.execute(
            "SELECT * FROM zustand WHERE zustand_id = ?", (zustand_id,)
        ).fetchone()
        return Zustand(**zeile) if zeile else None

    def erstellen(self, zustand: Zustand) -> None:
        self.db.execute(
            "INSERT INTO zustand (zustand_id, bezeichnung, beschreibung) VALUES (?, ?, ?)",
            (zustand.zustand_id, zustand.bezeichnung, zustand.beschreibung),
        )
        self.db.commit()

    def aktualisieren(self, zustand: Zustand) -> bool:
        cursor = self.db.execute(
            "UPDATE zustand SET bezeichnung = ?, beschreibung = ? WHERE zustand_id = ?",
            (zustand.bezeichnung, zustand.beschreibung, zustand.zustand_id),
        )
        self.db.commit()
        return cursor.rowcount > 0

    def loeschen(self, zustand_id: UUID) -> bool:
        """Löscht einen Zustand. Schlägt fehl, solange Produkte ihn referenzieren (ON DELETE RESTRICT)."""
        cursor = self.db.execute(
            "DELETE FROM zustand WHERE zustand_id = ?", (zustand_id,)
        )
        self.db.commit()
        return cursor.rowcount > 0
