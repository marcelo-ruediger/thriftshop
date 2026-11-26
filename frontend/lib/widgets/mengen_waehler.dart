/// Mengenauswahl mit Minus- und Plus-Schaltfläche.
library;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';

class MengenWaehler extends StatelessWidget {
  const MengenWaehler({
    super.key,
    required this.menge,
    required this.maximum,
    required this.beiAenderung,
    this.minimum = 1,
  });

  final int menge;
  final int minimum;
  final int maximum;
  final ValueChanged<int> beiAenderung;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppFarben.flaeche,
        border: Border.all(color: AppFarben.linie),
        borderRadius: BorderRadius.circular(Rundung.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Menge verringern',
            icon: const Icon(Icons.remove, size: 18),
            onPressed: menge > minimum ? () => beiAenderung(menge - 1) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 28),
            child: Text(
              '$menge',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: menge < maximum ? 'Menge erhöhen' : 'Mehr ist nicht auf Lager',
            icon: const Icon(Icons.add, size: 18),
            onPressed: menge < maximum ? () => beiAenderung(menge + 1) : null,
          ),
        ],
      ),
    );
  }
}
