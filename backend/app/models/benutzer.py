from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass
class Benutzer:
    benutzer_id: UUID
    vorname: str
    nachname: str
    email: str
    passwort_hash: str
    telefon: str | None = None
    rolle: str = "Kunde"
    erstellt_am: datetime | None = None
    letzte_aenderung: datetime | None = None
    letzter_login: datetime | None = None

    @property
    def name(self) -> str:
        return f"{self.vorname} {self.nachname}".strip()
