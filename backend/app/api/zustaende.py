"""
API-Routen für Zustände - CRUD-Endpunkte unter /zustaende.
"""

from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from dao.zustand_dao import ZustandDAO
from models.zustand import Zustand
from uuid import UUID

router = APIRouter(prefix="/zustaende", tags=["Zustände"])


@router.get("/")
def alle_zustaende_abrufen(limit: int = 50, offset: int = 0, db=Depends(get_db)):
    """Gibt alle Zustände alphabetisch sortiert zurück."""
    dao = ZustandDAO(db)
    return dao.get_alle(limit=limit, offset=offset)


@router.get("/bezeichnung/{bezeichnung}")
def zustand_nach_bezeichnung(bezeichnung: str, db=Depends(get_db)):
    """Gibt einen Zustand anhand der Bezeichnung zurück (z.B. 'Gut', 'Neuwertig')."""
    dao = ZustandDAO(db)
    zustand = dao.get_nach_bezeichnung(bezeichnung)
    if not zustand:
        raise HTTPException(status_code=404, detail="Zustand nicht gefunden")
    return zustand


@router.get("/{zustand_id}")
def zustand_abrufen(zustand_id: UUID, db=Depends(get_db)):
    """Gibt einen einzelnen Zustand anhand der UUID zurück."""
    dao = ZustandDAO(db)
    zustand = dao.get_nach_id(zustand_id)
    if not zustand:
        raise HTTPException(status_code=404, detail="Zustand nicht gefunden")
    return zustand


@router.post("/", status_code=201)
def zustand_erstellen(zustand: Zustand, db=Depends(get_db)):
    """Legt einen neuen Zustand an (z.B. 'Gut', 'Neuwertig', 'Stark getragen')."""
    dao = ZustandDAO(db)
    dao.erstellen(zustand)
    return zustand


@router.put("/{zustand_id}")
def zustand_aktualisieren(zustand_id: UUID, zustand: Zustand, db=Depends(get_db)):
    """Aktualisiert Bezeichnung und Beschreibung eines Zustands."""
    zustand.zustand_id = zustand_id  # die ID des aktualisierten Zustands bleibt gleich
    dao = ZustandDAO(db)
    dao.aktualisieren(zustand)
    return zustand


@router.delete("/{zustand_id}", status_code=204)
def zustand_loeschen(zustand_id: UUID, db=Depends(get_db)):
    """Löscht einen Zustand. Schlägt fehl, solange Produkte diesen Zustand referenzieren (ON DELETE RESTRICT)."""
    dao = ZustandDAO(db)
    dao.loeschen(zustand_id)
