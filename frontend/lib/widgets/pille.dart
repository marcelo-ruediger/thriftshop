/// Auswählbare „Pille“ für Filter - z.B. Kategorien oder Bestellstatus.
library;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';

class Pille extends StatelessWidget {
  const Pille({
    super.key,
    required this.text,
    required this.aktiv,
    required this.beiTipp,
    this.anzahl,
    this.icon,
    this.aktivFarbe = AppFarben.gruen,
  });

  final String text;

  /// Optionale Trefferzahl hinter dem Text.
  final int? anzahl;
  final IconData? icon;
  final bool aktiv;
  final VoidCallback beiTipp;
  final Color aktivFarbe;

  @override
  Widget build(BuildContext context) {
    final farbe = aktiv ? Colors.white : AppFarben.tinte;
    final stil = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: aktiv ? FontWeight.w600 : FontWeight.w500,
      color: farbe,
    );

    return Semantics(
      button: true,
      selected: aktiv,
      child: Material(
        color: aktiv ? aktivFarbe : AppFarben.flaeche,
        shape: StadiumBorder(
          side: BorderSide(color: aktiv ? aktivFarbe : AppFarben.linie),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: beiTipp,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: aktiv ? Colors.white : aktivFarbe),
                  const SizedBox(width: 6),
                ],
                Text(text, style: stil),
                if (anzahl != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$anzahl',
                    style: stil?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: aktiv
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppFarben.tinteGedaempft,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
