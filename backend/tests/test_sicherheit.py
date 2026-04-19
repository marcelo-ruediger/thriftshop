"""
Unit-Tests für app/core/sicherheit.py - Passwort-Hashing und JWT-Tokenverwaltung.
Kein Server und keine Datenbank nötig - reine Funktionsaufrufe.

Ausführen aus Backend/: pytest tests/test_sicherheit.py -v
"""

from app.core.sicherheit import (
    passwort_hashen,
    passwort_pruefen,
    token_erstellen,
    token_lesen,
)


class TestPasswortHashing:
    """Tests für passwort_hashen() und passwort_pruefen()"""

    def test_hash_wird_erzeugt(self):
        """Gehashtes Passwort ist nicht identisch mit dem Klartext."""
        klartext = "geheimesPasswort"
        ergebnis = passwort_hashen(klartext)
        assert ergebnis != klartext

    def test_korrektes_passwort_wird_akzeptiert(self):
        """Richtiges Passwort besteht die Prüfung."""
        h = passwort_hashen("geheim123")
        assert passwort_pruefen("geheim123", h) is True

    def test_falsches_passwort_wird_abgelehnt(self):
        """Falsches Passwort besteht die Prüfung nicht."""
        h = passwort_hashen("geheim123")
        assert passwort_pruefen("anderes", h) is False

    def test_zwei_hashes_sind_unterschiedlich(self):
        """Dasselbe Passwort erzeugt zwei verschiedene Hashes (Salt)."""
        h1 = passwort_hashen("gleichesPasswort")
        h2 = passwort_hashen("gleichesPasswort")
        assert h1 != h2  # bcrypt verwendet zufälliges Salt


class TestToken:
    """Tests für token_erstellen() und token_lesen()"""

    def test_token_wird_erzeugt(self):
        """token_erstellen() gibt einen nicht-leeren String zurück."""
        token = token_erstellen({"sub": "test-uuid", "rolle": "Kunde"})
        assert isinstance(token, str)
        assert len(token) > 0

    def test_token_inhalt_korrekt(self):
        """Dekodierter Token enthält die ursprünglichen Daten."""
        token = token_erstellen({"sub": "abc-123", "rolle": "Administrator"})
        daten = token_lesen(token)
        assert daten["sub"] == "abc-123"
        assert daten["rolle"] == "Administrator"
