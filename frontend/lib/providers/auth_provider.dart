/// Verwaltet die Sitzung: wer ist angemeldet und mit welcher Rolle.
library;

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/benutzer.dart';
import '../services/shop_api.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, this._tokens);

  final ShopApi _api;
  final TokenSpeicher _tokens;

  Benutzer? _benutzer;
  bool _bereit = false;

  Benutzer? get benutzer => _benutzer;

  /// `false`, solange beim Start noch geprüft wird, ob ein gespeichertes Token gültig ist.
  bool get bereit => _bereit;
  bool get angemeldet => _benutzer != null;
  bool get istPersonal => _benutzer?.istPersonal ?? false;
  bool get istAdmin => _benutzer?.istAdmin ?? false;

  /// Stellt beim App-Start die Sitzung aus dem gespeicherten Token wieder her.
  Future<void> initialisieren() async {
    if (_tokens.token != null) {
      try {
        _benutzer = await _api.ich();
      } on ApiFehler catch (fehler) {
        // Nur ein abgelehntes Token verwerfen - bei Netzwerkfehlern bleibt es erhalten
        if (fehler.status == 401) await _tokens.loeschen();
      }
    }
    _bereit = true;
    notifyListeners();
  }

  Future<void> anmelden(String email, String passwort) async =>
      _uebernehmen(await _api.anmelden(email, passwort));

  Future<void> registrieren({
    required String vorname,
    required String nachname,
    required String email,
    required String passwort,
    String? telefon,
  }) async => _uebernehmen(
    await _api.registrieren(
      vorname: vorname,
      nachname: nachname,
      email: email,
      passwort: passwort,
      telefon: telefon,
    ),
  );

  Future<void> _uebernehmen(Anmeldung anmeldung) async {
    await _tokens.speichern(anmeldung.token);
    _benutzer = anmeldung.benutzer;
    notifyListeners();
  }

  Future<void> profilSpeichern({
    required String vorname,
    required String nachname,
    required String email,
    String? telefon,
  }) async {
    _benutzer = await _api.profilSpeichern(
      vorname: vorname,
      nachname: nachname,
      email: email,
      telefon: telefon,
    );
    notifyListeners();
  }

  Future<void> passwortAendern(String aktuell, String neu) =>
      _api.passwortAendern(aktuell, neu);

  Future<void> kontoLoeschen() async {
    await _api.kontoLoeschen();
    await abmelden();
  }

  Future<void> abmelden() async {
    await _tokens.loeschen();
    _benutzer = null;
    notifyListeners();
  }

  /// Vom [ApiClient] aufgerufen, wenn der Server das Token nicht mehr akzeptiert.
  void sitzungAbgelaufen() {
    if (_benutzer == null) return;
    abmelden();
  }
}
