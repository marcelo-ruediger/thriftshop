"""
API-Routen für Bestellungen - CRUD und Statusverwaltung unter /bestellungen.
"""

from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from app.core.sicherheit import aktueller_benutzer, erfordert_rolle
from dao.bestellung_dao import BestellungDAO
from dao.bestellposition_dao import BestellpositionDAO
from models.bestellung import Bestellung
from models.bestellposition import Bestellposition
from uuid import UUID, uuid4
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field
from typing import List

router = APIRouter(prefix="/bestellungen", tags=["Bestellungen"])


# Pydantic-Modelle für Frontend-Anfrage-Validierung
class BestellPositionCreate(BaseModel):
    """Anforderungsmodell für eine einzelne Bestellposition vom Frontend."""
    produkt_id: UUID = Field(..., description="ID des Produkts")
    menge: int = Field(..., ge=1, description="Bestellte Menge")
    preis: Decimal = Field(..., gt=0, description="Einzelpreis vom Produkt")


class BestellungCreateRequest(BaseModel):
    """Anforderungsmodell zum Erstellen einer neuen Bestellung vom Frontend."""
    bestellpositionen: List[BestellPositionCreate] = Field(
        ..., min_length=1, description="Liste der Bestellpositionen"
    )
    gesamtpreis: Decimal = Field(..., gt=0, description="Gesamtpreis der Bestellung")


@router.get("/meine-bestellungen")
def meine_bestellungen(benutzer=Depends(aktueller_benutzer), db=Depends(get_db)):
    """Gibt alle Bestellungen des eingeloggten Kunden zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_benutzer(benutzer.benutzer_id)


@router.patch("/{bestellung_id}/stornieren")
def bestellung_stornieren(
    bestellung_id: UUID,
    benutzer=Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Kunde storniert seine eigene Bestellung - nur wenn Status 'Offen'."""
    dao = BestellungDAO(db)
    bestellung = dao.get_nach_id(bestellung_id)

    if not bestellung:
        raise HTTPException(status_code=404, detail="Bestellung nicht gefunden")

    # Sicherheitsprüfung: Bestellung gehört dem eingeloggten Benutzer?
    if bestellung.benutzer_id != benutzer.benutzer_id:
        raise HTTPException(status_code=403, detail="Keine Berechtigung")

    # Nur "Offen" kann storniert werden
    if bestellung.status != "Offen":
        raise HTTPException(
            status_code=422,
            detail=f"Bestellung mit Status '{bestellung.status}' kann nicht storniert werden",
        )

    dao.status_aktualisieren(bestellung_id, "Storniert")
    return {"bestellung_id": str(bestellung_id), "status": "Storniert"}


@router.get("/")
def alle_bestellungen_abrufen(
    limit: int = 50,
    offset: int = 0,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Gibt alle Bestellungen paginiert zurück - Admin-Dashboard."""
    dao = BestellungDAO(db)
    return dao.get_alle(limit=limit, offset=offset)


@router.get("/benutzer/{benutzer_id}")
def bestellungen_nach_benutzer(
    benutzer_id: UUID,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Gibt die Bestellhistorie eines Kunden zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_benutzer(benutzer_id)


@router.get("/status/{status}")
def bestellungen_nach_status(
    status: str,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Gibt alle Bestellungen mit einem bestimmten Status zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_status(status)


@router.get("/{bestellung_id}")
def bestellung_abrufen(
    bestellung_id: UUID, benutzer=Depends(aktueller_benutzer), db=Depends(get_db)
):
    """Gibt eine einzelne Bestellung anhand der UUID zurück."""
    dao = BestellungDAO(db)
    bestellung = dao.get_nach_id(bestellung_id)
    if not bestellung:
        raise HTTPException(status_code=404, detail="Bestellung nicht gefunden")
    return bestellung


@router.post("/", status_code=201)
def bestellung_erstellen(
    request: BestellungCreateRequest,
    benutzer=Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Legt eine neue Bestellung mit allen Positionen an (atomar).
    
    Akzeptiert Frontend-Payload mit bestellpositionen und gesamtpreis.
    Gibt die erstellte Bestellung mit bestellung_id und bestellnummer zurück.
    """
    bestell_dao = BestellungDAO(db)
    position_dao = BestellpositionDAO(db)
    
    try:
        # Transaktion starten
        cursor = db.cursor()
        
        # 1. Neue Bestellung erstellen (Backend generiert alle Felder)
        new_bestellung_id = uuid4()
        # Nächste laufende_nr ermitteln
        cursor.execute("SELECT MAX(laufende_nr) as max_nr FROM bestellung")
        row = cursor.fetchone()
        next_nr = (row[0] or 0) + 1
        
        cursor.execute(
            """
            INSERT INTO bestellung (
                bestellung_id, laufende_nr, bestelldatum, status, benutzer_id
            ) VALUES (%s, %s, %s, %s, %s)
            """,
            (
                str(new_bestellung_id),
                next_nr,
                datetime.now(),
                "Offen",
                str(benutzer.benutzer_id),
            ),
        )
        
        # 2. Bestellpositionen erstellen
        for position in request.bestellpositionen:
            position_id = uuid4()
            cursor.execute(
                """
                INSERT INTO bestellposition(
                    bestellposition_id, menge, einzelpreis_gebucht, rabatt_angewendet, 
                    steuersatz_gebucht, bestellung_id, produkt_id
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    str(position_id),
                    position.menge,
                    float(position.preis),
                    0,  # rabatt_angewendet
                    19,  # steuersatz_gebucht (19% deutsche MwSt)
                    str(new_bestellung_id),
                    str(position.produkt_id),
                ),
            )
        
        # Transaktion committen
        db.commit()
        
        # 3. Response zurückgeben
        return {
            "bestellung_id": str(new_bestellung_id),
            "laufende_nr": next_nr,
            "bestellnummer": f"B{next_nr:05d}",
            "status": "Offen",
            "gesamtpreis": float(request.gesamtpreis),
            "message": "Bestellung erfolgreich erstellt",
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Bestellung konnte nicht erstellt werden: {str(e)}")
    finally:
        if 'cursor' in locals():
            cursor.close()


ERLAUBTE_UEBERGAENGE = {
    "Offen": ["In Bearbeitung", "Storniert"],
    "In Bearbeitung": ["Abgeschlossen", "Storniert"],
    "Abgeschlossen": [],
    "Storniert": ["Erstattet"],
    "Erstattet": [],
}


@router.patch("/{bestellung_id}/status")
def status_aktualisieren(
    bestellung_id: UUID,
    neuer_status: str,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Ändert den Status einer Bestellung."""
    dao = BestellungDAO(db)
    bestellung = dao.get_nach_id(bestellung_id)
    if not bestellung:
        raise HTTPException(status_code=404, detail="Bestellung nicht gefunden")

    erlaubt = ERLAUBTE_UEBERGAENGE.get(bestellung.status, [])
    if neuer_status not in erlaubt:
        raise HTTPException(
            status_code=422,
            detail=f"Übergang von '{bestellung.status}' nach '{neuer_status}' nicht erlaubt",
        )

    dao.status_aktualisieren(bestellung_id, neuer_status)
    return {"bestellung_id": str(bestellung_id), "status": neuer_status}
