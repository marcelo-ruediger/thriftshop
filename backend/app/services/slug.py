"""Erzeugt URL-taugliche Slugs aus Bezeichnungen (z.B. 'Braune Lederjacke' -> 'braune-lederjacke')."""

import re

_UMLAUTE = str.maketrans({"ä": "ae", "ö": "oe", "ü": "ue", "ß": "ss"})


def slug_erzeugen(text: str) -> str:
    text = text.lower().translate(_UMLAUTE)
    return re.sub(r"[^a-z0-9]+", "-", text).strip("-") or "artikel"
