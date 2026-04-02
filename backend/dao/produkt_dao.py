import mysql.connector
from uuid import UUID
from decimal import Decimal
from models import Produkt

class ProduktDAO:
    def __init__(self, db_connection):
        """Initialisierung mit einer bestehenden DB-Verbindung"""
        self.db = db_connection

    def get_all_active(self) -> list[Produkt]:
        cursor = self.db.cursor(dictionary=True) # Gibt ein Dictionary mit den Spaltennamen als Attribute zurück, statt eines Tupels
        cursor.execute("SELECT * FROM produkte WHERE ist_aktiv = 1")
        return [Produkt(**row) for row in cursor.fetchall()]
    
    def get_by_id(self, p_id:int) -> Produkt | None:
        cursor = self.db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM produkte WHERE id = %s", (p_id))
        row = cursor.fetchone()
        return Produkt(**row) if row else None

