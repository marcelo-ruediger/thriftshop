from uuid import UUID
from dataclasses import dataclass
from datetime import datetime


@dataclass
class Benutzer:
    benutzer_id: UUID
    vorname: str
    nachname: str
    email: str
    telefon: str
    passwort_hash: str
    rolle: str = "Kunde"
    erstellt_am: datetime | None = None
    letzte_aenderung: datetime | None = None
    letzter_login: datetime | None = None
