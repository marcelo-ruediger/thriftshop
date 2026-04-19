"""
Authentifizierungs-Endpunkte - Registrierung und Login unter /auth.
"""

from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from app.core.sicherheit import (
    passwort_hashen,
    passwort_pruefen,
    token_erstellen,
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
        raise HTTPException(status_code=401, detail="Üngultige E-Mail oder Passwort")
    token = token_erstellen({"sub": str(benutzer.benutzer_id), "rolle": benutzer.rolle})
    return {"access_token": token, "token_type": "bearer"}
