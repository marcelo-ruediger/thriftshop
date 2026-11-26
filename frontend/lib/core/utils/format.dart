/// Formatierung von Geldbeträgen und Datumsangaben im deutschen Format.
library;

import 'package:intl/intl.dart';

final NumberFormat _euro = NumberFormat.currency(locale: 'de_DE', symbol: '€');
final NumberFormat _prozent = NumberFormat('0.##', 'de_DE');
final DateFormat _datum = DateFormat('dd.MM.yyyy', 'de_DE');
final DateFormat _datumZeit = DateFormat("dd.MM.yyyy, HH:mm 'Uhr'", 'de_DE');

/// 12.5 -> "12,50 €"
String euro(num betrag) => _euro.format(betrag);

/// 20 -> "20 %"
String prozent(num wert) => '${_prozent.format(wert)} %';

/// Datum in Ortszeit, z.B. "26.11.2026"
String datum(DateTime zeitpunkt) => _datum.format(zeitpunkt.toLocal());

/// Datum und Uhrzeit in Ortszeit, z.B. "26.11.2026, 14:05 Uhr"
String datumZeit(DateTime zeitpunkt) => _datumZeit.format(zeitpunkt.toLocal());
