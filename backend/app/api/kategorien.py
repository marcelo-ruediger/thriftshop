from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from dao.kategorie_dao import KategorieDAO
from models.kategorie import Kategorie
from uuid import UUID

router = APIRouter(prefix="/kategorien", tags=["Kategorien"])


@router.get("/")
def alle_kategorien_abrufen(limit: int = 50, offset: int = 0, db=Depends(get_db)):
    """Gibt alle Kategorien alphabetisch sortiert zurück."""
    dao = KategorieDAO(db)
    return dao.get_alle(limit=limit, offset=offset)


@router.get("/slug/{slug}")
def kategorie_nach_slug(slug: str, db=Depends(get_db)):
    """Gibt eine Kategorie anhand des SEO-Slugs zurück."""
    dao = KategorieDAO(db)
    kategorie = dao.get_nach_slug(slug)
    if not kategorie:
        raise HTTPException(status_code=404, detail="Kategorie nicht gefunden")
    return kategorie


@router.get("/{kategorie_id}")
def kategorie_abrufen(kategorie_id: UUID, db=Depends(get_db)):
    """Gibt eine einzelne Kategorie anhand der UUID zurück."""
    dao = KategorieDAO(db)
    kategorie = dao.get_nach_id(kategorie_id)
    if not kategorie:
        raise HTTPException(status_code=404, detail="Kategorie nicht gefunden")
    return kategorie


@router.post("/", status_code=201)
def kategorie_erstellen(kategorie: Kategorie, db=Depends(get_db)):
    """Legt eine neue Kategorie an."""
    dao = KategorieDAO(db)
    dao.erstellen(kategorie)
    return kategorie


@router.put("/{kategorie_id}")
def kategorie_aktualisieren(
    kategorie_id: UUID, kategorie: Kategorie, db=Depends(get_db)
):
    """Aktualisiert eine bestehende Kategorie (Bezeichnung, Slug, Rabatt, Steuersatz)."""
    kategorie.kategorie_id = kategorie_id
    dao = KategorieDAO(db)
    dao.aktualisieren(kategorie)
    return kategorie


@router.delete("/{kategorie_id}", status_code=204)
def kategorie_loeschen(kategorie_id: UUID, db=Depends(get_db)):
    """Löscht eine Kategorie. Schlägt fehl, solange Produkte dieser Kategorie zugeordnet sind (ON DELETE RESTRICT)."""
    dao = KategorieDAO(db)
    dao.loeschen(kategorie_id)
