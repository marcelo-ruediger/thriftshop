"""Gemeinsame Hilfen für die API-Routen."""

from fastapi import HTTPException, status


def nicht_gefunden(was: str) -> HTTPException:
    return HTTPException(status.HTTP_404_NOT_FOUND, detail=f"{was} nicht gefunden")


def konflikt(nachricht: str) -> HTTPException:
    return HTTPException(status.HTTP_409_CONFLICT, detail=nachricht)
