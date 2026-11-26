/// Produktkarte für das Katalograster.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/design_tokens.dart';
import '../core/utils/format.dart';
import '../models/produkt.dart';
import '../providers/katalog_provider.dart';
import 'abzeichen.dart';
import 'preis.dart';
import 'produkt_bild.dart';

class ProduktKarte extends StatefulWidget {
  const ProduktKarte(this.produkt, {super.key});

  final Produkt produkt;

  /// Höhe des Textbereichs unter dem quadratischen Bild.
  static const double textHoehe = 118;

  @override
  State<ProduktKarte> createState() => _ProduktKarteState();
}

class _ProduktKarteState extends State<ProduktKarte> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final produkt = widget.produkt;
    final schrift = Theme.of(context).textTheme;
    final zustand = context.select<KatalogProvider, String?>(
      (katalog) => katalog.zustand(produkt.zustandId)?.bezeichnung,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: AppFarben.flaeche,
        borderRadius: BorderRadius.circular(Rundung.lg),
        border: Border.all(color: _hover ? AppFarben.gruen : AppFarben.linie),
        boxShadow: [
          if (_hover)
            BoxShadow(
              color: AppFarben.tinte.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.go('/produkt/${produkt.slug}'),
          onHover: (hover) => setState(() => _hover = hover),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: produkt.ausverkauft ? 0.45 : 1,
                      child: ProduktBild(produkt.bildUrl, beschreibung: produkt.bezeichnung),
                    ),
                    Positioned(
                      top: Abstand.sm + 2,
                      left: Abstand.sm + 2,
                      child: _Etikett(produkt),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ProduktKarte.textHoehe,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Abstand.md,
                    Abstand.sm + 4,
                    Abstand.md,
                    Abstand.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zustand ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: schrift.bodySmall?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        produkt.bezeichnung,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: schrift.titleSmall?.copyWith(fontSize: 15, height: 1.25),
                      ),
                      const Spacer(),
                      Preis(produkt),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etikett extends StatelessWidget {
  const _Etikett(this.produkt);

  final Produkt produkt;

  @override
  Widget build(BuildContext context) {
    if (produkt.ausverkauft) {
      return const Abzeichen(
        'Ausverkauft',
        farbe: Colors.white,
        hintergrund: AppFarben.tinte,
      );
    }
    if (produkt.reduziert) {
      return Abzeichen(
        '−${prozent(produkt.rabattProzent)}',
        farbe: Colors.white,
        hintergrund: AppFarben.terrakotta,
      );
    }
    return const SizedBox.shrink();
  }
}
