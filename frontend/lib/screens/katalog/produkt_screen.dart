/// Produktdetailseite mit Bild, Beschreibung und „In den Warenkorb“.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/utils/format.dart';
import '../../models/produkt.dart';
import '../../providers/katalog_provider.dart';
import '../../providers/warenkorb_provider.dart';
import '../../widgets/abzeichen.dart';
import '../../widgets/meldungen.dart';
import '../../widgets/mengen_waehler.dart';
import '../../widgets/preis.dart';
import '../../widgets/produkt_bild.dart';
import '../../widgets/produkt_karte.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';

class ProduktScreen extends StatelessWidget {
  const ProduktScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final katalog = context.watch<KatalogProvider>();

    if (!katalog.geladen) {
      return SeitenInhalt.einfach(
        children: [
          katalog.fehler != null
              ? Hinweisflaeche.fehler(
                  nachricht: katalog.fehler!,
                  erneutVersuchen: katalog.laden,
                )
              : const SizedBox(height: 400, child: Ladeanzeige()),
        ],
      );
    }

    final produkt = katalog.produktNachSlug(slug);
    if (produkt == null) {
      return SeitenInhalt.einfach(
        children: [
          Hinweisflaeche(
            icon: Icons.sell_outlined,
            titel: 'Diesen Artikel gibt es nicht mehr',
            text: 'Second-Hand heißt: Jedes Teil gibt es nur einmal. Im Shop wartet aber schon das nächste Fundstück.',
            aktion: () => context.go('/'),
            aktionText: 'Zum Shop',
          ),
        ],
      );
    }

    final kategorie = katalog.kategorie(produkt.kategorieId);
    final aehnliche = katalog.aehnliche(produkt);
    final bild = AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppFarben.linie),
          borderRadius: BorderRadius.circular(Rundung.xl),
        ),
        child: ProduktBild(
          produkt.bildUrl,
          beschreibung: produkt.bezeichnung,
          rundung: Rundung.xl - 1,
        ),
      ),
    );
    // Der Schlüssel setzt die Mengenauswahl zurück, wenn zu einem anderen Produkt gewechselt wird
    final details = _Details(produkt, key: ValueKey(produkt.produktId));

    return SeitenInhalt.einfach(
      children: [
        // Brotkrumen: Shop / Kategorie
        Row(
          children: [
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Shop'),
              style: TextButton.styleFrom(foregroundColor: AppFarben.tinteGedaempft),
            ),
            if (kategorie != null) ...[
              Text('/', style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                onPressed: () {
                  katalog.kategorieWaehlen(kategorie.kategorieId);
                  context.go('/');
                },
                style: TextButton.styleFrom(foregroundColor: AppFarben.tinteGedaempft),
                child: Text(kategorie.bezeichnung),
              ),
            ],
          ],
        ),
        const SizedBox(height: Abstand.md),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 760
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: bild),
                    const SizedBox(width: Abstand.xxl),
                    Expanded(flex: 10, child: details),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [bild, const SizedBox(height: Abstand.lg), details],
                ),
        ),
        if (aehnliche.isNotEmpty) ...[
          const SizedBox(height: Abstand.xxl),
          Text(
            'Mehr aus ${kategorie?.bezeichnung ?? 'dieser Kategorie'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: Abstand.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const luecke = Abstand.md + 4;
              final spalten = constraints.maxWidth >= 760 ? 4 : 2;
              final kachel = (constraints.maxWidth - (spalten - 1) * luecke) / spalten;
              return Wrap(
                spacing: luecke,
                runSpacing: luecke,
                children: [
                  for (final p in aehnliche)
                    SizedBox(
                      width: kachel,
                      height: kachel + ProduktKarte.textHoehe + 2,
                      child: ProduktKarte(p),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _Details extends StatefulWidget {
  const _Details(this.produkt, {super.key});

  final Produkt produkt;

  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> {
  int _menge = 1;

  void _inDenWarenkorb(int nochMoeglich) {
    final produkt = widget.produkt;
    final hinzugefuegt = context.read<WarenkorbProvider>().hinzufuegen(
      produkt,
      menge: _menge.clamp(1, nochMoeglich),
    );
    if (hinzugefuegt > 0) {
      setState(() => _menge = 1);
      meldung(context, '„${produkt.bezeichnung}“ liegt im Warenkorb.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final produkt = widget.produkt;
    final schrift = Theme.of(context).textTheme;
    final katalog = context.watch<KatalogProvider>();
    final zustand = katalog.zustand(produkt.zustandId);
    final imKorb = context.select<WarenkorbProvider, int>(
      (w) => w.mengeVon(produkt.produktId),
    );
    final nochMoeglich = produkt.lagerbestand - imKorb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (produkt.reduziert)
          Padding(
            padding: const EdgeInsets.only(bottom: Abstand.sm + 4),
            child: Abzeichen(
              '${prozent(produkt.rabattProzent)} reduziert',
              farbe: Colors.white,
              hintergrund: AppFarben.terrakotta,
              icon: Icons.local_offer_outlined,
            ),
          ),
        Text(produkt.bezeichnung, style: schrift.headlineLarge),
        const SizedBox(height: Abstand.xs),
        Text('Artikelnummer ${produkt.produktnr}', style: schrift.bodySmall),
        const SizedBox(height: Abstand.md),
        Preis(produkt, gross: true),
        const SizedBox(height: Abstand.xs),
        Text(
          'inkl. ${prozent(produkt.steuersatz)} MwSt. · Abholung im Laden',
          style: schrift.bodySmall,
        ),
        const SizedBox(height: Abstand.lg),
        Text(produkt.produktInfo, style: schrift.bodyLarge),
        const SizedBox(height: Abstand.lg),
        if (zustand != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Abstand.md),
            decoration: BoxDecoration(
              color: AppFarben.gruenHell,
              borderRadius: BorderRadius.circular(Rundung.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_outlined, color: AppFarben.gruenDunkel, size: 22),
                const SizedBox(width: Abstand.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zustand: ${zustand.bezeichnung}',
                        style: schrift.titleSmall?.copyWith(color: AppFarben.gruenDunkel),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        zustand.beschreibung,
                        style: schrift.bodyMedium?.copyWith(color: AppFarben.gruenDunkel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: Abstand.lg),
        _Verfuegbarkeit(produkt),
        const SizedBox(height: Abstand.md),
        if (produkt.ausverkauft)
          const SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: null, child: Text('Ausverkauft')),
          )
        else if (nochMoeglich <= 0)
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => context.go('/warenkorb'),
              icon: const Icon(Icons.check),
              label: Text(
                produkt.einzelstueck
                    ? 'Liegt im Warenkorb – ansehen'
                    : 'Alle $imKorb Stück liegen im Warenkorb – ansehen',
              ),
            ),
          )
        else
          Row(
            children: [
              if (nochMoeglich > 1) ...[
                MengenWaehler(
                  menge: _menge.clamp(1, nochMoeglich),
                  maximum: nochMoeglich,
                  beiAenderung: (menge) => setState(() => _menge = menge),
                ),
                const SizedBox(width: Abstand.md),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _inDenWarenkorb(nochMoeglich),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('In den Warenkorb'),
                ),
              ),
            ],
          ),
        if (imKorb > 0 && nochMoeglich > 0)
          Padding(
            padding: const EdgeInsets.only(top: Abstand.sm),
            child: Text('$imKorb × bereits im Warenkorb', style: schrift.bodySmall),
          ),
        const SizedBox(height: Abstand.lg),
        const Divider(),
        const SizedBox(height: Abstand.md),
        const _Zeile(
          Icons.storefront_outlined,
          'Abholung im Laden',
          'Wir legen dein Teil sieben Tage für dich zurück.',
        ),
        const _Zeile(
          Icons.payments_outlined,
          'Bezahlen, wie es passt',
          'Bar oder mit Karte bei der Abholung – oder vorab per Rechnung.',
        ),
      ],
    );
  }
}

class _Verfuegbarkeit extends StatelessWidget {
  const _Verfuegbarkeit(this.produkt);

  final Produkt produkt;

  @override
  Widget build(BuildContext context) {
    final (icon, farbe, text) = produkt.ausverkauft
        ? (Icons.remove_circle_outline, AppFarben.tinteGedaempft, 'Leider schon verkauft')
        : produkt.einzelstueck
        ? (Icons.auto_awesome_outlined, AppFarben.terrakotta, 'Einzelstück – nur einmal verfügbar')
        : (Icons.check_circle_outline, AppFarben.gruen, '${produkt.lagerbestand} Stück verfügbar');
    return Row(
      children: [
        Icon(icon, size: 18, color: farbe),
        const SizedBox(width: Abstand.sm),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: farbe),
        ),
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile(this.icon, this.titel, this.text);

  final IconData icon;
  final String titel;
  final String text;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Abstand.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppFarben.tinteGedaempft),
          const SizedBox(width: Abstand.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titel, style: schrift.titleSmall),
                Text(text, style: schrift.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
