/// Einstiegspunkt: baut die Abhängigkeiten zusammen und startet die App.
library;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'models/produkt.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bestell_provider.dart';
import 'providers/katalog_provider.dart';
import 'providers/warenkorb_provider.dart';
import 'services/shop_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lesbare Adressen ohne "#": /produkt/lederjacke statt /#/produkt/lederjacke
  usePathUrlStrategy();
  await initializeDateFormatting('de_DE');
  // Schriften vor dem ersten Bild laden, damit der Text nicht nachträglich umspringt.
  // Dauert das zu lange (langsames Netz), startet die App trotzdem.
  await GoogleFonts.pendingFonts([
    for (final gewicht in [FontWeight.w400, FontWeight.w500, FontWeight.w600])
      GoogleFonts.inter(fontWeight: gewicht),
    GoogleFonts.fraunces(fontWeight: FontWeight.w600),
  ]).timeout(const Duration(seconds: 4), onTimeout: () => const []);

  final prefs = await SharedPreferences.getInstance();
  final tokens = TokenSpeicher(prefs);
  final client = ApiClient(tokens);
  final api = ShopApi(client);

  final auth = AuthProvider(api, tokens);
  final katalog = KatalogProvider(api);
  final warenkorb = WarenkorbProvider(prefs);
  final bestellungen = BestellProvider(api);
  final admin = AdminProvider(api);

  client.beiAbgelaufenerSitzung = auth.sitzungAbgelaufen;
  // Der Warenkorb übernimmt aktuelle Preise und Bestände aus dem Katalog
  // (nur wenn die Produktliste neu geladen wurde, nicht bei jedem Filterwechsel)
  List<Produkt>? abgeglichen;
  katalog.addListener(() {
    if (katalog.geladen && !identical(abgeglichen, katalog.produkte)) {
      abgeglichen = katalog.produkte;
      warenkorb.abgleichen(katalog.produkte);
    }
  });
  // Nach dem Abmelden bleiben keine Daten des vorherigen Benutzers im Speicher
  var warAngemeldet = false;
  auth.addListener(() {
    if (warAngemeldet && !auth.angemeldet) {
      bestellungen.leeren();
      admin.leeren();
    }
    warAngemeldet = auth.angemeldet;
  });

  auth.initialisieren();
  katalog.laden();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: katalog),
        ChangeNotifierProvider.value(value: warenkorb),
        ChangeNotifierProvider.value(value: bestellungen),
        ChangeNotifierProvider.value(value: admin),
      ],
      child: const ThriftshopApp(),
    ),
  );
}
