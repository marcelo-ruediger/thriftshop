/// Design Tokens für den Thriftshop
/// Zentrale Definition von Abständen, Farben und Radien
library;

import 'package:flutter/material.dart';

/// Abstand-Tokens
class Spacing {
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
}

/// Radius-Tokens
class Radius {
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
}

/// Farb-Schema für den Thriftshop
/// basierend auf dem UI/UX Leitfaden
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF93);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF81C784);

  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color error = Color(0xFFE53935);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
}
