/// Verwaltung - Produkte anlegen, bearbeiten und aus dem Shop nehmen.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/format.dart';
import '../../models/produkt.dart';
import '../../providers/admin_provider.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/abzeichen.dart';
import '../../widgets/meldungen.dart';
import '../../widgets/pille.dart';
import '../../widgets/produkt_bild.dart';
import '../../widgets/zustands_anzeigen.dart';
import 'admin_rahmen.dart';
import 'produkt_dialog.dart';

enum _Filter {
  alle('Alle'),
  aktiv('Im Shop'),
  ausverkauft('Ausverkauft'),
  inaktiv('Deaktiviert');

  const _Filter(this.titel);
  final String titel;

  bool passt(Produkt p) => switch (this) {
    alle => true,
    aktiv => p.produktAktiv,
    ausverkauft => p.produktAktiv && p.ausverkauft,
    inaktiv => !p.produktAktiv,
  };
}

class AdminProdukteScreen extends StatefulWidget {
  const AdminProdukteScreen({super.key});

  @override
  State<AdminProdukteScreen> createState() => _AdminProdukteScreenState();
}

class _AdminProdukteScreenState extends State<AdminProdukteScreen> {
  String _suche = '';
  _Filter _filter = _Filter.alle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminProvider>().produkteLaden();
    });
  }

  Future<void> _bearbeiten([Produkt? produkt]) async {
    final gespeichert = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProduktDialog(produkt: produkt),
    );
    if (gespeichert == true && mounted) {
      meldung(context, produkt == null ? 'Produkt angelegt.' : 'Änderungen gespeichert.');
      context.read<KatalogProvider>().laden(still: true);
    }
  }

  Future<void> _sichtbarkeit(Produkt produkt, bool aktiv) async {
    try {
      await context.read<AdminProvider>().produktSpeichern(
        produkt.produktId,
        ProduktEingabe.von(produkt, produktAktiv: aktiv),
      );
      if (!mounted) return;
      meldung(
        context,
        aktiv
            ? '„${produkt.bezeichnung}“ ist wieder im Shop.'
            : '„${produkt.bezeichnung}“ ist nicht mehr im Shop sichtbar.',
      );
      context.read<KatalogProvider>().laden(still: true);
    } on ApiFehler catch (fehler) {
      if (mounted) meldung(context, fehler.nachricht, fehler: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final alle = admin.produkte;
    final begriff = _suche.toLowerCase();
    final gefiltert = alle
        ?.where(
          (p) =>
              _filter.passt(p) &&
              (begriff.isEmpty ||
                  p.bezeichnung.toLowerCase().contains(begriff) ||
                  p.produktnr.toLowerCase().contains(begriff)),
        )
        .toList();

    return AdminRahmen(
      pfad: '/admin/produkte',
      titel: 'Produkte',
      untertitel: 'Deaktivierte Produkte bleiben für alte Bestellungen erhalten.',
      aktion: FilledButton.icon(
        onPressed: () => _bearbeiten(),
        icon: const Icon(Icons.add),
        label: const Text('Neues Produkt'),
      ),
      children: [
        if (alle == null || gefiltert == null)
          admin.fehler != null
              ? Hinweisflaeche.fehler(
                  nachricht: admin.fehler!,
                  erneutVersuchen: admin.produkteLaden,
                )
              : const SizedBox(height: 320, child: Ladeanzeige())
        else ...[
          TextField(
            onChanged: (wert) => setState(() => _suche = wert.trim()),
            decoration: const InputDecoration(
              hintText: 'Nach Bezeichnung oder Artikelnummer suchen',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: Abstand.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: Abstand.sm),
                    child: Pille(
                      text: filter.titel,
                      anzahl: alle.where(filter.passt).length,
                      aktiv: _filter == filter,
                      beiTipp: () => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Abstand.md),
          if (gefiltert.isEmpty)
            const Hinweisflaeche(
              icon: Icons.search_off,
              titel: 'Kein Produkt gefunden',
              text: 'Ändere die Suche oder den Filter.',
            )
          else
            Card(
              child: Column(
                children: [
                  for (final (index, produkt) in gefiltert.indexed) ...[
                    if (index > 0) const Divider(),
                    _Zeile(
                      produkt,
                      key: ValueKey(produkt.produktId),
                      beiBearbeiten: () => _bearbeiten(produkt),
                      beiSichtbarkeit: (aktiv) => _sichtbarkeit(produkt, aktiv),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile(
    this.produkt, {
    super.key,
    required this.beiBearbeiten,
    required this.beiSichtbarkeit,
  });

  final Produkt produkt;
  final VoidCallback beiBearbeiten;
  final ValueChanged<bool> beiSichtbarkeit;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final katalog = context.watch<KatalogProvider>();
    final kategorie = katalog.kategorie(produkt.kategorieId)?.bezeichnung ?? '–';
    final breit = MediaQuery.sizeOf(context).width >= 760;

    final bestand = produkt.ausverkauft
        ? const Abzeichen(
            'Ausverkauft',
            farbe: AppFarben.warnung,
            hintergrund: AppFarben.warnungHell,
            icon: Icons.remove_shopping_cart_outlined,
          )
        : Text('${produkt.lagerbestand} auf Lager', style: schrift.bodyMedium);
    final preis = Text(
      produkt.reduziert
          ? '${euro(produkt.endpreis)} (−${prozent(produkt.rabattProzent)})'
          : euro(produkt.endpreis),
      style: schrift.titleSmall?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    return InkWell(
      onTap: beiBearbeiten,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Abstand.md, vertical: Abstand.sm + 4),
        child: Row(
          children: [
            Opacity(
              opacity: produkt.produktAktiv ? 1 : 0.45,
              child: SizedBox.square(
                dimension: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppFarben.linie),
                    borderRadius: BorderRadius.circular(Rundung.sm),
                  ),
                  child: ProduktBild(produkt.bildUrl, rundung: Rundung.sm - 1),
                ),
              ),
            ),
            const SizedBox(width: Abstand.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produkt.bezeichnung,
                    style: schrift.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${produkt.produktnr} · $kategorie',
                    style: schrift.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!breit) ...[
                    const SizedBox(height: Abstand.xs),
                    Wrap(
                      spacing: Abstand.sm + 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [preis, bestand],
                    ),
                  ],
                ],
              ),
            ),
            if (breit) ...[
              SizedBox(width: 150, child: Align(alignment: Alignment.centerLeft, child: bestand)),
              SizedBox(width: 150, child: Align(alignment: Alignment.centerRight, child: preis)),
              const SizedBox(width: Abstand.md),
            ],
            Tooltip(
              message: produkt.produktAktiv ? 'Im Shop sichtbar' : 'Deaktiviert',
              child: Switch(value: produkt.produktAktiv, onChanged: beiSichtbarkeit),
            ),
            IconButton(
              tooltip: 'Bearbeiten',
              icon: const Icon(Icons.edit_outlined),
              onPressed: beiBearbeiten,
            ),
          ],
        ),
      ),
    );
  }
}
