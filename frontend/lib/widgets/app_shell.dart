/// Rahmen der App: Kopfzeile mit Navigation (Desktop) bzw. untere Navigationsleiste (Mobil).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/design_tokens.dart';
import '../providers/auth_provider.dart';
import '../providers/warenkorb_provider.dart';
import 'logo.dart';
import 'meldungen.dart';

class _Ziel {
  const _Ziel(this.titel, this.pfad, this.icon, this.iconAktiv);
  final String titel;
  final String pfad;
  final IconData icon;
  final IconData iconAktiv;
}

const _shop = _Ziel('Shop', '/', Icons.storefront_outlined, Icons.storefront);
const _warenkorb = _Ziel(
  'Warenkorb',
  '/warenkorb',
  Icons.shopping_bag_outlined,
  Icons.shopping_bag,
);
const _bestellungen = _Ziel(
  'Bestellungen',
  '/bestellungen',
  Icons.receipt_long_outlined,
  Icons.receipt_long,
);
const _konto = _Ziel('Konto', '/konto', Icons.person_outline, Icons.person);
const _verwaltung = _Ziel(
  'Verwaltung',
  '/admin',
  Icons.dashboard_outlined,
  Icons.dashboard,
);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.pfad, required this.child});

  /// Aktueller Pfad - bestimmt, welcher Navigationspunkt hervorgehoben ist.
  final String pfad;
  final Widget child;

  bool _aktiv(_Ziel ziel) => switch (ziel.pfad) {
    '/' => pfad == '/' || pfad.startsWith('/produkt'),
    '/warenkorb' => pfad.startsWith('/warenkorb') || pfad.startsWith('/checkout'),
    _ => pfad.startsWith(ziel.pfad),
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final breit = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

    if (breit) {
      final ziele = [
        _shop,
        if (auth.angemeldet) _bestellungen,
        if (auth.istPersonal) _verwaltung,
      ];
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: _Kopfzeile(ziele: ziele, aktiv: _aktiv),
        ),
        body: child,
      );
    }

    final ziele = [
      _shop,
      _warenkorb,
      _bestellungen,
      _konto,
      if (auth.istPersonal) _verwaltung,
    ];
    final index = ziele.indexWhere(_aktiv);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: Abstand.md,
        title: InkWell(
          onTap: () => context.go('/'),
          borderRadius: BorderRadius.circular(Rundung.sm),
          child: const Logo(hoehe: 34),
        ),
        shape: const Border(bottom: BorderSide(color: AppFarben.linie)),
      ),
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppFarben.linie)),
        ),
        child: NavigationBar(
          selectedIndex: index < 0 ? 0 : index,
          onDestinationSelected: (i) => context.go(ziele[i].pfad),
          destinations: [
            for (final ziel in ziele)
              NavigationDestination(
                icon: _mitZaehler(context, ziel, Icon(ziel.icon)),
                selectedIcon: _mitZaehler(context, ziel, Icon(ziel.iconAktiv)),
                label: ziel.titel,
              ),
          ],
        ),
      ),
    );
  }

  Widget _mitZaehler(BuildContext context, _Ziel ziel, Widget icon) =>
      ziel == _warenkorb ? _WarenkorbZaehler(child: icon) : icon;
}

/// Zeigt die Artikelanzahl als Badge am Warenkorb-Symbol.
class _WarenkorbZaehler extends StatelessWidget {
  const _WarenkorbZaehler({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anzahl = context.select<WarenkorbProvider, int>((w) => w.anzahl);
    return Badge(
      isLabelVisible: anzahl > 0,
      label: Text('$anzahl'),
      backgroundColor: AppFarben.terrakotta,
      child: child,
    );
  }
}

class _Kopfzeile extends StatelessWidget {
  const _Kopfzeile({required this.ziele, required this.aktiv});

  final List<_Ziel> ziele;
  final bool Function(_Ziel) aktiv;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppFarben.papier,
        border: Border(bottom: BorderSide(color: AppFarben.linie)),
      ),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.inhaltMax + 2 * Abstand.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Abstand.xl),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(Rundung.sm),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: Abstand.xs),
                  child: Logo(hoehe: 44),
                ),
              ),
              const SizedBox(width: Abstand.xl),
              for (final ziel in ziele)
                _NavLink(
                  titel: ziel.titel,
                  aktiv: aktiv(ziel),
                  beiTipp: () => context.go(ziel.pfad),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Warenkorb',
                onPressed: () => context.go('/warenkorb'),
                icon: const _WarenkorbZaehler(child: Icon(Icons.shopping_bag_outlined)),
              ),
              const SizedBox(width: Abstand.sm),
              if (auth.angemeldet)
                const _KontoMenue()
              else
                FilledButton.tonal(
                  onPressed: () => context.go('/login'),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  child: const Text('Anmelden'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.titel, required this.aktiv, required this.beiTipp});

  final String titel;
  final bool aktiv;
  final VoidCallback beiTipp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Abstand.xs),
      child: TextButton(
        onPressed: beiTipp,
        style: TextButton.styleFrom(
          foregroundColor: aktiv ? AppFarben.gruenDunkel : AppFarben.tinteGedaempft,
          backgroundColor: aktiv ? AppFarben.gruenHell : null,
          padding: const EdgeInsets.symmetric(horizontal: Abstand.md),
        ),
        child: Text(titel),
      ),
    );
  }
}

class _KontoMenue extends StatelessWidget {
  const _KontoMenue();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final benutzer = auth.benutzer!;
    final schrift = Theme.of(context).textTheme;

    return PopupMenuButton<String>(
      tooltip: 'Konto',
      position: PopupMenuPosition.under,
      offset: const Offset(0, Abstand.sm),
      onSelected: (wahl) async {
        if (wahl == 'abmelden') {
          await auth.abmelden();
          if (context.mounted) {
            context.go('/');
            meldung(context, 'Du bist abgemeldet.');
          }
        } else {
          context.go(wahl);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(benutzer.name, style: schrift.titleSmall),
              Text(benutzer.email, style: schrift.bodySmall),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: '/konto', child: Text('Mein Konto')),
        const PopupMenuItem(value: '/bestellungen', child: Text('Meine Bestellungen')),
        if (auth.istPersonal)
          const PopupMenuItem(value: '/admin', child: Text('Verwaltung')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'abmelden', child: Text('Abmelden')),
      ],
      child: Padding(
        padding: const EdgeInsets.all(Abstand.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppFarben.gruen,
              child: Text(
                benutzer.initialen,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: Abstand.sm),
            Text(benutzer.vorname, style: schrift.labelLarge),
            const Icon(Icons.expand_more, size: 20, color: AppFarben.tinteGedaempft),
          ],
        ),
      ),
    );
  }
}
