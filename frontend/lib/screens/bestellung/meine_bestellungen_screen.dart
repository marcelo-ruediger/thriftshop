/// Bestellhistorie des angemeldeten Kunden - mit Stornieren offener Bestellungen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../models/bestellung.dart';
import '../../providers/bestell_provider.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/bestell_widgets.dart';
import '../../widgets/meldungen.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';

class MeineBestellungenScreen extends StatefulWidget {
  const MeineBestellungenScreen({super.key});

  @override
  State<MeineBestellungenScreen> createState() => _MeineBestellungenScreenState();
}

class _MeineBestellungenScreenState extends State<MeineBestellungenScreen> {
  @override
  void initState() {
    super.initState();
    // Erst nach dem ersten Frame: laden() benachrichtigt die Zuhörer sofort
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BestellProvider>().laden();
    });
  }

  Future<void> _stornieren(Bestellung bestellung) async {
    final ja = await bestaetigen(
      context,
      titel: 'Bestellung ${bestellung.bestellnr} stornieren?',
      text: 'Die Teile gehen zurück in den Shop und können von anderen gekauft werden.',
      aktion: 'Stornieren',
      gefaehrlich: true,
    );
    if (!ja || !mounted) return;
    try {
      await context.read<BestellProvider>().stornieren(bestellung.bestellungId);
      if (!mounted) return;
      context.read<KatalogProvider>().laden(still: true); // Bestand ist zurück
      meldung(context, 'Bestellung ${bestellung.bestellnr} wurde storniert.');
    } on ApiFehler catch (fehler) {
      if (!mounted) return;
      meldung(context, fehler.nachricht, fehler: true);
      context.read<BestellProvider>().laden();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BestellProvider>();
    final bestellungen = provider.bestellungen;

    Widget inhalt;
    if (bestellungen == null) {
      inhalt = provider.fehler != null
          ? Hinweisflaeche.fehler(
              nachricht: provider.fehler!,
              erneutVersuchen: provider.laden,
            )
          : const SizedBox(height: 320, child: Ladeanzeige());
    } else if (bestellungen.isEmpty) {
      inhalt = Hinweisflaeche(
        icon: Icons.receipt_long_outlined,
        titel: 'Noch keine Bestellungen',
        text: 'Sobald du etwas bestellst, findest du es hier – samt Status.',
        aktion: () => context.go('/'),
        aktionText: 'Zum Shop',
      );
    } else {
      inhalt = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final bestellung in bestellungen)
            Padding(
              padding: const EdgeInsets.only(bottom: Abstand.md),
              child: BestellKarte(
                bestellung,
                key: ValueKey(bestellung.bestellungId),
                beiArtikelTipp: (position) {
                  if (position.slug != null) context.go('/produkt/${position.slug}');
                },
                aktionen: [
                  if (bestellung.stornierbar)
                    OutlinedButton(
                      onPressed: () => _stornieren(bestellung),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppFarben.fehler,
                        minimumSize: const Size(0, 40),
                      ),
                      child: const Text('Bestellung stornieren'),
                    ),
                ],
              ),
            ),
        ],
      );
    }

    return SeitenInhalt.einfach(
      maxBreite: 860,
      children: [
        const Seitentitel(
          'Meine Bestellungen',
          untertitel: 'Offene Bestellungen kannst du jederzeit stornieren.',
        ),
        inhalt,
      ],
    );
  }
}
