from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from dao.bestellposition_dao import BestellpositionDAO
from uuid import UUID

router = APIRouter(prefix="/bestellpositionen", tags=["Bestellpositionen"])


@router.get("/bestellung/{bestellung_id}")
def positionen_nach_bestellung(bestellung_id: UUID, db=Depends(get_db)):
    """Gibt alle Positionen einer Bestellung zurück."""
    dao = BestellpositionDAO(db)
    return dao.get_nach_bestellung(bestellung_id)


@router.get("/produkt/{produkt_id}")
def positionen_nach_produkt(produkt_id: UUID, db=Depends(get_db)):
    """Gibt alle Positionen zu einem Produkt zurück - Admin-Auswertung."""
    dao = BestellpositionDAO(db)
    return dao.get_nach_produkt(produkt_id)


@router.get("/{bestellposition_id}")
def bestellposition_abrufen(bestellposition_id: UUID, db=Depends(get_db)):
    """Gibt eine einzelne Bestellposition anhand der UUID zurück."""
    dao = BestellpositionDAO(db)
    position = dao.get_nach_id(bestellposition_id)
    if not position:
        raise HTTPException(status_code=404, detail="Bestellposition nicht gefunden")
    return position
