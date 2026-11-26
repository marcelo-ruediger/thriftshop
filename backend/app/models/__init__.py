"""Domänenmodelle - schlanke Dataclasses, die je eine Tabellenzeile abbilden."""

from .benutzer import Benutzer
from .bestellposition import Bestellposition
from .bestellung import Bestellung
from .kategorie import Kategorie
from .produkt import Produkt
from .zustand import Zustand

__all__ = [
    "Benutzer",
    "Bestellposition",
    "Bestellung",
    "Kategorie",
    "Produkt",
    "Zustand",
]
