/// Kleine farbige Etiketten: Bestellstatus, Rabatt, Zustand.
library;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';
import '../models/bestellung.dart';

class Abzeichen extends StatelessWidget {
  const Abzeichen(
    this.text, {
    super.key,
    this.farbe = AppFarben.tinte,
    this.hintergrund = AppFarben.flaecheGetoent,
    this.icon,
  });

  final String text;
  final Color farbe;
  final Color hintergrund;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hintergrund,
        borderRadius: BorderRadius.circular(Rundung.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: farbe),
            const SizedBox(width: Abstand.xs),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: farbe,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bestellstatus mit Farbe und Symbol - Farbe ist nie der einzige Hinweis.
class StatusAbzeichen extends StatelessWidget {
  const StatusAbzeichen(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (farbe, hintergrund, icon) = switch (status) {
      Bestellstatus.offen => (
        AppFarben.warnung,
        AppFarben.warnungHell,
        Icons.schedule,
      ),
      Bestellstatus.inBearbeitung => (
        AppFarben.info,
        AppFarben.infoHell,
        Icons.inventory_2_outlined,
      ),
      Bestellstatus.abgeschlossen => (
        AppFarben.gruenDunkel,
        AppFarben.gruenHell,
        Icons.check_circle_outline,
      ),
      Bestellstatus.storniert => (
        AppFarben.fehler,
        AppFarben.fehlerHell,
        Icons.cancel_outlined,
      ),
      _ => (AppFarben.tinteGedaempft, AppFarben.flaecheGetoent, Icons.undo),
    };
    return Abzeichen(status, farbe: farbe, hintergrund: hintergrund, icon: icon);
  }
}
