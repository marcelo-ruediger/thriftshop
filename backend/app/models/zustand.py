from dataclasses import dataclass
from uuid import UUID


@dataclass
class Zustand:
    zustand_id: UUID
    bezeichnung: str
    beschreibung: str
