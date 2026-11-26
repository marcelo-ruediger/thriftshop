# Product photo sources

The shop reads its 50 product photos from `backend/static/produktbilder/` (800 × 800 px, WebP,
product on a white background). The file name without `.webp` is the image key in
`backend/app/seed.py`.

This folder keeps what those photos were made from, so they are easy to find, swap and undo:

| Path                 | Contents                                                                              |
|----------------------|---------------------------------------------------------------------------------------|
| `stockfotos/`        | The nine stock photos as downloaded, named after the shop image they feed              |
| `ki-ersetzt/`        | The nine AI-generated images those photos replaced, unchanged                          |
| `freistellen.swift`  | Small macOS tool that cuts the product out of a photo and puts it on a white square    |

Nothing in this folder is used by the running shop, and it is left out of the Docker image.

## The nine stock photos

All nine come from [Pexels](https://www.pexels.com) and are used under the
[Pexels License](https://www.pexels.com/license/) (free to use, attribution not required).
The remaining 41 product photos in `backend/static/produktbilder/` are AI-generated (Flux).

Eight were cut out of their original surroundings with `freistellen.swift`, so they match the
white background of the other photos. The controller was already photographed on white and is
only cropped.

| Shop image                 | Product                                | Photographer               | Source                                 | Made with                    |
|----------------------------|----------------------------------------|----------------------------|----------------------------------------|------------------------------|
| `001_gel1.webp`            | Haarpomade Classic im Glas             | Vie Studio                 | https://www.pexels.com/photo/7004667/  | cut-out, fill `0.80`         |
| `002_gel2.webp`            | Styling-Creme Retro Edition            | Deepa Nishad               | https://www.pexels.com/photo/27544670/ | cut-out, fill `0.78`         |
| `008_radio2.webp`          | Transistorradio mit Tragebügel         | Việt Anh Nguyễn            | https://www.pexels.com/photo/38734460/ | cut-out, fill `0.84`         |
| `010_tshits1.webp`         | T-Shirt-Set Schwarz und Weiß (2 Stück) | dayong tien                | https://www.pexels.com/photo/18186105/ | cut-out, fill `0.88`         |
| `034_boots1.webp`          | Lederstiefel Braun Western             | Robert So                  | https://www.pexels.com/photo/19750710/ | cut-out, fill `0.86`         |
| `035_boots2.webp`          | Stiefeletten Schwarz mit Schnalle      | José Martin Segura Benites | https://www.pexels.com/photo/26851201/ | cut-out, fill `0.84`         |
| `036_boots3.webp`          | Schnürboots Nussbraun                  | 丹 师                      | https://www.pexels.com/photo/30156653/ | cut-out, fill `0.86`         |
| `043_spielcontroller.webp` | Gamecontroller Rot-Schwarz             | Huy Phan                   | https://www.pexels.com/photo/4225230/  | crop `180 350 1100`          |
| `045_gitarre1.webp`        | Westerngitarre mit Cutaway             | MART PRODUCTION            | https://www.pexels.com/photo/8107171/  | cut-out, fill `0.92`         |

Seven product texts in `backend/app/seed.py` were adjusted to match their photo (001, 002, 008,
010, 034, 035, 036). The demo data is only written into an empty database, so an existing database keeps the
old texts until it is reset with `rm backend/data/thriftshop.db`. The photos change right away.

## Replace a photo

Put the new source picture into `stockfotos/` under the name of the shop image. Converting needs
`cwebp` (`brew install webp`); cutting out also needs macOS 14 or newer with the Xcode command
line tools.

**Cut the product out onto white** (any background):

```bash
swiftc -O produktbilder-quellen/freistellen.swift -o /tmp/freistellen     # once
/tmp/freistellen produktbilder-quellen/stockfotos/<name>.jpg /tmp/<name>.png 1600 0.84
cwebp -q 86 -resize 800 800 /tmp/<name>.png -o backend/static/produktbilder/<name>.webp
```

`0.84` is the fill: how much of the square the product takes up. The tool lists every object it
finds with a number; add `0 <numbers>` (for example `0 2`) to the first command to keep only
those objects, for example a jar without the brush lying next to it. The `0` before the numbers is the strength of an optional
soft shadow (`0` = none).

**Only crop** (photo already has a white background): `x y` is the top-left corner of the square
and `size` its edge length, in pixels of the source picture:

```bash
cwebp -q 84 -crop <x> <y> <size> <size> -resize 800 800 \
  produktbilder-quellen/stockfotos/<name>.jpg \
  -o backend/static/produktbilder/<name>.webp
```

Add or update the row in the table above. The shop shows a replaced photo on the next reload.

## Undo a replacement

Copy the archived AI image back over the shop image:

```bash
cp produktbilder-quellen/ki-ersetzt/001_gel1.webp backend/static/produktbilder/001_gel1.webp
```

To undo all nine at once:

```bash
cp produktbilder-quellen/ki-ersetzt/*.webp backend/static/produktbilder/
```
