/// Preisanzeige - bei Rabatt mit durchgestrichenem Listenpreis.
library;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';
import '../core/utils/format.dart';
import '../models/produkt.dart';

class Preis extends StatelessWidget {
  const Preis(this.produkt, {super.key, this.gross = false});

  final Produkt produkt;
  final bool gross;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final stil = (gross ? text.headlineMedium : text.titleMedium)?.copyWith(
      // Tabellenziffern, damit Preise untereinander sauber stehen
      fontFeatures: const [FontFeature.tabularFigures()],
      color: produkt.reduziert ? AppFarben.terrakotta : AppFarben.tinte,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: Abstand.sm,
      children: [
        Text(euro(produkt.endpreis), style: stil),
        if (produkt.reduziert)
          Padding(
            padding: EdgeInsets.only(bottom: gross ? 4 : 1),
            child: Text(
              euro(produkt.preis),
              style: (gross ? text.bodyLarge : text.bodySmall)?.copyWith(
                color: AppFarben.tinteGedaempft,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
      ],
    );
  }
}
