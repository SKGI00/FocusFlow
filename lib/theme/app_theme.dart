import 'package:flutter/material.dart';

/// Warm, high-contrast defaults. The design deliberately avoids forced motion.
class AppTheme {
  static const Color sage = Color(0xFF45634F);
  static const Color background = Color(0xFFFCF8F1);
  static const Color ink = Color(0xFF27362E);

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: sage,
          brightness: Brightness.light,
        ).copyWith(
          primary: sage,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFF2DFD0),
          onPrimaryContainer: ink,
          secondaryContainer: const Color(0xFFE6EDD8),
          onSecondaryContainer: ink,
          surface: const Color(0xFFFFFCF8),
          onSurface: ink,
          outline: const Color(0xFF7B857D),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        centerTitle: false,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE3E3D8)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: sage,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
