"""
Datenbankverbindung - lädt .env-Variablen und stellt get_db() als FastAPI-Dependency bereit.
"""

import mysql.connector
import os
from dotenv import load_dotenv

_env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), '.env')
load_dotenv(_env_path)


def get_notwendige_env(name: str) -> str:
    """Gibt den Wert einer Umgebungsvariable zurück oder bricht bei Fehlen mit einem ValueError ab."""
    value = os.getenv(name)
    if value is None:
        raise ValueError(
            f"Kritischer Fehler: Die Variable '{name}' fehlt in der .env Datei!"
        )
    return value


def get_db():
    """FastAPI Dependency - gibt eine DB-Verbindung zurück und schliesst sie danach."""
    verbindung = mysql.connector.connect(
        host=get_notwendige_env("DB_HOST"),
        user=get_notwendige_env("DB_USER"),
        password=os.getenv("DB_PASSWORD", ""),
        database=get_notwendige_env("DB_NAME"),
    )
    try:
        yield verbindung
    finally:
        verbindung.close()
