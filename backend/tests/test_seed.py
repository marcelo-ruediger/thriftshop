"""Tests für das Einspielen der Demo-Daten und den ersten Administrator."""

import sqlite3

import pytest

from app import seed
from app.core.config import einstellungen
from app.core.datenbank import schema_erstellen, verbinden
from app.dao.benutzer_dao import BenutzerDAO


@pytest.fixture
def leere_datenbank(tmp_path, monkeypatch):
    """Lenkt die App für einen Test auf eine frische, leere Datenbankdatei um."""
    pfad = tmp_path / "shop.db"
    monkeypatch.setattr(einstellungen, "datenbank_pfad", pfad)
    schema_erstellen()
    return pfad


def _anzahl(tabelle: str) -> int:
    verbindung = verbinden()
    try:
        return verbindung.execute(f"SELECT COUNT(*) FROM {tabelle}").fetchone()[0]
    finally:
        verbindung.close()


def test_demo_daten_werden_nur_in_eine_leere_datenbank_eingespielt(leere_datenbank):
    assert seed.demo_datenbank_bereitstellen() is True
    assert _anzahl("produkt") == len(seed.PRODUKTE)
    assert _anzahl("benutzer") == len(seed.DEMO_KONTEN)

    assert seed.demo_datenbank_bereitstellen() is False
    assert _anzahl("produkt") == len(seed.PRODUKTE)


def test_abgebrochenes_einspielen_hinterlaesst_eine_startfaehige_datenbank(
    leere_datenbank, monkeypatch
):
    """Früher blieben halbe Stammdaten zurück und jeder weitere Start scheiterte."""
    original = seed.passwort_hashen

    def absturz(_klartext):
        raise RuntimeError("Prozess beendet")

    monkeypatch.setattr(seed, "passwort_hashen", absturz)
    with pytest.raises(RuntimeError):
        seed.demo_datenbank_bereitstellen()
    assert _anzahl("zustand") == 0  # nichts Halbes in der echten Datenbank

    monkeypatch.setattr(seed, "passwort_hashen", original)
    assert seed.demo_datenbank_bereitstellen() is True
    assert _anzahl("benutzer") == len(seed.DEMO_KONTEN)


def test_demo_produkte_behalten_ihre_ids(leere_datenbank):
    """Nach einem Neuaufbau der Datenbank zeigen gespeicherte Warenkörbe auf dieselben Produkte."""
    seed.demo_datenbank_bereitstellen()
    verbindung = verbinden()
    try:
        zeile = verbindung.execute(
            "SELECT produkt_id FROM produkt WHERE slug = 'wollsocken-natur'"
        ).fetchone()
    finally:
        verbindung.close()
    assert zeile["produkt_id"] == seed.feste_id("produkt", "wollsocken-natur")


def test_erster_administrator_aus_der_konfiguration(leere_datenbank, monkeypatch):
    monkeypatch.setattr(einstellungen, "admin_email", "chefin@example.com")
    monkeypatch.setattr(einstellungen, "admin_passwort", "sicher-genug-1")
    verbindung: sqlite3.Connection = verbinden()
    try:
        assert seed.administrator_sicherstellen(verbindung) is True
        assert BenutzerDAO(verbindung).get_nach_email("chefin@example.com").rolle == "Administrator"
        # Gibt es schon einen Administrator, passiert nichts mehr
        monkeypatch.setattr(einstellungen, "admin_email", "zweite@example.com")
        assert seed.administrator_sicherstellen(verbindung) is False
        assert BenutzerDAO(verbindung).get_nach_email("zweite@example.com") is None
    finally:
        verbindung.close()


def test_ohne_konfiguration_wird_kein_administrator_angelegt(leere_datenbank):
    verbindung = verbinden()
    try:
        assert seed.administrator_sicherstellen(verbindung) is False
        assert _anzahl("benutzer") == 0
    finally:
        verbindung.close()
