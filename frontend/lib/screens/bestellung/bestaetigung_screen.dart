/// Bestätigung nach dem Bestellen: Bestellnummer und wie es weitergeht.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../models/bestellung.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bestell_provider.dart';
import '../../widgets/bestell_widgets.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';

class BestaetigungScreen extends StatefulWidget {
  const BestaetigungScreen({super.key, required this.bestellungId});

  final String bestellungId;

  @override
  State<BestaetigungScreen> createState() => _BestaetigungScreenState();
}

class _BestaetigungScreenState extends State<BestaetigungScreen> {
  late Future<Bestellung> _bestellung = _laden();

  Future<Bestellung> _laden() =>
      context.read<BestellProvider>().eine(widget.bestellungId);

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final vorname = context.watch<AuthProvider>().benutzer?.vorname ?? '';

    return FutureBuilder<Bestellung>(
      future: _bestellung,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final fehler = snapshot.error;
          return SeitenInhalt.einfach(
            children: [
              Hinweisflaeche.fehler(
                nachricht: fehler is ApiFehler
                    ? fehler.nachricht
                    : 'Die Bestellung konnte nicht geladen werden.',
                erneutVersuchen: () => setState(() => _bestellung = _laden()),
              ),
            ],
          );
        }
        final bestellung = snapshot.data;
        if (bestellung == null) {
          return SeitenInhalt.einfach(
            children: const [SizedBox(height: 400, child: Ladeanzeige())],
          );
        }

        final rechnung = bestellung.zahlungsart == Zahlungsarten.rechnung;
        return SeitenInhalt.einfach(
          maxBreite: Breakpoints.schmalMax,
          children: [
            const SizedBox(height: Abstand.md),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppFarben.gruenHell,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 36, color: AppFarben.gruenDunkel),
              ),
            ),
            const SizedBox(height: Abstand.lg),
            Text(
              vorname.isEmpty ? 'Danke für deine Bestellung!' : 'Danke, $vorname!',
              textAlign: TextAlign.center,
              style: schrift.headlineLarge,
            ),
            const SizedBox(height: Abstand.sm),
            Text(
              'Deine Bestellung ${bestellung.bestellnr} ist bei uns eingegangen.',
              textAlign: TextAlign.center,
              style: schrift.bodyLarge?.copyWith(color: AppFarben.tinteGedaempft),
            ),
            const SizedBox(height: Abstand.xl),
            Abschnitt(
              titel: 'So geht es weiter',
              child: Column(
                children: [
                  const _Schritt(
                    1,
                    'Wir legen deine Teile zurück',
                    'In der Regel innerhalb eines Werktags.',
                  ),
                  _Schritt(
                    2,
                    rechnung ? 'Du bekommst die Rechnung per E-Mail' : 'Du bekommst Bescheid',
                    rechnung
                        ? 'Bitte überweise den Betrag vor der Abholung.'
                        : 'Sobald alles bereitliegt, schreiben wir dir eine E-Mail.',
                  ),
                  _Schritt(
                    3,
                    'Abholen im Laden',
                    rechnung
                        ? 'Musterstraße 12, 50667 Köln · Di–Sa 11–19 Uhr.'
                        : 'Musterstraße 12, 50667 Köln · Di–Sa 11–19 Uhr. Bezahlt wird vor Ort.',
                    letzter: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Abstand.md),
            BestellKarte(bestellung),
            const SizedBox(height: Abstand.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Abstand.md,
              runSpacing: Abstand.sm,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/bestellungen'),
                  child: const Text('Meine Bestellungen'),
                ),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Weiter stöbern'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Schritt extends StatelessWidget {
  const _Schritt(this.nummer, this.titel, this.text, {this.letzter = false});

  final int nummer;
  final String titel;
  final String text;
  final bool letzter;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: letzter ? 0 : Abstand.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppFarben.gruen,
            child: Text(
              '$nummer',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
