/// Verwaltung - Übersicht mit Kennzahlen und den neuesten Bestellungen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/utils/format.dart';
import '../../models/bestellung.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/abzeichen.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';
import 'admin_rahmen.dart';

class AdminUebersichtScreen extends StatefulWidget {
  const AdminUebersichtScreen({super.key});

  @override
  State<AdminUebersichtScreen> createState() => _AdminUebersichtScreenState();
}

class _AdminUebersichtScreenState extends State<AdminUebersichtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminProvider>().uebersichtLaden();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final statistik = admin.statistik;
    final bestellungen = admin.neuesteBestellungen;

    return AdminRahmen(
      pfad: '/admin',
      titel: 'Verwaltung',
      untertitel: 'Was heute im Laden ansteht.',
      children: [
        if (statistik == null || bestellungen == null)
          admin.fehler != null
              ? Hinweisflaeche.fehler(
                  nachricht: admin.fehler!,
                  erneutVersuchen: admin.uebersichtLaden,
                )
              : const SizedBox(height: 320, child: Ladeanzeige())
        else ...[
          LayoutBuilder(
            builder: (context, constraints) {
              const luecke = Abstand.md;
              final spalten = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              final breite = (constraints.maxWidth - (spalten - 1) * luecke) / spalten;
              final kacheln = [
                _Kennzahl(
                  icon: Icons.euro,
                  wert: euro(statistik.umsatz),
                  titel: 'Umsatz',
                  hinweis: 'ohne stornierte und erstattete Bestellungen',
                ),
                _Kennzahl(
                  icon: Icons.schedule,
                  wert: '${statistik.anzahl(Bestellstatus.offen)}',
                  titel: 'Offene Bestellungen',
                  hinweis: 'warten darauf, zurückgelegt zu werden',
                  beiTipp: () => context.go('/admin/bestellungen'),
                ),
                _Kennzahl(
                  icon: Icons.inventory_2_outlined,
                  wert: '${statistik.produkteAktiv}',
                  titel: 'Artikel im Shop',
                  hinweis: statistik.produkteAusverkauft == 0
                      ? 'alle verfügbar'
                      : 'davon ${statistik.produkteAusverkauft} ausverkauft',
                  beiTipp: () => context.go('/admin/produkte'),
                ),
                _Kennzahl(
                  icon: Icons.group_outlined,
                  wert: '${statistik.kunden}',
                  titel: 'Kundenkonten',
                  hinweis: '${statistik.bestellungenGesamt} Bestellungen insgesamt',
                ),
              ];
              return Wrap(
                spacing: luecke,
                runSpacing: luecke,
                children: [
                  for (final kachel in kacheln)
                    SizedBox(width: breite, height: 148, child: kachel),
                ],
              );
            },
          ),
          const SizedBox(height: Abstand.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final status = _NachStatus(statistik);
              final neueste = _Neueste(bestellungen);
              return constraints.maxWidth >= 820
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: neueste),
                        const SizedBox(width: Abstand.md),
                        Expanded(flex: 2, child: status),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [neueste, const SizedBox(height: Abstand.md), status],
                    );
            },
          ),
        ],
      ],
    );
  }
}

/// Kachel mit einer Kennzahl. Die Zahl steht in Textfarbe, nicht in einer Signalfarbe.
class _Kennzahl extends StatelessWidget {
  const _Kennzahl({
    required this.icon,
    required this.wert,
    required this.titel,
    required this.hinweis,
    this.beiTipp,
  });

  final IconData icon;
  final String wert;
  final String titel;
  final String hinweis;
  final VoidCallback? beiTipp;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: beiTipp,
        child: Padding(
          padding: const EdgeInsets.all(Abstand.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppFarben.tinteGedaempft),
                  const SizedBox(width: Abstand.sm),
                  Expanded(
                    child: Text(
                      titel,
                      style: schrift.labelLarge?.copyWith(color: AppFarben.tinteGedaempft),
                    ),
                  ),
                  if (beiTipp != null)
                    const Icon(Icons.arrow_forward, size: 16, color: AppFarben.tinteGedaempft),
                ],
              ),
              const SizedBox(height: Abstand.sm + 4),
              Text(
                wert,
                style: schrift.headlineLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: Abstand.xs),
              Text(
                hinweis,
                style: schrift.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NachStatus extends StatelessWidget {
  const _NachStatus(this.statistik);

  final Statistik statistik;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Abschnitt(
      titel: 'Bestellungen nach Status',
      child: Column(
        children: [
          for (final status in Bestellstatus.alle)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Abstand.xs + 2),
              child: Row(
                children: [
                  StatusAbzeichen(status),
                  const Spacer(),
                  Text(
                    '${statistik.anzahl(status)}',
                    style: schrift.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Neueste extends StatelessWidget {
  const _Neueste(this.bestellungen);

  final List<Bestellung> bestellungen;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Abschnitt(
      titel: 'Neueste Bestellungen',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (bestellungen.isEmpty)
            Text('Noch keine Bestellungen eingegangen.', style: schrift.bodyMedium),
          for (final (index, bestellung) in bestellungen.indexed) ...[
            if (index > 0) const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Abstand.sm + 2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${bestellung.bestellnr} · ${bestellung.kundeName ?? ''}',
                          style: schrift.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${datum(bestellung.bestelldatum)} · ${bestellung.artikelAnzahl} Artikel · ${euro(bestellung.gesamtpreis)}',
                          style: schrift.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Abstand.sm),
                  StatusAbzeichen(bestellung.status),
                ],
              ),
            ),
          ],
          const SizedBox(height: Abstand.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.go('/admin/bestellungen'),
              child: const Text('Alle Bestellungen ansehen'),
            ),
          ),
        ],
      ),
    );
  }
}
