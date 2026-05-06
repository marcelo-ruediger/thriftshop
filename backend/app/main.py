"""
Startpunkt der FastAPI-Anwendung - registriert alle Router.
"""

import os
import sys
from pathlib import Path

# Add parent directory to path for imports to work
sys.path.insert(0, str(Path(__file__).parent.parent))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import produkte
from app.api import benutzer
from app.api import bestellungen
from app.api import bestellposition
from app.api import kategorien
from app.api import zustaende
from app.api import auth
from dotenv import load_dotenv

# Load environment variables from .env file in the same directory
load_dotenv(Path(__file__).parent / ".env")

app = FastAPI(title="Thriftshop Köln API")

# CORS-Konfiguration für Flutter-Frontend (localhost mit beliebigem Port)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(produkte.router)
app.include_router(benutzer.router)
app.include_router(bestellungen.router)
app.include_router(bestellposition.router)
app.include_router(kategorien.router)
app.include_router(zustaende.router)
app.include_router(auth.router)

if __name__ == "__main__":
    import uvicorn

    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8001"))
    uvicorn.run("main:app", host=host, port=port, reload=True)
