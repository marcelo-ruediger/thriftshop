import mysql.connector
import os
from dotenv import load_dotenv

DB_PATH = "thriftshop.db"
load_dotenv()

def init_db():
    """Erstellt die Datenbank-Schema"""
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password=os.getenv("DB_PASSWORD")
    )
    cursor = conn.cursor()

    cursor.execute("SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'thriftshop'")
    db_exists = cursor.fetchone() is not None

    cursor.execute("CREATE DATABASE IF NOT EXISTS thriftshop")

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS produkte_katalog (
            id TEXT PRIMARY KEY,
            
        )
    """)


    
    if db_exists:
        print("Datenbank existierte bereits!")
    else:
        print("Datenbank inisialisiert!")

    cursor.close()
    conn.close()

if __name__ == "__main__":
    init_db()