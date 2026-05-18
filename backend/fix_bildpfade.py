"""
Fix für 4 Produkte, die nicht automatisch zugeordnet wurden.
"""

import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

# Mapping für die fehlenden Produkte
FIX_ZUORDNUNG = {
    "Minirock Schwarz Classic": "025_rock1.png",
    "Portmonnaie Schwarz Compact": "015_geldbeutel1.png",
    "Rucksack Grün Outdoor": "012_tasche1.png",  # Tasche als Ersatz
    "Videospiele Adventure XP10": "044_videospiel.png",
}


def main():
    try:
        conn = mysql.connector.connect(
            host="localhost", user="root", password=os.getenv("DB_PASSWORD")
        )
        cursor = conn.cursor(dictionary=True)
        cursor.execute("USE thriftshop")

        for bezeichnung, bild in FIX_ZUORDNUNG.items():
            cursor.execute(
                "UPDATE produkt SET bildpfad = %s WHERE bezeichnung = %s",
                (bild, bezeichnung),
            )
            print(f"✓ {bezeichnung} -> {bild}")

        conn.commit()
        cursor.close()
        conn.close()
        print("\nFix durchgeführt!")

    except Exception as e:
        print(f"Fehler: {e}")


if __name__ == "__main__":
    main()
