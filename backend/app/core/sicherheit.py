"""
Sicherheitsmodul - Passwort-Hashing (bcrypt) und JWT-Tokenverwaltung.
"""

from datetime import datetime, timedelta, timezone
from jose import jwt
from passlib.context import CryptContext
from app.core.datenbank import get_notwendige_env

ALGORITHMUS = "HS256"
TOKEN_ABLAUF_MINUTEN = 60 * 24  # 24 Stunden

passwort_kontext = CryptContext(schemes=["bcrypt"], deprecated="auto")


def passwort_hashen(klartext: str) -> str:
    """Gibt den bcrypt-Hash eines Klartextpassworts zurück."""
    return passwort_kontext.hash(klartext)


def passwort_pruefen(klartext: str, passwort_hash: str) -> bool:
    """Vergleicht ein Klartextpasswort mit einem gespeicherten Hash."""
    return passwort_kontext.verify(klartext, passwort_hash)


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
