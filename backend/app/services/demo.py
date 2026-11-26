"""
Regeln für den Demo-Modus (DEMO_MODUS=true).

Die Demo-Konten haben öffentlich bekannte Passwörter - auch das Administrator-Konto.
Deshalb gilt im Demo-Modus:
- Die Demo-Konten selbst bleiben unverändert (Passwort, E-Mail, Rolle, Löschung),
  damit sie für alle Besucher nutzbar bleiben.
- Wer mit einem Demo-Konto in der Verwaltung arbeitet, sieht die Kontaktdaten anderer
  Besucher nur unkenntlich gemacht.
"""

from fastapi import HTTPException, status

from app.core.config import einstellungen
from app.models import Benutzer

DEMO_EMAILS = {
    "admin@example.com",
    "team@example.com",
    "kunde@example.com",
    "jonas@example.com",
}
AUSGEBLENDET = "(im Demo-Modus ausgeblendet)"


def ist_demo_konto(email: str) -> bool:
    return einstellungen.demo_modus and email.lower() in DEMO_EMAILS


def demo_konto_schuetzen(benutzer: Benutzer, nachricht: str) -> None:
    """Bricht mit 403 ab, wenn ein Demo-Konto verändert werden soll."""
    if ist_demo_konto(benutzer.email):
        raise HTTPException(status.HTTP_403_FORBIDDEN, detail=nachricht)


def verbirgt_daten(betrachter: Benutzer, email_des_betroffenen: str | None) -> bool:
    """Darf der Betrachter die Kontaktdaten dieser Person nur maskiert sehen?"""
    return (
        ist_demo_konto(betrachter.email)
        and email_des_betroffenen is not None
        and not ist_demo_konto(email_des_betroffenen)
    )


def email_maskieren(email: str) -> str:
    return f"{email[:1]}•••@•••"


def name_kuerzen(name: str) -> str:
    """'Erika Mustermann' -> 'Erika M.'"""
    teile = name.split()
    return f"{teile[0]} {teile[-1][0]}." if len(teile) > 1 else name
