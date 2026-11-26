/// Verwaltung - alle Bestellungen mit Statuswechsel.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../models/bestellung.dart';
import '../../providers/admin_provider.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/bestell_widgets.dart';
import '../../widgets/meldungen.dart';
import '../../widgets/pille.dart';
import '../../widgets/zustands_anzeigen.dart';
import 'admin_rahmen.dart';

class AdminBestellungenScreen extends StatefulWidget {
  const AdminBestellungenScreen({super.key});

  @override
  State<AdminBestellungenScreen> createState() => _AdminBestellungenScreenState();
}

class _AdminBestellungenScreenState extends State<AdminBestellungenScreen> {
  /// `null` zeigt alle Bestellungen.
  String? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminProvider>().bestellungenLaden();
    });
  }

  Future<void> _wechseln(Bestellung bestellung, String neuerStatus) async {
    // Storno und Erstattung lassen sich nicht zurücknehmen - vorher nachfragen
    final endgueltig =
        neuerStatus == Bestellstatus.storniert || neuerStatus == Bestellstatus.erstattet;
    if (endgueltig) {
      final ja = await bestaetigen(
        context,
        titel: neuerStatus == Bestellstatus.storniert
            ? 'Bestellung ${bestellung.bestellnr} stornieren?'
            : 'Bestellung ${bestellung.bestellnr} erstatten?',
        text: bestellung.status == Bestellstatus.storniert
            ? 'Die Bestellung wird als erstattet markiert. Das lässt sich nicht rückgängig machen.'
            : 'Die Ware wird zurück ins Lager gebucht. Das lässt sich nicht rückgängig machen.',
        aktion: neuerStatus == Bestellstatus.storniert ? 'Stornieren' : 'Erstatten',
        gefaehrlich: true,
      );
      if (!ja || !mounted) return;
    }
    try {
      await context.read<AdminProvider>().statusAendern(bestellung.bestellungId, neuerStatus);
      if (!mounted) return;
      meldung(context, '${bestellung.bestellnr} ist jetzt „$neuerStatus“.');
      if (endgueltig) context.read<KatalogProvider>().laden(still: true);
    } on ApiFehler catch (fehler) {
      if (mounted) meldung(context, fehler.nachricht, fehler: true);
    }
  }

  /// Schaltflächen für die erlaubten Folgestatus einer Bestellung.
  List<Widget> _aktionen(Bestellung bestellung) => [
    for (final ziel in Bestellstatus.uebergaenge[bestellung.status] ?? const <String>[])
      switch (ziel) {
        Bestellstatus.inBearbeitung => FilledButton(
          onPressed: () => _wechseln(bestellung, ziel),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          child: const Text('In Bearbeitung nehmen'),
        ),
        Bestellstatus.abgeschlossen => FilledButton(
          onPressed: () => _wechseln(bestellung, ziel),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          child: const Text('Abgeholt – abschließen'),
        ),
        Bestellstatus.storniert => OutlinedButton(
          onPressed: () => _wechseln(bestellung, ziel),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppFarben.fehler,
            minimumSize: const Size(0, 40),
          ),
          child: const Text('Stornieren'),
        ),
        _ => OutlinedButton(
          onPressed: () => _wechseln(bestellung, ziel),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
          child: const Text('Erstatten'),
        ),
      },
  ];

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final alle = admin.bestellungen;
    final gefiltert = alle?.where((b) => _status == null || b.status == _status).toList();

    return AdminRahmen(
      pfad: '/admin/bestellungen',
      titel: 'Bestellungen',
      untertitel: 'Bestellungen zurücklegen, abschließen oder stornieren.',
      children: [
        if (alle == null || gefiltert == null)
          admin.fehler != null
              ? Hinweisflaeche.fehler(
                  nachricht: admin.fehler!,
                  erneutVersuchen: admin.bestellungenLaden,
                )
              : const SizedBox(height: 320, child: Ladeanzeige())
        else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final status in [null, ...Bestellstatus.alle])
                  Padding(
                    padding: const EdgeInsets.only(right: Abstand.sm),
                    child: Pille(
                      text: status ?? 'Alle',
                      anzahl: status == null
                          ? alle.length
                          : alle.where((b) => b.status == status).length,
                      aktiv: _status == status,
                      beiTipp: () => setState(() => _status = status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Abstand.md),
          if (gefiltert.isEmpty)
            Hinweisflaeche(
              icon: Icons.inbox_outlined,
              titel: _status == null
                  ? 'Noch keine Bestellungen'
                  : 'Keine Bestellungen mit Status „$_status“',
            ),
          for (final bestellung in gefiltert)
            Padding(
              padding: const EdgeInsets.only(bottom: Abstand.md),
              child: BestellKarte(
                bestellung,
                key: ValueKey(bestellung.bestellungId),
                zeigeKunde: true,
                aktionen: _aktionen(bestellung),
              ),
            ),
        ],
      ],
    );
  }
}
