"""
Sicherheitsmodul - Passwort-Hashing (bcrypt) und JWT-Tokenverwaltung.
"""

from datetime import datetime, timedelta, timezone
from uuid import UUID
import bcrypt
from jose import jwt, JWTError
from app.core.datenbank import get_notwendige_env
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from app.core.datenbank import get_db
from dao.benutzer_dao import BenutzerDAO

ALGORITHMUS = "HS256"
TOKEN_ABLAUF_MINUTEN = 60 * 24  # 24 Stunden


def passwort_hashen(klartext: str) -> str:
    """Gibt den bcrypt-Hash eines Klartextpassworts zurück."""
    return bcrypt.hashpw(klartext.encode(), bcrypt.gensalt()).decode()


def passwort_pruefen(klartext: str, passwort_hash: str) -> bool:
    """Vergleicht ein Klartextpasswort mit einem gespeicherten Hash."""
    return bcrypt.checkpw(klartext.encode(), passwort_hash.encode())


def token_erstellen(daten: dict) -> str:
    """Erstellt einen signierten JWT mit Ablaufzeit."""
    ablauf = datetime.now(timezone.utc) + timedelta(minutes=TOKEN_ABLAUF_MINUTEN)
    payload = {**daten, "exp": ablauf}
    geheimnis = get_notwendige_env("JWT_SECRET")
    return jwt.encode(payload, geheimnis, algorithm=ALGORITHMUS)


def token_lesen(token: str) -> dict:
    """Dekodiert und validiert einen JWT. Wirft JWTError bei ungültigem Token."""
    geheimnis = get_notwendige_env("JWT_SECRET")
    return jwt.decode(token, geheimnis, algorithms=[ALGORITHMUS])


oauth2_schema = OAuth2PasswordBearer(tokenUrl="/auth/login")


def aktueller_benutzer(token: str = Depends(oauth2_schema), db=Depends(get_db)):
    """Liest den JWT aus dem Authorization-Header und gibt den Benutzer zurück."""
    try:
        payload = token_lesen(token)
        benutzer_id: str | None = payload.get("sub")
        if benutzer_id is None:
            raise HTTPException(status_code=401, detail="Ungültiger Token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Ungültiger Token")

    dao = BenutzerDAO(db)
    benutzer = dao.get_nach_id(UUID(benutzer_id))
    if benutzer is None:
        raise HTTPException(status_code=401, detail="Benutzer nicht gefunden")
    return benutzer


def erfordert_rolle(*rollen: str):
    """Gibt eine Depends-Funktion zurück, die eine bestimmte Rolle voraussetzt."""

    def pruefe_role(benutzer=Depends(aktueller_benutzer)):
        if benutzer.rolle not in rollen:
            raise HTTPException(status_code=403, detail="Keine Berechtigung")
        return benutzer

    return pruefe_role
