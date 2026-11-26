/// Kasse: Zahlungsart wählen und die Bestellung abschicken.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/format.dart';
import '../../models/bestellung.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bestell_provider.dart';
import '../../providers/katalog_provider.dart';
import '../../providers/warenkorb_provider.dart';
import '../../widgets/bestell_widgets.dart';
import '../../widgets/meldungen.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _anmerkung = TextEditingController();
  String _zahlungsart = Zahlungsarten.abholung;
  bool _sendet = false;

  @override
  void dispose() {
    _anmerkung.dispose();
    super.dispose();
  }

  Future<void> _bestellen() async {
    final warenkorb = context.read<WarenkorbProvider>();
    final katalog = context.read<KatalogProvider>();
    final router = GoRouter.of(context);

    setState(() => _sendet = true);
    try {
      final bestellung = await context.read<BestellProvider>().bestellen(
        warenkorb.items,
        zahlungsart: _zahlungsart,
        anmerkung: _anmerkung.text.trim().isEmpty ? null : _anmerkung.text.trim(),
      );
      // Erst weiterleiten, dann leeren - sonst blitzt kurz „Warenkorb ist leer“ auf
      router.go('/bestellungen/${bestellung.bestellungId}/danke');
      warenkorb.leeren();
      katalog.laden(still: true); // Bestände haben sich geändert
    } on ApiFehler catch (fehler) {
      if (!mounted) return;
      setState(() => _sendet = false);
      meldung(context, fehler.nachricht, fehler: true);
      // 409: ein Artikel ist nicht mehr verfügbar - der Warenkorb gleicht sich ab
      if (fehler.status == 409) katalog.laden(still: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final warenkorb = context.watch<WarenkorbProvider>();
    final benutzer = context.watch<AuthProvider>().benutzer;
    final schrift = Theme.of(context).textTheme;

    if (warenkorb.istLeer || benutzer == null) {
      return SeitenInhalt.einfach(
        children: [
          Hinweisflaeche(
            icon: Icons.shopping_bag_outlined,
            titel: 'Hier gibt es noch nichts zu bezahlen',
            text: 'Leg zuerst etwas in den Warenkorb.',
            aktion: () => context.go('/'),
            aktionText: 'Zum Shop',
          ),
        ],
      );
    }

    final angaben = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Abschnitt(
          titel: 'Deine Daten',
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(benutzer.name, style: schrift.titleSmall),
                    Text(benutzer.email, style: schrift.bodyMedium),
                    if (benutzer.telefon != null)
                      Text(benutzer.telefon!, style: schrift.bodyMedium),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/konto'),
                child: const Text('Ändern'),
              ),
            ],
          ),
        ),
        const SizedBox(height: Abstand.md),
        Abschnitt(
          titel: 'Abholung',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.storefront_outlined, color: AppFarben.gruen),
              const SizedBox(width: Abstand.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thriftshop Köln', style: schrift.titleSmall),
                    Text(
                      'Musterstraße 12, 50667 Köln\nDi–Sa 11–19 Uhr',
                      style: schrift.bodyMedium,
                    ),
                    const SizedBox(height: Abstand.xs),
                    Text(
                      'Wir melden uns per E-Mail, sobald alles bereitliegt, und legen die Teile sieben Tage zurück.',
                      style: schrift.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Abstand.md),
        Abschnitt(
          titel: 'Zahlungsart',
          child: Column(
            children: [
              _Auswahl(
                aktiv: _zahlungsart == Zahlungsarten.abholung,
                icon: Icons.point_of_sale_outlined,
                titel: 'Bei Abholung bezahlen',
                text: 'Bar oder mit Karte direkt im Laden.',
                beiTipp: () => setState(() => _zahlungsart = Zahlungsarten.abholung),
              ),
              const SizedBox(height: Abstand.sm),
              _Auswahl(
                aktiv: _zahlungsart == Zahlungsarten.rechnung,
                icon: Icons.description_outlined,
                titel: 'Auf Rechnung',
                text: 'Du erhältst die Rechnung per E-Mail und überweist vor der Abholung.',
                beiTipp: () => setState(() => _zahlungsart = Zahlungsarten.rechnung),
              ),
            ],
          ),
        ),
        const SizedBox(height: Abstand.md),
        Abschnitt(
          titel: 'Anmerkung (optional)',
          child: TextField(
            controller: _anmerkung,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'z. B. „Ich komme am Samstagvormittag vorbei.“',
            ),
          ),
        ),
      ],
    );

    final uebersicht = Abschnitt(
      titel: 'Deine Bestellung',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in warenkorb.items)
            Padding(
              padding: const EdgeInsets.only(bottom: Abstand.sm + 4),
              child: Artikelzeile(
                bildUrl: item.produkt.bildUrl,
                titel: item.produkt.bezeichnung,
                untertitel: '${item.menge} × ${euro(item.produkt.endpreis)}',
                preis: euro(item.summe),
                bildGroesse: 48,
              ),
            ),
          const Divider(),
          const SizedBox(height: Abstand.sm),
          Summenzeile('Zwischensumme', euro(warenkorb.summe)),
          const Summenzeile('Abholung im Laden', 'kostenlos'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Abstand.sm),
            child: Divider(),
          ),
          Summenzeile('Gesamt', euro(warenkorb.summe), hervorgehoben: true),
          Text('inkl. ${euro(warenkorb.mwst)} MwSt.', style: schrift.bodySmall),
          const SizedBox(height: Abstand.lg),
          FilledButton(
            onPressed: _sendet ? null : _bestellen,
            child: _sendet
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Zahlungspflichtig bestellen'),
          ),
          const SizedBox(height: Abstand.sm + 4),
          Text(
            'Das ist ein Demo-Shop: Es wird nichts verschickt und nichts abgebucht.',
            textAlign: TextAlign.center,
            style: schrift.bodySmall,
          ),
        ],
      ),
    );

    return SeitenInhalt.einfach(
      children: [
        const Seitentitel('Kasse'),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 820
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: angaben),
                    const SizedBox(width: Abstand.lg),
                    SizedBox(width: 400, child: uebersicht),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [angaben, const SizedBox(height: Abstand.md), uebersicht],
                ),
        ),
      ],
    );
  }
}

/// Auswählbare Kachel - verhält sich wie ein Radiobutton.
class _Auswahl extends StatelessWidget {
  const _Auswahl({
    required this.aktiv,
    required this.icon,
    required this.titel,
    required this.text,
    required this.beiTipp,
  });

  final bool aktiv;
  final IconData icon;
  final String titel;
  final String text;
  final VoidCallback beiTipp;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: aktiv,
      child: Material(
        color: aktiv ? AppFarben.gruenHell : AppFarben.flaeche,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rundung.md),
          side: BorderSide(
            color: aktiv ? AppFarben.gruen : AppFarben.linie,
            width: aktiv ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: beiTipp,
          child: Padding(
            padding: const EdgeInsets.all(Abstand.md),
            child: Row(
              children: [
                Icon(
                  aktiv ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: aktiv ? AppFarben.gruen : AppFarben.tinteGedaempft,
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
                const SizedBox(width: Abstand.sm),
                Icon(icon, color: AppFarben.tinteGedaempft),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
