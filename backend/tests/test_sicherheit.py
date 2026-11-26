"""Unit-Tests für das Sicherheitsmodul und die Preislogik (ohne Datenbank)."""

from decimal import Decimal

import pytest
from jose import JWTError

from app.core.sicherheit import (
    passwort_hashen,
    passwort_pruefen,
    token_erstellen,
    token_lesen,
)
from app.services import preise
from app.services.slug import slug_erzeugen


def test_passwort_wird_nicht_im_klartext_gespeichert():
    hash_ = passwort_hashen("geheim1234")
    assert hash_ != "geheim1234"
    assert hash_.startswith("$2")  # bcrypt


def test_gleiches_passwort_ergibt_verschiedene_hashes():
    assert passwort_hashen("geheim1234") != passwort_hashen("geheim1234")  # Salt


def test_passwort_pruefen():
    hash_ = passwort_hashen("geheim1234")
    assert passwort_pruefen("geheim1234", hash_)
    assert not passwort_pruefen("falsch", hash_)
    assert not passwort_pruefen("egal", "")  # anonymisiertes Konto ohne Hash


def test_token_enthaelt_die_daten():
    payload = token_lesen(token_erstellen({"sub": "abc", "rolle": "Kunde"}))
    assert payload["sub"] == "abc"
    assert payload["rolle"] == "Kunde"
    assert "exp" in payload


def test_manipulierter_token_wird_abgelehnt():
    token = token_erstellen({"sub": "abc"})
    with pytest.raises(JWTError):
        token_lesen(token[:-2] + "xx")


def test_es_gilt_der_hoehere_rabatt():
    assert preise.rabatt_prozent(Decimal("15"), Decimal("10")) == Decimal("15")
    assert preise.rabatt_prozent(Decimal("0"), Decimal("10")) == Decimal("10")


def test_rabatt_wird_kaufmaennisch_gerundet():
    assert preise.rabatt_betrag(Decimal("33.33"), Decimal("15")) == Decimal("5.00")
    assert preise.rabatt_betrag(Decimal("0.25"), Decimal("10")) == Decimal("0.03")


def test_enthaltene_mehrwertsteuer():
    assert preise.enthaltene_mwst(Decimal("119.00"), Decimal("19")) == Decimal("19.00")
    assert preise.enthaltene_mwst(Decimal("107.00"), Decimal("7")) == Decimal("7.00")


def test_slug():
    assert slug_erzeugen("Möbel & Wohnen") == "moebel-wohnen"
    assert slug_erzeugen("  Größe  XL!  ") == "groesse-xl"
    assert slug_erzeugen("???") == "artikel"
