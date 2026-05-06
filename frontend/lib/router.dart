/// Router für die Thriftshop-App
import 'package:flutter/material.dart';

import 'exports.dart';
import 'widgets/main_navigation.dart';
import 'models/produkt.dart';
import 'models/warenkorb_item.dart';

class Routes {
  static const String start = '/';
  static const String produktliste = '/produkte';
  static const String produktdetail = '/produkt-detail';
  static const String warenkorb = '/warenkorb';
  static const String bestell = '/bestellen';
  static const String meineBestellungen = '/meine-bestellungen';
  static const String profil = '/profil';
  static const String adminProduktverwaltung = '/admin/produkte';
  static const String adminBestellverwaltung = '/admin/bestellungen';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.start:
      case Routes.produktliste:
        return MaterialPageRoute(
          builder: (_) => MainNavigation(child: const ProduktListeScreen()),
        );

      case Routes.produktdetail:
        final produkt = settings.arguments as Produkt;
        return MaterialPageRoute(
          builder: (_) => ProduktDetailScreen(produkt: produkt),
        );

      case Routes.warenkorb:
        return MaterialPageRoute(
          builder: (_) => MainNavigation(child: const WarenkorbScreen()),
        );

      case Routes.bestell:
        final items = settings.arguments as List<WarenkorbItem>;
        // Berechne Gesamtpreis aus den Items
        final totalPrice = items.fold(
          0.0,
          (sum, item) => sum + (item.produkt.preis * item.menge),
        );
        return MaterialPageRoute(
          builder: (_) => BestellScreen(items: items, gesamtpreis: totalPrice),
        );

      case Routes.profil:
        return MaterialPageRoute(builder: (_) => const ProfilScreen());

      case Routes.meineBestellungen:
        return MaterialPageRoute(
          builder: (_) =>
              MainNavigation(child: const MeineBestellungenScreen()),
        );

      case Routes.adminProduktverwaltung:
        return MaterialPageRoute(
          builder: (_) =>
              MainNavigation(child: const ProduktverwaltungScreen()),
        );

      case Routes.adminBestellverwaltung:
        return MaterialPageRoute(
          builder: (_) =>
              MainNavigation(child: const BestellverwaltungScreen()),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Keine Route für ${settings.name} gefunden'),
            ),
          ),
        );
    }
  }
}
