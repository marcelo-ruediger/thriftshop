/// Bausteine für Warenkorb, Kasse und Bestellübersichten.
library;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';
import '../core/utils/format.dart';
import '../models/bestellung.dart';
import 'abzeichen.dart';
import 'produkt_bild.dart';

/// Eine Artikelzeile: Bild, Bezeichnung, Zusatzinfo und rechts der Preis.
class Artikelzeile extends StatelessWidget {
  const Artikelzeile({
    super.key,
    required this.bildUrl,
    required this.titel,
    required this.untertitel,
    required this.preis,
    this.bildGroesse = 56,
    this.beiTipp,
  });

  final String? bildUrl;
  final String titel;
  final String untertitel;
  final String preis;
  final double bildGroesse;
  final VoidCallback? beiTipp;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final zeile = Row(
      children: [
        SizedBox.square(
          dimension: bildGroesse,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppFarben.linie),
              borderRadius: BorderRadius.circular(Rundung.sm),
            ),
            child: ProduktBild(bildUrl, rundung: Rundung.sm - 1),
          ),
        ),
        const SizedBox(width: Abstand.sm + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: schrift.titleSmall,
              ),
              Text(untertitel, style: schrift.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: Abstand.sm),
        Text(
          preis,
          style: schrift.titleSmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
    if (beiTipp == null) return zeile;
    return InkWell(
      onTap: beiTipp,
      borderRadius: BorderRadius.circular(Rundung.sm),
      child: zeile,
    );
  }
}

/// Zeile einer Summenaufstellung: Bezeichnung links, Betrag rechts.
class Summenzeile extends StatelessWidget {
  const Summenzeile(this.titel, this.wert, {super.key, this.hervorgehoben = false});

  final String titel;
  final String wert;
  final bool hervorgehoben;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final stil = hervorgehoben
        ? schrift.titleLarge
        : schrift.bodyMedium?.copyWith(color: AppFarben.tinteGedaempft);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Abstand.xs),
      child: Row(
        children: [
          Expanded(child: Text(titel, style: stil)),
          Text(
            wert,
            style: stil?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

/// Karte mit einer Bestellung: Kopf, Positionen, Summe und optionale Aktionen.
class BestellKarte extends StatelessWidget {
  const BestellKarte(
    this.bestellung, {
    super.key,
    this.zeigeKunde = false,
    this.aktionen = const [],
    this.beiArtikelTipp,
  });

  final Bestellung bestellung;

  /// Name und E-Mail des Kunden anzeigen (Bestellverwaltung).
  final bool zeigeKunde;
  final List<Widget> aktionen;
  final void Function(Bestellposition)? beiArtikelTipp;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Abstand.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Abstand.md,
              runSpacing: Abstand.sm,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Bestellung ${bestellung.bestellnr}', style: schrift.titleMedium),
                    Text(datumZeit(bestellung.bestelldatum), style: schrift.bodySmall),
                    if (zeigeKunde && bestellung.kundeName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Abstand.xs),
                        child: Text(
                          '${bestellung.kundeName} · ${bestellung.kundeEmail}',
                          style: schrift.bodyMedium,
                        ),
                      ),
                  ],
                ),
                StatusAbzeichen(bestellung.status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Abstand.md),
              child: Divider(),
            ),
            for (final position in bestellung.positionen)
              Padding(
                padding: const EdgeInsets.only(bottom: Abstand.sm + 4),
                child: Artikelzeile(
                  bildUrl: position.bildUrl,
                  titel: position.bezeichnung ?? 'Artikel',
                  untertitel: '${position.menge} × ${euro(position.stueckpreis)}',
                  preis: euro(position.gesamtpreis),
                  beiTipp: beiArtikelTipp == null
                      ? null
                      : () => beiArtikelTipp!(position),
                ),
              ),
            if (bestellung.anmerkung != null)
              Container(
                margin: const EdgeInsets.only(bottom: Abstand.sm + 4),
                padding: const EdgeInsets.all(Abstand.sm + 4),
                decoration: BoxDecoration(
                  color: AppFarben.papier,
                  borderRadius: BorderRadius.circular(Rundung.sm),
                ),
                child: Text('Anmerkung: ${bestellung.anmerkung}', style: schrift.bodySmall),
              ),
            const Divider(),
            const SizedBox(height: Abstand.sm + 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '${bestellung.zahlungsart} · inkl. ${euro(bestellung.enthalteneMwst)} MwSt.',
                    style: schrift.bodySmall,
                  ),
                ),
                Text(
                  euro(bestellung.gesamtpreis),
                  style: schrift.titleLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (aktionen.isNotEmpty) ...[
              const SizedBox(height: Abstand.md),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: Abstand.sm,
                runSpacing: Abstand.sm,
                children: aktionen,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
