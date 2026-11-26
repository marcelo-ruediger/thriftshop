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


def test_konto_mit_bestellungen_wird_anonymisiert(
    client, neuer_kunde, admin, produkt_anlegen, ohne_demo_modus
):
    header, benutzer, passwort = neuer_kunde
    produkt = produkt_anlegen(lagerbestand=1)
    bestellung = client.post(
        "/api/bestellungen",
        headers=header,
        json={
            "positionen": [{"produkt_id": produkt["produkt_id"], "menge": 1}],
            "anmerkung": "Bitte anrufen: 0171 2345678, Erika Mustermann",
        },
    ).json()

    assert client.delete("/api/auth/profil", headers=header).status_code == 204

    # Kein Login mehr möglich - und auch das alte Token ist sofort wertlos
    login = client.post(
        "/api/auth/login", json={"email": benutzer["email"], "passwort": passwort}
    )
    assert login.status_code == 401
    assert client.get("/api/auth/me", headers=header).status_code == 401
    assert client.get("/api/bestellungen/meine", headers=header).status_code == 401

    # Die Bestellung bleibt ohne Personenbezug erhalten, wurde aber storniert
    erhalten = client.get(f"/api/bestellungen/{bestellung['bestellung_id']}", headers=admin)
    assert erhalten.status_code == 200
    assert benutzer["email"] not in erhalten.text
    assert "Mustermann" not in erhalten.text
    assert erhalten.json()["kunde_name"] == "Gelöschter Benutzer"
    assert erhalten.json()["anmerkung"] is None
    assert erhalten.json()["status"] == "Storniert"
    alle = client.get("/api/produkte/alle", headers=admin).json()
    assert next(p for p in alle if p["produkt_id"] == produkt["produkt_id"])["lagerbestand"] == 1


def test_der_letzte_administrator_kann_sein_konto_nicht_loeschen(
    client, admin, neuer_kunde, ohne_demo_modus
):
    header, benutzer, _ = neuer_kunde
    assert client.delete("/api/auth/profil", headers=admin).status_code == 409

    # Mit einem zweiten Administrator geht es
    client.patch(
        f"/api/benutzer/{benutzer['benutzer_id']}/rolle",
        headers=admin,
        json={"rolle": "Administrator"},
    )
    assert client.delete("/api/auth/profil", headers=header).status_code == 204


def test_passwort_ueber_72_bytes_wird_abgelehnt(client):
    # 40 Umlaute sind 40 Zeichen, aber 80 Bytes - mehr als bcrypt verarbeitet
    antwort = client.post("/api/auth/registrieren", json=_registrierung(passwort="ä" * 40))
    assert antwort.status_code == 422
    assert client.post(
        "/api/auth/registrieren", json=_registrierung(passwort="ä" * 36)
    ).status_code == 201


def test_login_unabhaengig_von_gross_und_kleinschreibung(client):
    daten = _registrierung(email=f"Jörg-{uuid.uuid4().hex[:8]}@Example.com")
    assert client.post("/api/auth/registrieren", json=daten).status_code == 201
    for schreibweise in (daten["email"], daten["email"].upper(), daten["email"].lower()):
        login = client.post(
            "/api/auth/login", json={"email": schreibweise, "passwort": daten["passwort"]}
        )
        assert login.status_code == 200, schreibweise


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


def test_demo_admin_sieht_fremde_kontaktdaten_nur_maskiert(client, admin, neuer_kunde, produkt_anlegen):
    header, benutzer, _ = neuer_kunde
    produkt = produkt_anlegen()
    bestellung = client.post(
        "/api/bestellungen",
        headers=header,
        json={
            "positionen": [{"produkt_id": produkt["produkt_id"], "menge": 1}],
            "anmerkung": "Meine Nummer: 0171 2345678",
        },
    ).json()

    liste = client.get("/api/benutzer", headers=admin)
    assert benutzer["email"] not in liste.text
    assert "0221 123456" not in liste.text
    eintrag = next(b for b in liste.json() if b["benutzer_id"] == benutzer["benutzer_id"])
    assert eintrag == {**eintrag, "vorname": "Test", "nachname": "K.", "telefon": None}
    # Die Demo-Konten selbst bleiben lesbar
    assert any(b["email"] == "kunde@example.com" for b in liste.json())

    for pfad in ("/api/bestellungen", f"/api/bestellungen/{bestellung['bestellung_id']}"):
        antwort = client.get(pfad, headers=admin)
        assert benutzer["email"] not in antwort.text
        assert "0171" not in antwort.text
        assert "Test K." in antwort.text

    # Die Kundin selbst sieht ihre Bestellung unverändert
    eigene = client.get(f"/api/bestellungen/{bestellung['bestellung_id']}", headers=header).json()
    assert eigene["anmerkung"] == "Meine Nummer: 0171 2345678"
    assert eigene["kunde_email"] == benutzer["email"]


def test_ohne_demo_modus_sieht_der_admin_die_echten_daten(
    client, admin, neuer_kunde, ohne_demo_modus
):
    _, benutzer, _ = neuer_kunde
    liste = client.get("/api/benutzer", headers=admin).json()
    eintrag = next(b for b in liste if b["benutzer_id"] == benutzer["benutzer_id"])
    assert eintrag["email"] == benutzer["email"]
    assert eintrag["telefon"] == "0221 123456"
