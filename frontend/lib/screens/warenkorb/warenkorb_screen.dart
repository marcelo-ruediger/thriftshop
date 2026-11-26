/// Warenkorb: Artikel, Mengen und der Weg zur Kasse.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/utils/format.dart';
import '../../models/warenkorb_item.dart';
import '../../providers/warenkorb_provider.dart';
import '../../widgets/bestell_widgets.dart';
import '../../widgets/mengen_waehler.dart';
import '../../widgets/produkt_bild.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';

class WarenkorbScreen extends StatelessWidget {
  const WarenkorbScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final warenkorb = context.watch<WarenkorbProvider>();

    final hinweis = warenkorb.hinweis == null
        ? null
        : Container(
            margin: const EdgeInsets.only(bottom: Abstand.md),
            padding: const EdgeInsets.fromLTRB(Abstand.md, Abstand.xs, Abstand.xs, Abstand.xs),
            decoration: BoxDecoration(
              color: AppFarben.warnungHell,
              borderRadius: BorderRadius.circular(Rundung.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppFarben.warnung, size: 20),
                const SizedBox(width: Abstand.sm + 4),
                Expanded(child: Text(warenkorb.hinweis!)),
                IconButton(
                  tooltip: 'Hinweis schließen',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: warenkorb.hinweisSchliessen,
                ),
              ],
            ),
          );

    if (warenkorb.istLeer) {
      return SeitenInhalt.einfach(
        children: [
          ?hinweis,
          Hinweisflaeche(
            icon: Icons.shopping_bag_outlined,
            titel: 'Dein Warenkorb ist noch leer',
            text: 'Stöber durch den Shop – die schönsten Stücke sind schnell weg.',
            aktion: () => context.go('/'),
            aktionText: 'Zum Shop',
          ),
        ],
      );
    }

    final artikel = Card(
      child: Column(
        children: [
          for (final (index, item) in warenkorb.items.indexed) ...[
            if (index > 0) const Divider(),
            _Position(item),
          ],
        ],
      ),
    );

    final zusammenfassung = Abschnitt(
      titel: 'Zusammenfassung',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Summenzeile(
            warenkorb.anzahl == 1 ? '1 Artikel' : '${warenkorb.anzahl} Artikel',
            euro(warenkorb.summe),
          ),
          const Summenzeile('Abholung im Laden', 'kostenlos'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Abstand.sm),
            child: Divider(),
          ),
          Summenzeile('Gesamt', euro(warenkorb.summe), hervorgehoben: true),
          Text(
            'inkl. ${euro(warenkorb.mwst)} MwSt.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Abstand.lg),
          FilledButton(
            onPressed: () => context.go('/checkout'),
            child: const Text('Zur Kasse'),
          ),
          const SizedBox(height: Abstand.sm),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Weiter stöbern'),
          ),
        ],
      ),
    );

    return SeitenInhalt.einfach(
      children: [
        const Seitentitel('Warenkorb'),
        ?hinweis,
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 820
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: artikel),
                    const SizedBox(width: Abstand.lg),
                    SizedBox(width: 360, child: zusammenfassung),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [artikel, const SizedBox(height: Abstand.md), zusammenfassung],
                ),
        ),
      ],
    );
  }
}

class _Position extends StatelessWidget {
  const _Position(this.item);

  final WarenkorbItem item;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final produkt = item.produkt;
    final warenkorb = context.read<WarenkorbProvider>();

    return Padding(
      padding: const EdgeInsets.all(Abstand.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go('/produkt/${produkt.slug}'),
            borderRadius: BorderRadius.circular(Rundung.md),
            child: SizedBox.square(
              dimension: 88,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppFarben.linie),
                  borderRadius: BorderRadius.circular(Rundung.md),
                ),
                child: ProduktBild(
                  produkt.bildUrl,
                  beschreibung: produkt.bezeichnung,
                  rundung: Rundung.md - 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: Abstand.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(produkt.bezeichnung, style: schrift.titleMedium),
                    ),
                    const SizedBox(width: Abstand.sm),
                    Text(
                      euro(item.summe),
                      style: schrift.titleMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                Text(
                  produkt.reduziert
                      ? '${euro(produkt.endpreis)} pro Stück statt ${euro(produkt.preis)}'
                      : '${euro(produkt.endpreis)} pro Stück',
                  style: schrift.bodySmall,
                ),
                const SizedBox(height: Abstand.sm + 4),
                Row(
                  children: [
                    if (produkt.lagerbestand > 1)
                      MengenWaehler(
                        menge: item.menge,
                        maximum: produkt.lagerbestand,
                        beiAenderung: (menge) =>
                            warenkorb.mengeAendern(produkt.produktId, menge),
                      )
                    else
                      Text('Einzelstück', style: schrift.bodySmall),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => warenkorb.entfernen(produkt.produktId),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Entfernen'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppFarben.tinteGedaempft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
