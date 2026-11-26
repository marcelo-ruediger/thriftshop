/// Typisierte Aufrufe aller Backend-Endpunkte. Die Provider sprechen nur mit dieser Klasse.
library;

import 'dart:typed_data';

import '../core/network/api_client.dart';
import '../models/benutzer.dart';
import '../models/bestellung.dart';
import '../models/produkt.dart';
import '../models/stammdaten.dart';

/// Ergebnis von Login und Registrierung.
class Anmeldung {
  const Anmeldung(this.token, this.benutzer);
  final String token;
  final Benutzer benutzer;
}

class ShopApi {
  ShopApi(this._client);

  final ApiClient _client;

  List<T> _liste<T>(dynamic daten, T Function(Map<String, dynamic>) vonJson) =>
      (daten as List).map((e) => vonJson(e as Map<String, dynamic>)).toList();

  Anmeldung _anmeldung(dynamic daten) => Anmeldung(
    daten['access_token'] as String,
    Benutzer.fromJson(daten['benutzer'] as Map<String, dynamic>),
  );

  // --- Authentifizierung & Profil --------------------------------------------

  Future<Anmeldung> anmelden(String email, String passwort) async => _anmeldung(
    await _client.post('/auth/login', daten: {'email': email, 'passwort': passwort}),
  );

  Future<Anmeldung> registrieren({
    required String vorname,
    required String nachname,
    required String email,
    required String passwort,
    String? telefon,
  }) async => _anmeldung(
    await _client.post(
      '/auth/registrieren',
      daten: {
        'vorname': vorname,
        'nachname': nachname,
        'email': email,
        'telefon': telefon,
        'passwort': passwort,
      },
    ),
  );

  Future<Benutzer> ich() async => Benutzer.fromJson(await _client.get('/auth/me'));

  Future<Benutzer> profilSpeichern({
    required String vorname,
    required String nachname,
    required String email,
    String? telefon,
  }) async => Benutzer.fromJson(
    await _client.put(
      '/auth/profil',
      daten: {
        'vorname': vorname,
        'nachname': nachname,
        'email': email,
        'telefon': telefon,
      },
    ),
  );

  Future<void> passwortAendern(String aktuell, String neu) => _client.put(
    '/auth/passwort',
    daten: {'aktuelles_passwort': aktuell, 'neues_passwort': neu},
  );

  Future<void> kontoLoeschen() => _client.delete('/auth/profil');

  // --- Katalog -----------------------------------------------------------------

  Future<List<Produkt>> produkte() async =>
      _liste(await _client.get('/produkte'), Produkt.fromJson);

  Future<List<Kategorie>> kategorien() async =>
      _liste(await _client.get('/kategorien'), Kategorie.fromJson);

  Future<List<Zustand>> zustaende() async =>
      _liste(await _client.get('/zustaende'), Zustand.fromJson);

  // --- Bestellungen ------------------------------------------------------------

  Future<Bestellung> bestellen({
    required Map<String, int> mengen,
    required String zahlungsart,
    String? anmerkung,
  }) async => Bestellung.fromJson(
    await _client.post(
      '/bestellungen',
      daten: {
        'positionen': [
          for (final eintrag in mengen.entries)
            {'produkt_id': eintrag.key, 'menge': eintrag.value},
        ],
        'zahlungsart': zahlungsart,
        'anmerkung': anmerkung,
      },
    ),
  );

  Future<List<Bestellung>> meineBestellungen() async =>
      _liste(await _client.get('/bestellungen/meine'), Bestellung.fromJson);

  Future<Bestellung> bestellung(String id) async =>
      Bestellung.fromJson(await _client.get('/bestellungen/$id'));

  Future<Bestellung> stornieren(String id) async =>
      Bestellung.fromJson(await _client.patch('/bestellungen/$id/stornieren'));

  // --- Verwaltung (Mitarbeiter/Administrator) ----------------------------------

  Future<List<Produkt>> alleProdukte() async =>
      _liste(await _client.get('/produkte/alle'), Produkt.fromJson);

  Future<Produkt> produktAnlegen(ProduktEingabe eingabe) async =>
      Produkt.fromJson(await _client.post('/produkte', daten: eingabe.toJson()));

  Future<Produkt> produktSpeichern(String id, ProduktEingabe eingabe) async =>
      Produkt.fromJson(await _client.put('/produkte/$id', daten: eingabe.toJson()));

  /// Lädt ein Produktbild hoch und gibt den Dateinamen für `bildpfad` zurück.
  Future<String> bildHochladen(Uint8List bytes, String dateiname, String mimeTyp) async {
    final antwort = await _client.hochladen(
      '/produkte/bild',
      feld: 'datei',
      bytes: bytes,
      dateiname: dateiname,
      mimeTyp: mimeTyp,
    );
    return antwort['bildpfad'] as String;
  }

  Future<List<Bestellung>> alleBestellungen() async =>
      _liste(await _client.get('/bestellungen'), Bestellung.fromJson);

  Future<Bestellung> statusAendern(String id, String status) async => Bestellung.fromJson(
    await _client.patch('/bestellungen/$id/status', daten: {'status': status}),
  );

  Future<Statistik> statistik() async =>
      Statistik.fromJson(await _client.get('/bestellungen/statistik'));

  Future<List<Benutzer>> alleBenutzer() async =>
      _liste(await _client.get('/benutzer'), Benutzer.fromJson);

  Future<Benutzer> rolleAendern(String benutzerId, String rolle) async => Benutzer.fromJson(
    await _client.patch('/benutzer/$benutzerId/rolle', daten: {'rolle': rolle}),
  );
}
