from abc import ABC, abstractmethod
from dataclasses import dataclass
from uuid import uuid4

@dataclass
class bestellung():
    id = uuid4
    