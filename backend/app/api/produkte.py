"""
API-Routen für Produkte unter /produkte.

Der Katalog (aktive Produkte) ist öffentlich. Anlegen, Bearbeiten, Deaktivieren
und der Bild-Upload erfordern die Rolle Mitarbeiter oder Administrator.
"""

import sqlite3
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Response, UploadFile, status

from app.api.fehler import nicht_gefunden
from app.core.config import einstellungen
from app.core.datenbank import get_db, jetzt
from app.core.sicherheit import erfordert_personal
from app.dao.kategorie_dao import KategorieDAO
from app.dao.produkt_dao import ProduktDAO
from app.dao.zustand_dao import ZustandDAO
from app.models import Produkt
from app.schemas import BildAusgabe, ProduktAnfrage, ProduktAusgabe
from app.services.slug import slug_erzeugen

router = APIRouter(prefix="/produkte", tags=["Produkte"])

ERLAUBTE_BILDTYPEN = {"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}
MAX_BILDGROESSE = 5 * 1024 * 1024  # 5 MB


def _eindeutiger_slug(dao: ProduktDAO, bezeichnung: str, produkt_id: UUID | None = None) -> str:
    """Hängt bei Bedarf eine Nummer an, damit der Slug eindeutig bleibt."""
    basis = slug_erzeugen(bezeichnung)
    slug, zaehler = basis, 2
    while dao.slug_existiert(slug, ausser_produkt_id=produkt_id):
        slug = f"{basis}-{zaehler}"
        zaehler += 1
    return slug


def _referenzen_pruefen(db: sqlite3.Connection, anfrage: ProduktAnfrage) -> None:
    if not KategorieDAO(db).get_nach_id(anfrage.kategorie_id):
        raise HTTPException(422, detail="Unbekannte Kategorie")
    if not ZustandDAO(db).get_nach_id(anfrage.zustand_id):
        raise HTTPException(422, detail="Unbekannter Zustand")


@router.get("", response_model=list[ProduktAusgabe])
def aktive_produkte_abrufen(db=Depends(get_db)):
    """Gibt alle aktiven Produkte zurück - der öffentliche Katalog."""
    return ProduktDAO(db).get_alle_aktiven()


@router.get("/alle", response_model=list[ProduktAusgabe])
def alle_produkte_abrufen(_personal=Depends(erfordert_personal), db=Depends(get_db)):
    """Gibt alle Produkte zurück (auch deaktivierte) - für die Produktverwaltung."""
    return ProduktDAO(db).get_alle()


@router.post("/bild", response_model=BildAusgabe, status_code=201)
async def bild_hochladen(datei: UploadFile, _personal=Depends(erfordert_personal)):
    """Speichert ein Produktbild und gibt den Dateinamen für das Feld `bildpfad` zurück."""
    endung = ERLAUBTE_BILDTYPEN.get(datei.content_type or "")
    if endung is None:
        raise HTTPException(
            status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Erlaubt sind Bilder im Format JPEG, PNG oder WebP",
        )
    inhalt = await datei.read(MAX_BILDGROESSE + 1)
    if len(inhalt) > MAX_BILDGROESSE:
        raise HTTPException(
            status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, detail="Das Bild ist größer als 5 MB"
        )
    # Der Dateiname wird serverseitig vergeben - der Name vom Client wird nie verwendet
    dateiname = f"upload_{uuid4().hex}{endung}"
    einstellungen.upload_verzeichnis.mkdir(parents=True, exist_ok=True)
    (einstellungen.upload_verzeichnis / dateiname).write_bytes(inhalt)
    return BildAusgabe(bildpfad=dateiname)


@router.get("/slug/{slug}", response_model=ProduktAusgabe)
def produkt_nach_slug(slug: str, db=Depends(get_db)):
    """Gibt ein aktives Produkt anhand seines URL-Slugs zurück."""
    produkt = ProduktDAO(db).get_nach_slug(slug)
    if not produkt or not produkt.produkt_aktiv:
        raise nicht_gefunden("Produkt")
    return produkt


@router.get("/{produkt_id}", response_model=ProduktAusgabe)
def produkt_abrufen(produkt_id: UUID, db=Depends(get_db)):
    """Gibt ein aktives Produkt anhand der UUID zurück."""
    produkt = ProduktDAO(db).get_nach_id(produkt_id)
    if not produkt or not produkt.produkt_aktiv:
        raise nicht_gefunden("Produkt")
    return produkt


@router.post("", response_model=ProduktAusgabe, status_code=201)
def produkt_erstellen(
    anfrage: ProduktAnfrage, _personal=Depends(erfordert_personal), db=Depends(get_db)
):
    """Legt ein neues Produkt an. ID, Produktnummer und Slug vergibt der Server."""
    _referenzen_pruefen(db, anfrage)
    dao = ProduktDAO(db)
    produkt = Produkt(
        produkt_id=uuid4(),
        laufende_nr=0,  # vergibt die Datenbank
        slug=_eindeutiger_slug(dao, anfrage.bezeichnung),
        erstellungsdatum=jetzt(),
        **anfrage.model_dump(),
    )
    dao.erstellen(produkt)
    db.commit()
    return dao.get_nach_id(produkt.produkt_id)


@router.put("/{produkt_id}", response_model=ProduktAusgabe)
def produkt_aktualisieren(
    produkt_id: UUID,
    anfrage: ProduktAnfrage,
    _personal=Depends(erfordert_personal),
    db=Depends(get_db),
):
    """Aktualisiert ein bestehendes Produkt."""
    dao = ProduktDAO(db)
    produkt = dao.get_nach_id(produkt_id)
    if not produkt:
        raise nicht_gefunden("Produkt")
    _referenzen_pruefen(db, anfrage)

    if anfrage.bezeichnung != produkt.bezeichnung:
        produkt.slug = _eindeutiger_slug(dao, anfrage.bezeichnung, produkt_id)
    for feld, wert in anfrage.model_dump().items():
        setattr(produkt, feld, wert)
    dao.aktualisieren(produkt)
    db.commit()
    return dao.get_nach_id(produkt_id)


@router.delete("/{produkt_id}", status_code=204)
def produkt_deaktivieren(
    produkt_id: UUID, _personal=Depends(erfordert_personal), db=Depends(get_db)
):
    """Deaktiviert ein Produkt (Soft-Delete) - es verschwindet aus dem Katalog,
    bleibt aber für bestehende Bestellungen erhalten."""
    if not ProduktDAO(db).deaktivieren(produkt_id):
        raise nicht_gefunden("Produkt")
    db.commit()
    return Response(status_code=204)
