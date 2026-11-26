"""
Sicherheitsmodul - Passwort-Hashing (bcrypt), JWT-Tokenverwaltung und Rollenprüfung.
"""

from datetime import datetime, timedelta, timezone
from uuid import UUID

import bcrypt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from app.core.config import einstellungen
from app.core.datenbank import get_db
from app.dao.benutzer_dao import BenutzerDAO
from app.models import Benutzer

ALGORITHMUS = "HS256"

ROLLE_ADMIN = "Administrator"
ROLLE_MITARBEITER = "Mitarbeiter"
ROLLE_KUNDE = "Kunde"
PERSONAL = (ROLLE_ADMIN, ROLLE_MITARBEITER)


def passwort_hashen(klartext: str) -> str:
    """Gibt den bcrypt-Hash eines Klartextpassworts zurück."""
    return bcrypt.hashpw(klartext.encode(), bcrypt.gensalt()).decode()


def passwort_pruefen(klartext: str, passwort_hash: str) -> bool:
    """Vergleicht ein Klartextpasswort mit einem gespeicherten Hash."""
    try:
        return bcrypt.checkpw(klartext.encode(), passwort_hash.encode())
    except ValueError:
        return False


def token_erstellen(daten: dict) -> str:
    """Erstellt einen signierten JWT mit Ablaufzeit."""
    ablauf = datetime.now(timezone.utc) + timedelta(
        minutes=einstellungen.token_ablauf_minuten
    )
    return jwt.encode(
        {**daten, "exp": ablauf}, einstellungen.jwt_secret, algorithm=ALGORITHMUS
    )


def token_lesen(token: str) -> dict:
    """Dekodiert und validiert einen JWT. Wirft JWTError bei ungültigem Token."""
    return jwt.decode(token, einstellungen.jwt_secret, algorithms=[ALGORITHMUS])


bearer_schema = HTTPBearer(auto_error=False)


def aktueller_benutzer(
    zugang: HTTPAuthorizationCredentials | None = Depends(bearer_schema),
    db=Depends(get_db),
) -> Benutzer:
    """Liest den JWT aus dem Authorization-Header und gibt den Benutzer zurück."""
    fehler = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Nicht angemeldet oder Sitzung abgelaufen",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if zugang is None:
        raise fehler
    try:
        benutzer_id = UUID(token_lesen(zugang.credentials).get("sub", ""))
    except (JWTError, ValueError):
        raise fehler from None

    benutzer = BenutzerDAO(db).get_nach_id(benutzer_id)
    # Ein anonymisiertes (gelöschtes) Konto hat keinen Passwort-Hash mehr - seine
    # noch nicht abgelaufenen Tokens dürfen nicht weiter funktionieren.
    if benutzer is None or not benutzer.passwort_hash:
        raise fehler
    return benutzer


def erfordert_rolle(*rollen: str):
    """Gibt eine Dependency zurück, die eine der angegebenen Rollen voraussetzt."""

    def pruefe_rolle(benutzer: Benutzer = Depends(aktueller_benutzer)) -> Benutzer:
        if benutzer.rolle not in rollen:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Keine Berechtigung"
            )
        return benutzer

    return pruefe_rolle


erfordert_personal = erfordert_rolle(*PERSONAL)
erfordert_admin = erfordert_rolle(ROLLE_ADMIN)
