from uuid import UUID
from dataclasses import dataclass

@dataclass
class Zustand:
    zustand_id: UUID
    bezeichnung: str
    beschreibung: str

    