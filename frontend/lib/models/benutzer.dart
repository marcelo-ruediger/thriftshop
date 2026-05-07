/// Das Benutzer-Modell für den Thriftshop
/// Entspricht dem Python-Benutzer-Modell aus dem Backend
library;

import 'dart:convert';

/// Benutzer des Thriftshop-Systems
class Benutzer {
  /// Die eindeutige ID des Benutzers
  final String benutzerId;

  /// Der Vorname des Benutzers
  final String vorname;

  /// Der Nachname des Benutzers
  final String nachname;

  /// Die E-Mail-Adresse des Benutzers
  final String email;

  /// Die Telefonnummer des Benutzers
  final String telefonnummer;

  /// Der Hash des Passworts (nicht das Passwort selbst)
  final String passwortHash;

  /// Die Rolle des Benutzers (z.B. kunde, mitarbeiter, admin)
  final String rolle;

  /// Das Erstellungsdatum des Benutzerkontos
  final DateTime? erstelltAm;

  /// Das Datum der letzten Änderung des Benutzerkontos
  final DateTime? letzteAenderung;

  /// Das Datum des letzten Logins
  final DateTime? letzterLogin;

  /// Konstruktor für Benutzer
  Benutzer({
    required this.benutzerId,
    required this.vorname,
    required this.nachname,
    required this.email,
    required this.telefonnummer,
    required this.passwortHash,
    required this.rolle,
    this.erstelltAm,
    this.letzteAenderung,
    this.letzterLogin,
  });

  /// Erstellt ein Benutzer-Objekt aus JSON
  factory Benutzer.fromJson(Map<String, dynamic> json) {
    return Benutzer(
      benutzerId: json['benutzer_id'] as String,
      vorname: json['vorname'] as String,
      nachname: json['nachname'] as String,
      email: json['email'] as String,
      telefonnummer: json['telefonnummer'] as String,
      passwortHash: json['passwort_hash'] as String,
      rolle: json['rolle'] as String,
      erstelltAm: json['erstellt_am'] == null
          ? null
          : DateTime.parse(json['erstellt_am'] as String),
      letzteAenderung: json['letzte_aenderung'] == null
          ? null
          : DateTime.parse(json['letzte_aenderung'] as String),
      letzterLogin: json['letzter_login'] == null
          ? null
          : DateTime.parse(json['letzter_login'] as String),
    );
  }

  /// Konvertiert das Benutzer-Objekt in JSON
  Map<String, dynamic> toJson() {
    return {
      'benutzer_id': benutzerId,
      'vorname': vorname,
      'nachname': nachname,
      'email': email,
      'telefonnummer': telefonnummer,
      'passwort_hash': passwortHash,
      'rolle': rolle,
      'erstellt_am': erstelltAm?.toIso8601String(),
      'letzte_aenderung': letzteAenderung?.toIso8601String(),
      'letzter_login': letzterLogin?.toIso8601String(),
    };
  }

  /// Konvertiert das Benutzer in einen JSON-String
  String toJsonString() => json.encode(toJson());

  /// Erstellt ein Benutzer-Objekt aus einem JSON-String
  factory Benutzer.fromJsonString(String jsonString) =>
      Benutzer.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
