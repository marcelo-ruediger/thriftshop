from fastapi import FastAPI
from app.api import produkte
from app.api import benutzer
from app.api import bestellungen
from app.api import bestellposition
from app.api import kategorien
from app.api import zustaende

app = FastAPI(title="Thriftshop Köln API")

app.include_router(produkte.router)
app.include_router(benutzer.router)
app.include_router(bestellungen.router)
app.include_router(bestellposition.router)
app.include_router(kategorien.router)
app.include_router(zustaende.router)
