/// Zentrales Theme: Farbschema, Typografie und das Aussehen aller Standard-Widgets.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/design_tokens.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme _farben = ColorScheme(
    brightness: Brightness.light,
    primary: AppFarben.gruen,
    onPrimary: Colors.white,
    primaryContainer: AppFarben.gruenHell,
    onPrimaryContainer: AppFarben.gruenDunkel,
    secondary: AppFarben.terrakotta,
    onSecondary: Colors.white,
    // Tonale Schaltflächen nutzen den Secondary-Container - bewusst in Hellgrün
    secondaryContainer: AppFarben.gruenHell,
    onSecondaryContainer: AppFarben.gruenDunkel,
    tertiary: AppFarben.holz,
    onTertiary: Colors.white,
    error: AppFarben.fehler,
    onError: Colors.white,
    errorContainer: AppFarben.fehlerHell,
    onErrorContainer: AppFarben.fehler,
    surface: AppFarben.flaeche,
    onSurface: AppFarben.tinte,
    onSurfaceVariant: AppFarben.tinteGedaempft,
    surfaceContainerLowest: AppFarben.flaeche,
    surfaceContainerLow: AppFarben.papier,
    surfaceContainer: AppFarben.flaecheGetoent,
    surfaceContainerHigh: AppFarben.flaecheGetoent,
    surfaceContainerHighest: AppFarben.flaecheGetoent,
    outline: AppFarben.tinteGedaempft,
    outlineVariant: AppFarben.linie,
  );

  /// Überschriften in der Serifenschrift Fraunces, Fließtext in Inter.
  static TextTheme get _schrift {
    final basis = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).apply(bodyColor: AppFarben.tinte, displayColor: AppFarben.tinte);

    TextStyle ueberschrift(TextStyle? stil, double groesse) =>
        GoogleFonts.fraunces(
          textStyle: stil,
          fontSize: groesse,
          fontWeight: FontWeight.w600,
          height: 1.15,
          letterSpacing: -0.3,
          color: AppFarben.tinte,
        );

    return basis.copyWith(
      displaySmall: ueberschrift(basis.displaySmall, 40),
      headlineLarge: ueberschrift(basis.headlineLarge, 32),
      headlineMedium: ueberschrift(basis.headlineMedium, 26),
      headlineSmall: ueberschrift(basis.headlineSmall, 22),
      titleLarge: basis.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: basis.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: basis.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: basis.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: basis.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
      bodySmall: basis.bodySmall?.copyWith(
        fontSize: 13,
        height: 1.4,
        color: AppFarben.tinteGedaempft,
      ),
      labelLarge: basis.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ThemeData get hell {
    final schrift = _schrift;
    final form = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Rundung.md),
    );
    OutlineInputBorder rand(Color farbe, [double breite = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(Rundung.md),
          borderSide: BorderSide(color: farbe, width: breite),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: _farben,
      textTheme: schrift,
      scaffoldBackgroundColor: AppFarben.papier,
      dividerTheme: const DividerThemeData(
        color: AppFarben.linie,
        space: 1,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppFarben.papier,
        foregroundColor: AppFarben.tinte,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: schrift.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppFarben.flaeche,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rundung.lg),
          side: const BorderSide(color: AppFarben.linie),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: Abstand.lg),
          shape: form,
          textStyle: schrift.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: Abstand.lg),
          shape: form,
          side: const BorderSide(color: AppFarben.linie),
          foregroundColor: AppFarben.tinte,
          textStyle: schrift.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 40),
          shape: form,
          textStyle: schrift.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppFarben.flaeche,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Abstand.md,
          vertical: 14,
        ),
        border: rand(AppFarben.linie),
        enabledBorder: rand(AppFarben.linie),
        focusedBorder: rand(AppFarben.gruen, 2),
        errorBorder: rand(AppFarben.fehler),
        focusedErrorBorder: rand(AppFarben.fehler, 2),
        labelStyle: const TextStyle(color: AppFarben.tinteGedaempft),
        hintStyle: const TextStyle(color: AppFarben.tinteGedaempft),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppFarben.flaeche,
        indicatorColor: AppFarben.gruenHell,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          schrift.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppFarben.tinte,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppFarben.flaeche,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rundung.xl),
        ),
        titleTextStyle: schrift.headlineSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppFarben.tinte,
        contentTextStyle: schrift.bodyMedium?.copyWith(color: Colors.white),
        shape: form,
        insetPadding: const EdgeInsets.all(Abstand.md),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppFarben.flaeche,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rundung.md),
          side: const BorderSide(color: AppFarben.linie),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppFarben.gruen,
      ),
    );
  }
}
