/// Benutzerkonto - entspricht `BenutzerAusgabe` im Backend (ohne Passwort-Hash).
library;

class Rollen {
  Rollen._();
  static const String administrator = 'Administrator';
  static const String mitarbeiter = 'Mitarbeiter';
  static const String kunde = 'Kunde';
  static const List<String> alle = [kunde, mitarbeiter, administrator];
}

class Benutzer {
  const Benutzer({
    required this.benutzerId,
    required this.vorname,
    required this.nachname,
    required this.email,
    required this.rolle,
    this.telefon,
    this.erstelltAm,
    this.letzterLogin,
  });

  final String benutzerId;
  final String vorname;
  final String nachname;
  final String email;
  final String? telefon;
  final String rolle;
  final DateTime? erstelltAm;
  final DateTime? letzterLogin;

  String get name => '$vorname $nachname'.trim();

  String get initialen {
    final v = vorname.isNotEmpty ? vorname[0] : '';
    final n = nachname.isNotEmpty ? nachname[0] : '';
    return (v + n).toUpperCase();
  }

  bool get istAdmin => rolle == Rollen.administrator;

  /// Mitarbeiter und Administratoren dürfen in die Verwaltung.
  bool get istPersonal => istAdmin || rolle == Rollen.mitarbeiter;

  factory Benutzer.fromJson(Map<String, dynamic> json) => Benutzer(
    benutzerId: json['benutzer_id'] as String,
    vorname: json['vorname'] as String,
    nachname: json['nachname'] as String,
    email: json['email'] as String,
    telefon: json['telefon'] as String?,
    rolle: json['rolle'] as String,
    erstelltAm: _zeit(json['erstellt_am']),
    letzterLogin: _zeit(json['letzter_login']),
  );
}

DateTime? _zeit(dynamic wert) => wert == null ? null : DateTime.parse(wert as String);
