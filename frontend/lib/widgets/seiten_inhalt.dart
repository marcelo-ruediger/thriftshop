/// Gemeinsamer Rahmen aller Seiten: scrollbarer, zentrierter Inhalt mit Fußzeile.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';

class SeitenInhalt extends StatelessWidget {
  /// Seite aus Slivers - für lange Listen und Raster, die nur Sichtbares aufbauen.
  const SeitenInhalt({
    super.key,
    required this.slivers,
    this.maxBreite = Breakpoints.inhaltMax,
  });

  /// Seite aus normalen Widgets, die untereinander stehen.
  SeitenInhalt.einfach({
    super.key,
    required List<Widget> children,
    this.maxBreite = Breakpoints.inhaltMax,
  }) : slivers = [
         SliverToBoxAdapter(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: children,
           ),
         ),
       ];

  final List<Widget> slivers;
  final double maxBreite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rand = constraints.maxWidth < 600 ? Abstand.md : Abstand.xl;
        // Inhalt auf maxBreite begrenzen und zentrieren
        final seitlich = math.max(rand, (constraints.maxWidth - maxBreite) / 2);
        final polster = EdgeInsets.symmetric(horizontal: seitlich);

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: Abstand.lg)),
            for (final sliver in slivers) SliverPadding(padding: polster, sliver: sliver),
            // Schiebt die Fußzeile auf kurzen Seiten an den unteren Rand
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Align(alignment: Alignment.bottomCenter, child: _Fusszeile()),
            ),
          ],
        );
      },
    );
  }
}

class _Fusszeile extends StatelessWidget {
  const _Fusszeile();

  @override
  Widget build(BuildContext context) {
    final stil = Theme.of(context).textTheme.bodySmall;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Abstand.xxl),
      padding: const EdgeInsets.symmetric(horizontal: Abstand.lg, vertical: Abstand.lg),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppFarben.linie)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: Abstand.lg,
        runSpacing: Abstand.xs,
        children: [
          Text('Thriftshop Köln – Second-Hand mit Geschichte', style: stil),
          Text('Demo-Projekt: Es werden keine echten Bestellungen ausgelöst.', style: stil),
          Text('Flutter · FastAPI · SQLite', style: stil),
        ],
      ),
    );
  }
}

/// Seitenüberschrift mit optionalem Untertitel und Aktion rechts.
class Seitentitel extends StatelessWidget {
  const Seitentitel(this.titel, {super.key, this.untertitel, this.aktion});

  final String titel;
  final String? untertitel;
  final Widget? aktion;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Abstand.lg),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Abstand.md,
        runSpacing: Abstand.md,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titel, style: schrift.headlineLarge),
              if (untertitel != null) ...[
                const SizedBox(height: Abstand.xs),
                Text(
                  untertitel!,
                  style: schrift.bodyLarge?.copyWith(color: AppFarben.tinteGedaempft),
                ),
              ],
            ],
          ),
          ?aktion,
        ],
      ),
    );
  }
}

/// Karte mit Überschrift - für Formularabschnitte und Zusammenfassungen.
class Abschnitt extends StatelessWidget {
  const Abschnitt({super.key, this.titel, required this.child, this.polster});

  final String? titel;
  final Widget child;
  final EdgeInsetsGeometry? polster;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: polster ?? const EdgeInsets.all(Abstand.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titel != null) ...[
              Text(titel!, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Abstand.md),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
