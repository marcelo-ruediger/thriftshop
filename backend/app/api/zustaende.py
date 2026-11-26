"""
API-Routen für Zustände unter /zustaende. Lesen ist öffentlich, Schreiben erfordert Personal.
"""

from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, Response

from app.api.fehler import nicht_gefunden
from app.core.datenbank import get_db
from app.core.sicherheit import erfordert_personal
from app.dao.zustand_dao import ZustandDAO
from app.models import Zustand
from app.schemas import ZustandAnfrage, ZustandAusgabe

router = APIRouter(prefix="/zustaende", tags=["Zustände"])


@router.get("", response_model=list[ZustandAusgabe])
def alle_zustaende_abrufen(db=Depends(get_db)):
    """Gibt alle Zustände zurück (z.B. „Neu mit Etikett“, „Sehr gut“)."""
    return ZustandDAO(db).get_alle()


@router.post("", response_model=ZustandAusgabe, status_code=201)
def zustand_erstellen(
    anfrage: ZustandAnfrage, _personal=Depends(erfordert_personal), db=Depends(get_db)
):
    zustand = Zustand(uuid4(), anfrage.bezeichnung, anfrage.beschreibung)
    ZustandDAO(db).erstellen(zustand)
    return zustand


@router.put("/{zustand_id}", response_model=ZustandAusgabe)
def zustand_aktualisieren(
    zustand_id: UUID,
    anfrage: ZustandAnfrage,
    _personal=Depends(erfordert_personal),
    db=Depends(get_db),
):
    zustand = Zustand(zustand_id, anfrage.bezeichnung, anfrage.beschreibung)
    if not ZustandDAO(db).aktualisieren(zustand):
        raise nicht_gefunden("Zustand")
    return zustand


@router.delete("/{zustand_id}", status_code=204)
def zustand_loeschen(
    zustand_id: UUID, _personal=Depends(erfordert_personal), db=Depends(get_db)
):
    """Löscht einen Zustand. Antwortet mit 409, solange Produkte ihn verwenden."""
    if not ZustandDAO(db).loeschen(zustand_id):
        raise nicht_gefunden("Zustand")
    return Response(status_code=204)
