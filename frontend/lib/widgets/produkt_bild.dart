/// Produktbild mit Platzhalter während des Ladens und bei fehlendem Bild.
library;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';

class ProduktBild extends StatelessWidget {
  const ProduktBild(this.url, {super.key, this.beschreibung, this.rundung = 0});

  final String? url;

  /// Alternativtext für Screenreader.
  final String? beschreibung;
  final double rundung;

  @override
  Widget build(BuildContext context) {
    const platzhalter = ColoredBox(
      color: AppFarben.flaecheGetoent,
      child: Center(
        child: Icon(Icons.checkroom_outlined, color: AppFarben.linie, size: 40),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(rundung),
      child: url == null
          ? platzhalter
          : Image.network(
              url!,
              fit: BoxFit.cover,
              semanticLabel: beschreibung,
              // Die Produktfotos haben weißen Hintergrund - so entsteht kein Flackern
              frameBuilder: (context, bild, frame, synchron) => ColoredBox(
                color: Colors.white,
                child: AnimatedOpacity(
                  opacity: synchron || frame != null ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: bild,
                ),
              ),
              errorBuilder: (context, fehler, stack) => platzhalter,
            ),
    );
  }
}
