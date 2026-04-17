from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from dao.bestellung_dao import BestellungDAO
from dao.bestellposition_dao import BestellpositionDAO
from models.bestellung import Bestellung
from models.bestellposition import Bestellposition
from uuid import UUID

router = APIRouter(prefix="/bestellungen", tags=["Bestellungen"])

@router.get("/")
def alle_bestellungen_abrufen(limit:int = 50, offset:int = 0, db = Depends(get_db)):
    """Gibt alle Bestellungen paginiert zurück - Admin-Dashboard."""
    dao = BestellungDAO(db)
    return dao.get_alle(limit=limit, offset=offset)

@router.get("/{bestellung_id}")
def bestellung_abrufen(bestellung_id:UUID, db = Depends(get_db)):
    """Gibt eine einzelne Bestellung anhand der UUID zurück."""
    dao = BestellungDAO(db)
    bestellung = dao.get_nach_id(bestellung_id)
    if not bestellung:
        raise HTTPException(status_code=404, detail="Bestellung nicht gefunden")
    return bestellung

@router.get("/benutzer/{benutzer_id}")
def bestellungen_nach_benutzer(benutzer_id:UUID, db = Depends(get_db)):
    """Gibt die Bestellhistorie eines Kunden zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_benutzer(benutzer_id)

@router.get("/status/{status}")
def bestellungen_nach_status(status:str, db = Depends(get_db)):
    """Gibt alle Bestellungen mit einem bestimmten Status zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_status(status)

@router.post("/", status_code=201)
def bestellung_erstellen(
    bestellung: Bestellung,
    positionen: list[Bestellposition],
    db = Depends(get_db)
):
    """Legt eine neue Bestellung mit allen Positionen an (atomar)."""
    bestell_dao = BestellungDAO(db)
    position_dao = BestellpositionDAO(db)
    bestell_dao.erstellen(bestellung)
    position_dao.erstellen_mehrere(positionen)
    return bestellung

@router.patch("/{bestellung_id}/status")
def status_aktualisieren(bestellung_id:UUID, neuer_status:str, db = Depends(get_db)):
    """Ändert den Status einer Bestellung."""
    dao = BestellungDAO(db)
    dao.status_aktualisieren(bestellung_id, neuer_status)
    return {"bestellung_id": str(bestellung_id), "status": neuer_status}

