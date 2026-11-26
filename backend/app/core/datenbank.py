"""
Datenbankzugriff - SQLite-Verbindung, Schema und die FastAPI-Dependency get_db().

SQLite braucht keinen eigenen Server: die komplette Datenbank liegt in einer Datei.
Die SQL-Logik bleibt vollständig in den DAOs gekapselt.
"""

import sqlite3
from collections.abc import Iterator
from datetime import datetime, timezone
from decimal import Decimal
from uuid import UUID

from app.core.config import einstellungen

CENT = Decimal("0.01")

# Python-Typen <-> SQLite-Spaltentypen
sqlite3.register_adapter(Decimal, str)
sqlite3.register_adapter(UUID, str)
sqlite3.register_adapter(datetime, lambda wert: wert.isoformat(timespec="seconds"))
sqlite3.register_converter("CHAR", lambda roh: UUID(roh.decode()))  # CHAR(36) = UUID
sqlite3.register_converter("DECIMAL", lambda roh: Decimal(roh.decode()).quantize(CENT))
sqlite3.register_converter("DATETIME", lambda roh: datetime.fromisoformat(roh.decode()))
sqlite3.register_converter("BOOLEAN", lambda roh: roh != b"0")

SCHEMA = """
CREATE TABLE IF NOT EXISTS benutzer (
    benutzer_id      CHAR(36) PRIMARY KEY,
    vorname          VARCHAR(50) NOT NULL,
    nachname         VARCHAR(50) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE COLLATE NOCASE,
    telefon          VARCHAR(30),
    passwort_hash    VARCHAR(255) NOT NULL,
    rolle            VARCHAR(20) NOT NULL DEFAULT 'Kunde'
                     CHECK (rolle IN ('Administrator', 'Mitarbeiter', 'Kunde')),
    erstellt_am      DATETIME NOT NULL,
    letzte_aenderung DATETIME NOT NULL,
    letzter_login    DATETIME
);

CREATE TABLE IF NOT EXISTS zustand (
    zustand_id   CHAR(36) PRIMARY KEY,
    bezeichnung  VARCHAR(255) NOT NULL UNIQUE,
    beschreibung TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS kategorie (
    kategorie_id     CHAR(36) PRIMARY KEY,
    bezeichnung      VARCHAR(255) NOT NULL UNIQUE,
    slug             VARCHAR(80) NOT NULL UNIQUE,
    kategorie_rabatt DECIMAL(4,2) NOT NULL DEFAULT 0
                     CHECK (kategorie_rabatt >= 0 AND kategorie_rabatt < 100),
    steuersatz       DECIMAL(5,2) NOT NULL DEFAULT 19
                     CHECK (steuersatz >= 0 AND steuersatz < 100)
);

-- ON DELETE RESTRICT: Zustand/Kategorie können nicht gelöscht werden, solange Produkte darauf verweisen
CREATE TABLE IF NOT EXISTS produkt (
    produkt_id       CHAR(36) PRIMARY KEY,
    laufende_nr      INTEGER NOT NULL UNIQUE,
    erstellungsdatum DATETIME NOT NULL,
    bezeichnung      VARCHAR(255) NOT NULL,
    slug             VARCHAR(120) NOT NULL UNIQUE,
    produkt_info     TEXT NOT NULL,
    preis            DECIMAL(10,2) NOT NULL CHECK (preis > 0),
    produkt_rabatt   DECIMAL(4,2) NOT NULL DEFAULT 0
                     CHECK (produkt_rabatt >= 0 AND produkt_rabatt < 100),
    produkt_aktiv    BOOLEAN NOT NULL DEFAULT 1,
    lagerbestand     INTEGER NOT NULL DEFAULT 1 CHECK (lagerbestand >= 0),
    bildpfad         VARCHAR(255),
    zustand_id       CHAR(36) NOT NULL REFERENCES zustand(zustand_id) ON DELETE RESTRICT,
    kategorie_id     CHAR(36) NOT NULL REFERENCES kategorie(kategorie_id) ON DELETE RESTRICT
);

-- ON DELETE RESTRICT: Bestellungen bleiben für die Buchhaltung erhalten
CREATE TABLE IF NOT EXISTS bestellung (
    bestellung_id CHAR(36) PRIMARY KEY,
    laufende_nr   INTEGER NOT NULL UNIQUE,
    bestelldatum  DATETIME NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'Offen'
                  CHECK (status IN ('Offen', 'In Bearbeitung', 'Abgeschlossen', 'Storniert', 'Erstattet')),
    zahlungsart   VARCHAR(30) NOT NULL DEFAULT 'Zahlung bei Abholung'
                  CHECK (zahlungsart IN ('Zahlung bei Abholung', 'Rechnung')),
    anmerkung     TEXT,
    benutzer_id   CHAR(36) NOT NULL REFERENCES benutzer(benutzer_id) ON DELETE RESTRICT
);

-- Snapshot von Preis, Rabatt und Steuersatz zum Kaufzeitpunkt
CREATE TABLE IF NOT EXISTS bestellposition (
    bestellposition_id  CHAR(36) PRIMARY KEY,
    menge               INTEGER NOT NULL CHECK (menge > 0),
    einzelpreis_gebucht DECIMAL(10,2) NOT NULL,
    rabatt_angewendet   DECIMAL(10,2) NOT NULL DEFAULT 0,
    steuersatz_gebucht  DECIMAL(5,2) NOT NULL,
    bestellung_id       CHAR(36) NOT NULL REFERENCES bestellung(bestellung_id) ON DELETE CASCADE,
    produkt_id          CHAR(36) NOT NULL REFERENCES produkt(produkt_id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_produkt_kategorie ON produkt(kategorie_id);
CREATE INDEX IF NOT EXISTS idx_bestellung_benutzer ON bestellung(benutzer_id);
CREATE INDEX IF NOT EXISTS idx_position_bestellung ON bestellposition(bestellung_id);
"""


def jetzt() -> datetime:
    """Aktueller Zeitpunkt in UTC - alle Zeitstempel werden zeitzonenbewusst gespeichert."""
    return datetime.now(timezone.utc).replace(microsecond=0)


def verbinden() -> sqlite3.Connection:
    """Öffnet eine neue Verbindung zur SQLite-Datei."""
    einstellungen.datenbank_pfad.parent.mkdir(parents=True, exist_ok=True)
    verbindung = sqlite3.connect(
        einstellungen.datenbank_pfad,
        detect_types=sqlite3.PARSE_DECLTYPES,
        # FastAPI führt Dependency und Endpunkt ggf. in verschiedenen Threads aus
        check_same_thread=False,
        timeout=10,
    )
    verbindung.row_factory = sqlite3.Row
    verbindung.execute("PRAGMA foreign_keys = ON")
    return verbindung


def schema_erstellen() -> None:
    """Legt alle Tabellen an, falls sie noch nicht existieren."""
    verbindung = verbinden()
    try:
        verbindung.executescript(SCHEMA)
        verbindung.commit()
    finally:
        verbindung.close()


def get_db() -> Iterator[sqlite3.Connection]:
    """FastAPI-Dependency - gibt eine DB-Verbindung zurück und schließt sie danach."""
    verbindung = verbinden()
    try:
        yield verbindung
    finally:
        verbindung.close()
