"""
Sicherheitsmodul - Passwort-Hashing (bcrypt) und JWT-Tokenverwaltung.
"""

from datetime import datetime, timedelta, timezone
import bcrypt
from jose import jwt
from app.core.datenbank import get_notwendige_env

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
