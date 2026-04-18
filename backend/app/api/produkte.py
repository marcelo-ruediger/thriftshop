"""
API-Routen für Produkte - CRUD-Endpunkte unter /produkte.
"""

from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from dao.produkt_dao import ProduktDAO
from models.produkt import Produkt
from uuid import UUID

router = APIRouter(prefix="/produkte", tags=["Produkte"])


@router.get("/")
def alle_produkte_abrufen(
    limit: int = 50,
    offset: int = 0,
    db=Depends(get_db),
):
    """Gibt alle Produkte zurück (auch inaktive) - Admin-Dashboard."""
    dao = ProduktDAO(db)
    return dao.get_alle(limit=limit, offset=offset)


@router.get("/aktiv")
def aktive_produkte_abrufen(db=Depends(get_db)):
    """Gibt nur aktive Produkte zurück - Onlineshop."""
    dao = ProduktDAO(db)
    return dao.get_all_aktiven()


@router.get("/{produkt_id}")
def produkt_abrufen(produkt_id: UUID, db=Depends(get_db)):
    """Gibt ein einzelnes Produkt anhand der UUID zurück."""
    dao = ProduktDAO(db)
    produkt = dao.get_nach_id(produkt_id)
    if not produkt:
        raise HTTPException(status_code=404, detail="Produkt nicht gefunden")
    return produkt


@router.post("/", status_code=201)
def produkt_erstellen(produkt: Produkt, db=Depends(get_db)):
    """Legt ein neues Produkt an."""
    dao = ProduktDAO(db)
    dao.erstellen(produkt)
    return produkt


@router.put("/{produkt_id}")
def produkt_aktualisieren(produkt_id: UUID, produkt: Produkt, db=Depends(get_db)):
    """Aktualisiert ein bestehendes Produkt."""
    produkt.produkt_id = produkt_id
    dao = ProduktDAO(db)
    dao.aktualisieren(produkt)
    return produkt


@router.delete("/{produkt_id}", status_code=204)
def produkt_deaktivieren(produkt_id: UUID, db=Depends(get_db)):
    """Deaktiviert ein Produkt (Soft-Delete)."""
    dao = ProduktDAO(db)
    dao.deaktivieren(produkt_id)
