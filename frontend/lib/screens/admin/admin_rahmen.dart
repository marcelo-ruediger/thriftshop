/// Gemeinsamer Rahmen der Verwaltung: Überschrift und Reiter zu den Unterseiten.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/seiten_inhalt.dart';

class AdminRahmen extends StatelessWidget {
  const AdminRahmen({
    super.key,
    required this.pfad,
    required this.titel,
    required this.children,
    this.untertitel,
    this.aktion,
  });

  /// Pfad der aktuellen Unterseite - bestimmt den aktiven Reiter.
  final String pfad;
  final String titel;
  final String? untertitel;
  final Widget? aktion;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final istAdmin = context.watch<AuthProvider>().istAdmin;
    final reiter = [
      ('Übersicht', '/admin', Icons.dashboard_outlined),
      ('Produkte', '/admin/produkte', Icons.inventory_2_outlined),
      ('Bestellungen', '/admin/bestellungen', Icons.receipt_long_outlined),
      // Rollen vergeben dürfen nur Administratoren, nicht Mitarbeiter
      if (istAdmin) ('Benutzer', '/admin/benutzer', Icons.group_outlined),
    ];

    return SeitenInhalt.einfach(
      children: [
        Seitentitel(titel, untertitel: untertitel, aktion: aktion),
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppFarben.linie)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (name, ziel, icon) in reiter)
                  _Reiter(
                    name: name,
                    icon: icon,
                    aktiv: ziel == pfad,
                    beiTipp: () => context.go(ziel),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Abstand.lg),
        ...children,
      ],
    );
  }
}

class _Reiter extends StatelessWidget {
  const _Reiter({
    required this.name,
    required this.icon,
    required this.aktiv,
    required this.beiTipp,
  });

  final String name;
  final IconData icon;
  final bool aktiv;
  final VoidCallback beiTipp;

  @override
  Widget build(BuildContext context) {
    final farbe = aktiv ? AppFarben.gruenDunkel : AppFarben.tinteGedaempft;
    return Semantics(
      selected: aktiv,
      child: InkWell(
        onTap: beiTipp,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Abstand.md, vertical: Abstand.sm + 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: aktiv ? AppFarben.gruen : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: farbe),
              const SizedBox(width: Abstand.sm),
              Text(
                name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: farbe),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
