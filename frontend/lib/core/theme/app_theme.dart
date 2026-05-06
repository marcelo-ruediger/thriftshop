/// Theme-Definition für den Thriftshop
/// Zentrale Definition von Farben, Schriften und Theme-Data

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/design_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.primary),
        foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: Spacing.spacingMd,
            vertical: Spacing.spacingSm,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radius.radiusMd),
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radius.radiusMd),
      ),
      filled: true,
      fillColor: AppColors.white,
    ),
  );
}
