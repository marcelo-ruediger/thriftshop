/// Daten der Verwaltung: alle Produkte, alle Bestellungen, Kennzahlen und Benutzer.
library;


import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/benutzer.dart';
import '../models/bestellung.dart';
import '../models/produkt.dart';
import '../services/shop_api.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider(this._api);

  final ShopApi _api;

  /// So viele Bestellungen lädt die Bestellverwaltung höchstens (die neuesten).
  static const int bestellLimit = 200;

  List<Produkt>? _produkte;
  List<Bestellung>? _bestellungen;
  List<Bestellung>? _neuesteBestellungen;
  List<Benutzer>? _benutzer;
  Statistik? _statistik;
  String? _fehler;

  /// Jeweils `null`, solange noch nicht geladen.
  List<Produkt>? get produkte => _produkte;
  List<Bestellung>? get bestellungen => _bestellungen;

  /// Die fünf neuesten Bestellungen für die Übersicht.
  List<Bestellung>? get neuesteBestellungen => _neuesteBestellungen;
  List<Benutzer>? get benutzer => _benutzer;
  Statistik? get statistik => _statistik;
  String? get fehler => _fehler;

  Future<void> _laden(Future<void> Function() aktion) async {
    _fehler = null;
    try {
      await aktion();
    } on ApiFehler catch (fehler) {
      _fehler = fehler.nachricht;
    }
    notifyListeners();
  }

  Future<void> uebersichtLaden() => _laden(() async {
    final ergebnisse = await Future.wait([
      _api.statistik(),
      _api.alleBestellungen(limit: 5),
    ]);
    _statistik = ergebnisse[0] as Statistik;
    _neuesteBestellungen = ergebnisse[1] as List<Bestellung>;
  });

  Future<void> produkteLaden() =>
      _laden(() async => _produkte = await _api.alleProdukte());

  Future<void> bestellungenLaden() =>
      _laden(() async => _bestellungen = await _api.alleBestellungen(limit: bestellLimit));

  Future<void> benutzerLaden() =>
      _laden(() async => _benutzer = await _api.alleBenutzer());

  // --- Änderungen (werfen ApiFehler, die Screens zeigen die Meldung) -------------

  Future<String> bildHochladen(Uint8List bytes, String dateiname, String mimeTyp) =>
      _api.bildHochladen(bytes, dateiname, mimeTyp);

  Future<void> produktAnlegen(ProduktEingabe eingabe) async {
    final produkt = await _api.produktAnlegen(eingabe);
    _produkte = [produkt, ...?_produkte];
    notifyListeners();
  }

  Future<void> produktSpeichern(String produktId, ProduktEingabe eingabe) async {
    final produkt = await _api.produktSpeichern(produktId, eingabe);
    _produkte = [
      for (final p in _produkte ?? const <Produkt>[])
        p.produktId == produktId ? produkt : p,
    ];
    notifyListeners();
  }

  Future<void> sichtbarkeitAendern(String produktId, bool aktiv) async {
    final produkt = await _api.sichtbarkeitSetzen(produktId, aktiv);
    _produkte = [
      for (final p in _produkte ?? const <Produkt>[])
        p.produktId == produktId ? produkt : p,
    ];
    notifyListeners();
  }

  Future<void> statusAendern(String bestellungId, String status) async {
    final bestellung = await _api.statusAendern(bestellungId, status);
    _bestellungen = [
      for (final b in _bestellungen ?? const <Bestellung>[])
        b.bestellungId == bestellungId ? bestellung : b,
    ];
    notifyListeners();
  }

  Future<void> rolleAendern(String benutzerId, String rolle) async {
    final geaendert = await _api.rolleAendern(benutzerId, rolle);
    _benutzer = [
      for (final b in _benutzer ?? const <Benutzer>[])
        b.benutzerId == benutzerId ? geaendert : b,
    ];
    notifyListeners();
  }

  /// Beim Abmelden: nichts vom vorherigen Benutzer behalten.
  void leeren() {
    _produkte = null;
    _bestellungen = null;
    _neuesteBestellungen = null;
    _benutzer = null;
    _statistik = null;
    _fehler = null;
    notifyListeners();
  }
}
