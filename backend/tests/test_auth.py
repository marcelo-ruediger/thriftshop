"""
Automatisierte Integrationstests für /auth-Endpunkte.

Voraussetzungen:
    pip install pytest httpx
    Ausführen aus backend/: pytest tests/test_auth.py -v

Hinweis: Diese Tests verwenden einen TestClient der die FastAPI-App direkt
aufruft - kein laufender Server nötig. Die Datenbank muss jedoch erreichbar sein.
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

# raise_server_exceptions=False: Server-Fehler (500) werden als Response
# zurückgegeben statt als Exception – ermöglicht assert auf status_code
client = TestClient(app, raise_server_exceptions=False)


def _neue_testdaten() -> dict:
    """Erzeugt Testdaten mit eindeutiger UUID und E-Mail für jeden Testlauf.
    Verhindert 'Duplicate entry'-Fehler bei wiederholtem Ausführen der Tests.
    """
    eindeutige_id = str(uuid.uuid4())
    return {
        "benutzer_id": eindeutige_id,
        "vorname": "Test",
        "nachname": "Benutzer",
        "email": f"test_{eindeutige_id[:8]}@test.de",  # eindeutige E-Mail
        "telefon": f"0{eindeutige_id[:10].replace('-', '')}",  # eindeutige Telefonnummer
        "passwort_hash": "testPasswort123",  # Klartext – Route hasht automatisch
        "rolle": "Kunde",
        "erstellt_am": "2026-04-19T08:58:38.148Z",
        "letzte_aenderung": "2026-04-19T08:58:38.148Z",
        "letzter_login": "2026-04-19T08:58:38.148Z",
    }


class TestRegistrieren:
    """Tests für POST /auth/registrieren"""

    def test_registrieren_erfolgreich(self):
        """Neuer Benutzer wird angelegt - erwartet HTTP 201."""
        antwort = client.post("/auth/registrieren", json=_neue_testdaten())
        assert antwort.status_code == 201
        assert antwort.json() == {"nachricht": "Benutzer erfolgreich registriert"}

    def test_registrieren_ungueltige_rolle(self):
        """Ungültige Rolle schlägt mit HTTP 500 fehl (DB CHECK-Constraint)."""
        daten = {**_neue_testdaten(), "rolle": "Gast"}  # "Gast" ist nicht erlaubt
        antwort = client.post("/auth/registrieren", json=daten)
        assert antwort.status_code == 500


class TestLogin:
    """Tests für POST /auth/login.
    Jeder Test registriert zuerst einen frischen Benutzer, damit das
    Passwort garantiert korrekt gehasht in der DB liegt.
    """

    def test_login_erfolgreich(self):
        """Korrekte E-Mail und Passwort - erwartet HTTP 200 mit JWT."""
        # Zuerst frischen Benutzer anlegen
        daten = _neue_testdaten()
        client.post("/auth/registrieren", json=daten)

        # Dann mit Klartext-Passwort einloggen
        antwort = client.post(
            "/auth/login",
            params={"email": daten["email"], "passwort": daten["passwort_hash"]},
        )
        assert antwort.status_code == 200
        ergebnis = antwort.json()
        assert "access_token" in ergebnis
        assert ergebnis["token_type"] == "bearer"

    def test_login_falsches_passwort(self):
        """Falsches Passwort - erwartet HTTP 401."""
        daten = _neue_testdaten()
        client.post("/auth/registrieren", json=daten)

        antwort = client.post(
            "/auth/login",
            params={"email": daten["email"], "passwort": "falschesPasswort"},
        )
        assert antwort.status_code == 401

    def test_login_unbekannte_email(self):
        """Nicht registrierte E-Mail - erwartet HTTP 401."""
        antwort = client.post(
            "/auth/login",
            params={"email": "nichtvorhanden@test.de", "passwort": "egal"},
        )
        assert antwort.status_code == 401
