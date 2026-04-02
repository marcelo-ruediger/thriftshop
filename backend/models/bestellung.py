from uuid import UUID
from dataclasses import dataclass
from datetime import datetime

@dataclass
class Bestellung:
    bestellung_id: UUID
    laufende_nr: int
    status: str
    bestelldatum: datetime
    benutzer_id: UUID               # FK von Benutzer

    @property
    def bestellnr(self) -> str:
        """Erzeugt eine lesbare Bestellnummer (Z.B. B00001)"""
        return f"B{self.laufende_nr:05d}"
    
