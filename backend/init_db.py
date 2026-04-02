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
    cursor.execute("USE thriftshop")

    # Benutzer-Tabelle --------------------------------
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS benutzer (
            benutzer_id CHAR(36) PRIMARY KEY,
            vorname VARCHAR(50) NOT NULL,
            nachname VARCHAR(50) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            telefon VARCHAR(30) UNIQUE NOT NULL,
            passwort_hash VARCHAR(255) NOT NULL,
            rolle VARCHAR(20) NOT NULL DEFAULT "Gast",
            erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            letzte_aenderung TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            letzter_login DATETIME DEFAULT NULL,
                   
            CONSTRAINT check_rolle CHECK (rolle IN ("Administrator", "Mitarbeiter", "Kunde"))
        )
    """)


      # Zustand-Tabelle
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS zustand (
            zustand_id CHAR(36) PRIMARY KEY,
            bezeichnung VARCHAR(255) UNIQUE NOT NULL,
            beschreibung TEXT NOT NULL
        )
    """)

    # Kategorie-Tabelle
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS kategorie (
            kategorie_id CHAR(36) PRIMARY KEY,
            bezeichnung VARCHAR(255) UNIQUE NOT NULL,
            slug VARCHAR(50) UNIQUE NOT NULL, 
            kategorie_rabatt DECIMAL(4,2) NOT NULL DEFAULT 0.00,
            steuersatz DECIMAL(5,2) NOT NULL DEFAULT 19.00
        )
    """)

    # Bestellungstabelle -----------------------------
    # ON DELETE RESTRICT für Archivierung 
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS bestellung (
            bestellung_id CHAR(36) PRIMARY KEY,   
            laufende_nr INT NOT NULL AUTO_INCREMENT UNIQUE,
            bestelldatum DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            status VARCHAR(20) NOT NULL DEFAULT "Offen",
            benutzer_id CHAR(36) NOT NULL,
                            
            CONSTRAINT bestellung_benutzer
                FOREIGN KEY (benutzer_id)
                REFERENCES benutzer(benutzer_id)
                ON DELETE RESTRICT,
            CONSTRAINT check_status
                CHECK(status IN ("Offen", "In Bearbeitung", "Abgeschlossen", "Storniert", "Erstattet"))
        )
    """)

    # Produkttabelle -----------------------------------
    # produkt_rabatt DEFAULT 0.00 -> Vereinfacht Backend Rechenlogik, SQL-Abfragen und vermeidet "NullPointerExceptions" 
    # ON DELETE RESTRICT -> Verhindert das Löschen von zustand_id und kategorie_id, solange noch Produkte darauf verweisen
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS produkt (
            produkt_id CHAR(36) PRIMARY KEY,
            laufende_nr INT NOT NULL AUTO_INCREMENT UNIQUE,
            erstellungsdatum DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            bezeichnung VARCHAR(255) UNIQUE NOT NULL,
            slug VARCHAR(50) UNIQUE NOT NULL, 
            produkt_info TEXT NOT NULL,
            preis DECIMAL(10,2) NOT NULL,
            produkt_rabatt DECIMAL(4,2) NOT NULL DEFAULT 0.00,
            produkt_aktiv BOOLEAN NOT NULL DEFAULT 1,
            lagerbestand INT NOT NULL DEFAULT 1,
                   
            zustand_id CHAR(36) NOT NULL,
            kategorie_id CHAR(36) NOT NULL,
            
            CONSTRAINT fk_produkt_zustand
                FOREIGN KEY (zustand_id)
                REFERENCES zustand(zustand_id)
                ON DELETE RESTRICT,
            CONSTRAINT fk_produkt_kategorie
                FOREIGN KEY (kategorie_id)
                REFERENCES kategorie(kategorie_id)
                ON DELETE RESTRICT
        )
    """)

    # Bestellposition-tabelle --------------------------------------
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS bestellposition (
        bestellposition_id CHAR(36) PRIMARY KEY,
        menge INT NOT NULL,
        einzelpreis_gebucht DECIMAL(10,2) NOT NULL, 
        rabatt_angewendet DECIMAL(4,2) NOT NULL,    
        steuersatz_gebucht DECIMAL(5,2) NOT NULL,   
        
        bestellung_id CHAR(36) NOT NULL,
        produkt_id CHAR(36) NOT NULL,
        
        CONSTRAINT fk_bestellposition_bestellung
            FOREIGN KEY (bestellung_id)
            REFERENCES bestellung(bestellung_id)
            ON DELETE CASCADE,
        CONSTRAINT fk_bestellposition_produkt
            FOREIGN KEY (produkt_id)
            REFERENCES produkt(produkt_id)
            ON DELETE RESTRICT
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

