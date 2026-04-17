from fastapi import FastAPI
from app.api import produkte

app = FastAPI(title="Thriftshop Köln API")

app.include_router(produkte.router)