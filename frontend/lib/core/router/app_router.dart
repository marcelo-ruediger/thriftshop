/// Alle Routen der App und die Zugriffsregeln (Anmeldung, Rolle).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/admin/admin_benutzer_screen.dart';
import '../../screens/admin/admin_bestellungen_screen.dart';
import '../../screens/admin/admin_produkte_screen.dart';
import '../../screens/admin/admin_uebersicht_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/registrieren_screen.dart';
import '../../screens/bestellung/bestaetigung_screen.dart';
import '../../screens/bestellung/checkout_screen.dart';
import '../../screens/bestellung/meine_bestellungen_screen.dart';
import '../../screens/katalog/katalog_screen.dart';
import '../../screens/katalog/produkt_screen.dart';
import '../../screens/konto/konto_screen.dart';
import '../../screens/warenkorb/warenkorb_screen.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/seiten_inhalt.dart';
import '../../widgets/zustands_anzeigen.dart';

/// Bereiche, die eine Anmeldung voraussetzen.
const _geschuetzt = ['/checkout', '/bestellungen', '/konto', '/admin'];
const _anmeldeseiten = ['/login', '/registrieren'];

GoRouter routerErstellen(AuthProvider auth) {
  return GoRouter(
    // Wertet die Regeln neu aus, sobald sich der Anmeldestatus ändert
    refreshListenable: auth,
    redirect: (context, state) {
      // Beim Start erst abwarten, ob ein gespeichertes Token noch gültig ist
      if (!auth.bereit) return null;

      final pfad = state.matchedLocation;
      final braucht = _geschuetzt.any(pfad.startsWith);

      if (!auth.angemeldet && braucht) {
        // Nach dem Login geht es zurück zur gewünschten Seite
        return Uri(path: '/login', queryParameters: {'weiter': state.uri.toString()})
            .toString();
      }
      if (auth.angemeldet && _anmeldeseiten.contains(pfad)) {
        return state.uri.queryParameters['weiter'] ?? '/';
      }
      if (pfad.startsWith('/admin') && !auth.istPersonal) return '/';
      if (pfad.startsWith('/admin/benutzer') && !auth.istAdmin) return '/admin';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(weiter: state.uri.queryParameters['weiter']),
      ),
      GoRoute(
        path: '/registrieren',
        builder: (context, state) =>
            RegistrierenScreen(weiter: state.uri.queryParameters['weiter']),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(pfad: state.matchedLocation, child: child),
        routes: [
          _seite('/', (state) => const KatalogScreen()),
          _seite(
            '/produkt/:slug',
            (state) => ProduktScreen(slug: state.pathParameters['slug']!),
          ),
          _seite('/warenkorb', (state) => const WarenkorbScreen()),
          _seite('/checkout', (state) => const CheckoutScreen()),
          _seite('/bestellungen', (state) => const MeineBestellungenScreen()),
          _seite(
            '/bestellungen/:id/danke',
            (state) => BestaetigungScreen(bestellungId: state.pathParameters['id']!),
          ),
          _seite('/konto', (state) => const KontoScreen()),
          _seite('/admin', (state) => const AdminUebersichtScreen()),
          _seite('/admin/produkte', (state) => const AdminProdukteScreen()),
          _seite('/admin/bestellungen', (state) => const AdminBestellungenScreen()),
          _seite('/admin/benutzer', (state) => const AdminBenutzerScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => AppShell(
      pfad: '',
      child: SeitenInhalt.einfach(
        children: [
          Hinweisflaeche(
            icon: Icons.explore_off_outlined,
            titel: 'Diese Seite gibt es nicht',
            text: 'Vielleicht wurde der Artikel schon verkauft – im Shop findest du alles, was noch da ist.',
            aktion: () => context.go('/'),
            aktionText: 'Zum Shop',
          ),
        ],
      ),
    ),
  );
}

/// Route ohne Übergangsanimation - im Web fühlt sich das wie ein Seitenwechsel an.
GoRoute _seite(String pfad, Widget Function(GoRouterState) seite) => GoRoute(
  path: pfad,
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: seite(state)),
);
