"""
API-Routen für Kategorien unter /kategorien. Lesen ist öffentlich, Schreiben erfordert Personal.
"""

from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, Response

from app.api.fehler import nicht_gefunden
from app.core.datenbank import get_db
from app.core.sicherheit import erfordert_personal
from app.dao.kategorie_dao import KategorieDAO
from app.models import Kategorie
from app.schemas import KategorieAnfrage, KategorieAusgabe
from app.services.slug import slug_erzeugen

router = APIRouter(prefix="/kategorien", tags=["Kategorien"])


@router.get("", response_model=list[KategorieAusgabe])
def alle_kategorien_abrufen(db=Depends(get_db)):
    """Gibt alle Kategorien alphabetisch sortiert zurück."""
    return KategorieDAO(db).get_alle()


@router.post("", response_model=KategorieAusgabe, status_code=201)
def kategorie_erstellen(
    anfrage: KategorieAnfrage, _personal=Depends(erfordert_personal), db=Depends(get_db)
):
    """Legt eine neue Kategorie an. Der Slug wird aus der Bezeichnung erzeugt."""
    kategorie = Kategorie(
        kategorie_id=uuid4(),
        bezeichnung=anfrage.bezeichnung,
        slug=slug_erzeugen(anfrage.bezeichnung),
        kategorie_rabatt=anfrage.kategorie_rabatt,
        steuersatz=anfrage.steuersatz,
    )
    KategorieDAO(db).erstellen(kategorie)
    return kategorie


@router.put("/{kategorie_id}", response_model=KategorieAusgabe)
def kategorie_aktualisieren(
    kategorie_id: UUID,
    anfrage: KategorieAnfrage,
    _personal=Depends(erfordert_personal),
    db=Depends(get_db),
):
    """Aktualisiert Bezeichnung, Rabatt und Steuersatz einer Kategorie."""
    kategorie = Kategorie(
        kategorie_id=kategorie_id,
        bezeichnung=anfrage.bezeichnung,
        slug=slug_erzeugen(anfrage.bezeichnung),
        kategorie_rabatt=anfrage.kategorie_rabatt,
        steuersatz=anfrage.steuersatz,
    )
    if not KategorieDAO(db).aktualisieren(kategorie):
        raise nicht_gefunden("Kategorie")
    return kategorie


@router.delete("/{kategorie_id}", status_code=204)
def kategorie_loeschen(
    kategorie_id: UUID, _personal=Depends(erfordert_personal), db=Depends(get_db)
):
    """Löscht eine Kategorie. Antwortet mit 409, solange ihr Produkte zugeordnet sind."""
    if not KategorieDAO(db).loeschen(kategorie_id):
        raise nicht_gefunden("Kategorie")
    return Response(status_code=204)
