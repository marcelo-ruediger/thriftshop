"""Integrationstests - Registrierung, Login und Profilverwaltung."""

import uuid


def _registrierung(**felder) -> dict:
    return {
        "vorname": "Ada",
        "nachname": "Lovelace",
        "email": f"ada-{uuid.uuid4().hex[:10]}@example.com",
        "passwort": "geheim1234",
        **felder,
    }


def test_registrierung_meldet_direkt_an(client):
    antwort = client.post("/api/auth/registrieren", json=_registrierung())
    assert antwort.status_code == 201
    inhalt = antwort.json()
    assert inhalt["token_type"] == "bearer"
    assert inhalt["benutzer"]["rolle"] == "Kunde"
    assert "passwort_hash" not in inhalt["benutzer"]


def test_rolle_kann_bei_der_registrierung_nicht_gewaehlt_werden(client):
    antwort = client.post(
        "/api/auth/registrieren", json=_registrierung(rolle="Administrator")
    )
    assert antwort.status_code == 201
    assert antwort.json()["benutzer"]["rolle"] == "Kunde"


def test_doppelte_email_wird_abgelehnt(client, neuer_kunde):
    _, benutzer, _ = neuer_kunde
    antwort = client.post(
        "/api/auth/registrieren", json=_registrierung(email=benutzer["email"].upper())
    )
    assert antwort.status_code == 409


def test_zu_kurzes_passwort_wird_abgelehnt(client):
    antwort = client.post("/api/auth/registrieren", json=_registrierung(passwort="kurz"))
    assert antwort.status_code == 422


def test_login_mit_falschem_passwort(client):
    antwort = client.post(
        "/api/auth/login", json={"email": "kunde@example.com", "passwort": "falsch"}
    )
    assert antwort.status_code == 401


def test_login_mit_unbekannter_email(client):
    antwort = client.post(
        "/api/auth/login", json={"email": "niemand@example.com", "passwort": "geheim1234"}
    )
    assert antwort.status_code == 401


def test_me_liefert_den_eingeloggten_benutzer(client, neuer_kunde):
    header, benutzer, _ = neuer_kunde
    antwort = client.get("/api/auth/me", headers=header)
    assert antwort.status_code == 200
    assert antwort.json()["email"] == benutzer["email"]


def test_me_ohne_oder_mit_ungueltigem_token(client):
    assert client.get("/api/auth/me").status_code == 401
    assert (
        client.get("/api/auth/me", headers={"Authorization": "Bearer kaputt"}).status_code
        == 401
    )


def test_profil_bearbeiten(client, neuer_kunde):
    header, benutzer, _ = neuer_kunde
    antwort = client.put(
        "/api/auth/profil",
        headers=header,
        json={"vorname": "Grace", "nachname": "Hopper", "email": benutzer["email"], "telefon": ""},
    )
    assert antwort.status_code == 200
    assert antwort.json()["vorname"] == "Grace"
    assert antwort.json()["telefon"] is None


def test_profil_email_darf_nicht_vergeben_sein(client, neuer_kunde):
    header, _, _ = neuer_kunde
    antwort = client.put(
        "/api/auth/profil",
        headers=header,
        json={"vorname": "A", "nachname": "B", "email": "kunde@example.com"},
    )
    assert antwort.status_code == 409


def test_passwort_aendern(client, neuer_kunde):
    header, benutzer, passwort = neuer_kunde
    falsch = client.put(
        "/api/auth/passwort",
        headers=header,
        json={"aktuelles_passwort": "falsch", "neues_passwort": "nochgeheimer1"},
    )
    assert falsch.status_code == 400

    antwort = client.put(
        "/api/auth/passwort",
        headers=header,
        json={"aktuelles_passwort": passwort, "neues_passwort": "nochgeheimer1"},
    )
    assert antwort.status_code == 204
    login = client.post(
        "/api/auth/login", json={"email": benutzer["email"], "passwort": "nochgeheimer1"}
    )
    assert login.status_code == 200


def test_konto_ohne_bestellungen_wird_geloescht(client, neuer_kunde):
    header, benutzer, passwort = neuer_kunde
    assert client.delete("/api/auth/profil", headers=header).status_code == 204
    assert client.get("/api/auth/me", headers=header).status_code == 401
    login = client.post(
        "/api/auth/login", json={"email": benutzer["email"], "passwort": passwort}
    )
    assert login.status_code == 401


def test_konto_mit_bestellungen_wird_anonymisiert(client, neuer_kunde, admin, produkt_anlegen):
    header, benutzer, passwort = neuer_kunde
    produkt = produkt_anlegen()
    bestellung = client.post(
        "/api/bestellungen",
        headers=header,
        json={"positionen": [{"produkt_id": produkt["produkt_id"], "menge": 1}]},
    ).json()

    assert client.delete("/api/auth/profil", headers=header).status_code == 204

    # Kein Login mehr möglich, die Bestellung bleibt aber ohne Personenbezug erhalten
    login = client.post(
        "/api/auth/login", json={"email": benutzer["email"], "passwort": passwort}
    )
    assert login.status_code == 401
    erhalten = client.get(f"/api/bestellungen/{bestellung['bestellung_id']}", headers=admin)
    assert erhalten.status_code == 200
    assert benutzer["email"] not in erhalten.text
    assert erhalten.json()["kunde_name"] == "Gelöschter Benutzer"


def test_demo_konten_sind_geschuetzt(client, admin):
    assert client.delete("/api/auth/profil", headers=admin).status_code == 403
    antwort = client.put(
        "/api/auth/passwort",
        headers=admin,
        json={"aktuelles_passwort": "admin1234", "neues_passwort": "uebernommen1"},
    )
    assert antwort.status_code == 403


def test_rollen_der_demo_konten_sind_fest(client, admin):
    team = next(b for b in client.get("/api/benutzer", headers=admin).json() if b["email"] == "team@example.com")
    antwort = client.patch(
        f"/api/benutzer/{team['benutzer_id']}/rolle", headers=admin, json={"rolle": "Kunde"}
    )
    assert antwort.status_code == 403
