/// Design-Tokens für den Thriftshop: Farben, Abstände, Radien und Breakpoints.
///
/// Widgets verwenden ausschließlich diese Werte bzw. das daraus gebaute Theme -
/// keine frei gewählten Zahlen oder Farben.
library;

import 'package:flutter/material.dart';

/// Abstände im 4-px-Raster.
class Abstand {
  Abstand._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Eckenradien.
class Rundung {
  Rundung._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Layout-Breakpoints (Fensterbreite).
class Breakpoints {
  Breakpoints._();

  /// Ab hier Kopfzeile mit Navigation statt unterer Navigationsleiste.
  static const double desktop = 900;

  /// Maximale Breite des Seiteninhalts.
  static const double inhaltMax = 1200;

  /// Maximale Breite für Formulare und Lesetext.
  static const double schmalMax = 720;
}

/// Farbpalette: warmes Papier, dunkles Grün und das Holzbraun des Logos.
class AppFarben {
  AppFarben._();

  // Marke
  static const Color gruen = Color(0xFF2F6F5E);
  static const Color gruenDunkel = Color(0xFF1D4A3E);
  static const Color gruenHell = Color(0xFFDCEEE7);
  static const Color terrakotta = Color(0xFFC2572F);
  static const Color terrakottaHell = Color(0xFFFBE7DD);
  static const Color holz = Color(0xFF6B4226);

  // Flächen
  static const Color papier = Color(0xFFFAF7F2);
  static const Color flaeche = Color(0xFFFFFFFF);
  static const Color flaecheGetoent = Color(0xFFF2EDE4);
  static const Color linie = Color(0xFFE4DDD1);

  // Text
  static const Color tinte = Color(0xFF1E2420);
  static const Color tinteGedaempft = Color(0xFF5E6862);

  // Status
  static const Color fehler = Color(0xFFB3261E);
  static const Color fehlerHell = Color(0xFFFBE9E7);
  static const Color warnung = Color(0xFF8A5A00);
  static const Color warnungHell = Color(0xFFFFF1D6);
  static const Color info = Color(0xFF1F5F8B);
  static const Color infoHell = Color(0xFFE1F0FA);
}
