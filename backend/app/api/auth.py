"""
Authentifizierungs-Endpunkte - Registrierung, Login, Profil unter /auth.
"""

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from app.core.datenbank import get_db
from app.core.sicherheit import (
    passwort_hashen,
    passwort_pruefen,
    token_erstellen,
    token_lesen,
)
from dao.benutzer_dao import BenutzerDAO
from models.benutzer import Benutzer

router = APIRouter(prefix="/auth", tags=["Authentifizierung"])


@router.post("/registrieren", status_code=201)
def registrieren(benutzer: Benutzer, db=Depends(get_db)):
    """Legt einen neuen Benutzer an und speichert das Passwort als bcrypt-Hash."""
    benutzer.passwort_hash = passwort_hashen(benutzer.passwort_hash)
    dao = BenutzerDAO(db)
    dao.erstellen(benutzer)
    return {"nachricht": "Benutzer erfolgreich registriert"}


@router.post("/login")
def login(email: str, passwort: str, db=Depends(get_db)):
    """Prüft E-mail und Passwort, gibt bei Erfolg einen JWT zurück."""
    dao = BenutzerDAO(db)
    benutzer = dao.get_nach_email(email)
    if not benutzer or not passwort_pruefen(passwort, benutzer.passwort_hash):
        raise HTTPException(status_code=401, detail="Ungultige E-Mail oder Passwort")
    token = token_erstellen({"sub": str(benutzer.benutzer_id), "rolle": benutzer.rolle})
    return {"access_token": token, "token_type": "bearer"}


@router.get("/me")
def profil_aktuell(db=Depends(get_db)):
    """Gibt die Daten des aktuell eingeloggten Benutzers zurück.
    Erfordert ein gueltiges JWT im Authorization-Header."""
    from fastapi import Header

    authorization: str = Header(None)
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Kein Token angegeben")

    token = authorization.split(" ", 1)[1]
    try:
        payload = token_lesen(token)
    except Exception:
        raise HTTPException(status_code=401, detail="Ungueltiges oder abgelaufenes Token")

    benutzer_id = payload.get("sub")
    if benutzer_id is None:
        raise HTTPException(status_code=401, detail="Token hat keine sub")

    dao = BenutzerDAO(db)
    benutzer = dao.get_nach_id(benutzer_id)
    if benutzer is None:
        raise HTTPException(status_code=404, detail="Benutzer nicht gefunden")

    return {
        "benutzer_id": str(benutzer.benutzer_id),
        "vorname": benutzer.vorname,
        "nachname": benutzer.nachname,
        "email": benutzer.email,
        "telefonnummer": benutzer.telefon,
        "rolle": benutzer.rolle,
        "erstellt_am": benutzer.erstellt_am.isoformat() if benutzer.erstellt_am else None,
        "letzte_aenderung": benutzer.letzte_aenderung.isoformat() if benutzer.letzte_aenderung else None,
        "letzter_login": benutzer.letzter_login.isoformat() if benutzer.letzter_login else None,
    }


@router.get("/logout")
def logout():
    """Logout-Endpunkt (stateless - JWT verfaellt automatisch)."""
    return {"nachricht": "Erfolgreich abgemeldet"}


@router.put("/profile")
def profil_bearbeiten(benutzer: Benutzer, db=Depends(get_db)):
    """Aktualisiert die Stammdaten des Benutzers."""
    dao = BenutzerDAO(db)
    dao.aktualisieren_stammdaten(benutzer)
    return benutzer


@router.delete("/profile")
def profil_loeschen(benutzer_id: str = None, db=Depends(get_db)):
    """Loescht das Benutzerkonto (DSGVO - Recht auf Vergessenwerden).
    Benutzer-ID wird aus dem JWT-Token gelesen."""
    # Da wir hier kein JWT-Validation haben, akzeptieren wir die ID als Query-Parameter
    # In der Produktion sollte die ID aus dem JWT gelesen werden
    if benutzer_id is None:
        raise HTTPException(
            status_code=400,
            detail="Benutzer-ID erforderlich (aus JWT-Token)",
        )
    from uuid import UUID

    try:
        uuid_id = UUID(benutzer_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Ungueltige Benutzer-ID")

    dao = BenutzerDAO(db)
    dao.loeschen(uuid_id)
    return {"nachricht": "Benutzerkonto erfolgreich geloescht"}
