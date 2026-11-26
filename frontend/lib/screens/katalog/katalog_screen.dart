/// Startseite: Begrüßung, Filter und das Produktraster.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/pille.dart';
import '../../widgets/produkt_karte.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  late final TextEditingController _suche;

  @override
  void initState() {
    super.initState();
    // Hier und nicht als lazy Feld: sonst liefe die Initialisierung erst in dispose(),
    // wenn die Seite verlassen wird, bevor der Katalog geladen ist.
    _suche = TextEditingController(text: context.read<KatalogProvider>().suche);
  }

  @override
  void dispose() {
    _suche.dispose();
    super.dispose();
  }

  void _zuruecksetzen() {
    _suche.clear();
    context.read<KatalogProvider>().filterZuruecksetzen();
  }

  @override
  Widget build(BuildContext context) {
    final katalog = context.watch<KatalogProvider>();
    final produkte = katalog.gefiltert;

    return SeitenInhalt(
      slivers: [
        const SliverToBoxAdapter(child: _Begruessung()),
        const SliverToBoxAdapter(child: SizedBox(height: Abstand.lg)),
        if (!katalog.geladen)
          SliverToBoxAdapter(
            child: katalog.fehler != null
                ? Hinweisflaeche.fehler(
                    nachricht: katalog.fehler!,
                    erneutVersuchen: katalog.laden,
                  )
                : const SizedBox(height: 320, child: Ladeanzeige()),
          )
        else ...[
          SliverToBoxAdapter(child: _Filterleiste(suche: _suche)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Abstand.md),
              child: Row(
                children: [
                  Text(
                    produkte.length == 1 ? '1 Artikel' : '${produkte.length} Artikel',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (katalog.filterAktiv) ...[
                    const SizedBox(width: Abstand.sm),
                    TextButton(
                      onPressed: _zuruecksetzen,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: Abstand.sm),
                      ),
                      child: const Text('Filter zurücksetzen'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (produkte.isEmpty)
            SliverToBoxAdapter(
              child: Hinweisflaeche(
                icon: Icons.search_off,
                titel: 'Nichts gefunden',
                text: 'Zu deiner Suche gibt es gerade keinen Artikel. Probier es mit einem anderen Begriff oder einer anderen Kategorie.',
                aktion: _zuruecksetzen,
                aktionText: 'Alle Artikel anzeigen',
              ),
            )
          else
            SliverLayoutBuilder(
              builder: (context, constraints) {
                const luecke = Abstand.md + 4;
                final breite = constraints.crossAxisExtent;
                final spalten = (breite / 250).floor().clamp(2, 5);
                final kachel = (breite - (spalten - 1) * luecke) / spalten;
                return SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: spalten,
                    crossAxisSpacing: luecke,
                    mainAxisSpacing: luecke,
                    // quadratisches Bild + Textbereich + Rahmen
                    mainAxisExtent: kachel + ProduktKarte.textHoehe + 2,
                  ),
                  itemCount: produkte.length,
                  itemBuilder: (context, index) => ProduktKarte(
                    produkte[index],
                    key: ValueKey(produkte[index].produktId),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}

/// Großes Bild mit Begrüßungstext über dem Katalog.
class _Begruessung extends StatelessWidget {
  const _Begruessung();

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final breit = MediaQuery.sizeOf(context).width >= 700;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Rundung.xl),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bilder/laden.webp',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.3),
              excludeFromSemantics: true,
            ),
          ),
          // Dunkelgrüner Verlauf, damit die weiße Schrift lesbar bleibt
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppFarben.gruenDunkel.withValues(alpha: 0.96),
                    AppFarben.gruenDunkel.withValues(alpha: breit ? 0.55 : 0.85),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(breit ? Abstand.xxl : Abstand.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SECOND-HAND AUS KÖLN',
                    style: schrift.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: Abstand.sm + 4),
                  Text(
                    'Gute Stücke verdienen ein zweites Leben.',
                    style: (breit ? schrift.displaySmall : schrift.headlineLarge)
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: Abstand.md),
                  Text(
                    'Kleidung, Möbel und Fundstücke – von uns geprüft, fair bepreist und zur Abholung im Laden für dich zurückgelegt.',
                    style: schrift.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: Abstand.lg),
                  const Wrap(
                    spacing: Abstand.lg,
                    runSpacing: Abstand.sm,
                    children: [
                      _Vorteil(Icons.storefront_outlined, 'Abholung im Laden'),
                      _Vorteil(Icons.payments_outlined, 'Zahlung vor Ort oder auf Rechnung'),
                      _Vorteil(Icons.verified_outlined, 'Jedes Teil geprüft'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Vorteil extends StatelessWidget {
  const _Vorteil(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: Abstand.sm),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Suche, Sortierung, Angebotsfilter und Kategorien.
class _Filterleiste extends StatelessWidget {
  const _Filterleiste({required this.suche});

  final TextEditingController suche;

  @override
  Widget build(BuildContext context) {
    final katalog = context.watch<KatalogProvider>();

    final suchfeld = TextField(
      controller: suche,
      onChanged: katalog.suchen,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Wonach suchst du? z. B. Lederjacke, Radio …',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: katalog.suche.isEmpty
            ? null
            : IconButton(
                tooltip: 'Suche leeren',
                icon: const Icon(Icons.close),
                onPressed: () {
                  suche.clear();
                  katalog.suchen('');
                },
              ),
      ),
    );

    final sortierung = PopupMenuButton<Sortierung>(
      tooltip: 'Sortierung ändern',
      initialValue: katalog.sortierung,
      onSelected: katalog.sortieren,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final wahl in Sortierung.values)
          PopupMenuItem(value: wahl, child: Text(wahl.titel)),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: Abstand.md),
        decoration: BoxDecoration(
          color: AppFarben.flaeche,
          border: Border.all(color: AppFarben.linie),
          borderRadius: BorderRadius.circular(Rundung.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert, size: 20, color: AppFarben.tinteGedaempft),
            const SizedBox(width: Abstand.sm),
            Text(
              katalog.sortierung.titel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Icon(Icons.expand_more, size: 20, color: AppFarben.tinteGedaempft),
          ],
        ),
      ),
    );

    final angebote = Pille(
      text: 'Nur Angebote',
      icon: Icons.local_offer_outlined,
      aktiv: katalog.nurAngebote,
      aktivFarbe: AppFarben.terrakotta,
      beiTipp: () => katalog.nurAngeboteZeigen(!katalog.nurAngebote),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 640
              ? Row(
                  children: [
                    Expanded(child: suchfeld),
                    const SizedBox(width: Abstand.md),
                    sortierung,
                    const SizedBox(width: Abstand.md),
                    angebote,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    suchfeld,
                    const SizedBox(height: Abstand.sm + 4),
                    Row(
                      children: [sortierung, const Spacer(), angebote],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: Abstand.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Pille(
                text: 'Alle',
                anzahl: katalog.produkte.length,
                aktiv: katalog.kategorieId == null,
                beiTipp: () => katalog.kategorieWaehlen(null),
              ),
              for (final kategorie in katalog.kategorien)
                Padding(
                  padding: const EdgeInsets.only(left: Abstand.sm),
                  child: Pille(
                    text: kategorie.bezeichnung,
                    anzahl: katalog.anzahlInKategorie(kategorie.kategorieId),
                    aktiv: katalog.kategorieId == kategorie.kategorieId,
                    beiTipp: () => katalog.kategorieWaehlen(kategorie.kategorieId),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
