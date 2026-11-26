/// Prüfregeln für Formularfelder. Jede Funktion gibt die Fehlermeldung oder `null` zurück.
library;

final RegExp _emailMuster = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

String? pflichtfeld(String? wert, [String meldung = 'Bitte ausfüllen']) =>
    (wert == null || wert.trim().isEmpty) ? meldung : null;

String? emailPruefen(String? wert) {
  if (wert == null || wert.trim().isEmpty) return 'Bitte gib deine E-Mail-Adresse ein';
  if (!_emailMuster.hasMatch(wert.trim())) return 'Das sieht nicht nach einer E-Mail-Adresse aus';
  return null;
}

String? neuesPasswortPruefen(String? wert) {
  if (wert == null || wert.isEmpty) return 'Bitte wähle ein Passwort';
  if (wert.length < 8) return 'Mindestens 8 Zeichen';
  if (wert.length > 72) return 'Höchstens 72 Zeichen';
  return null;
}
