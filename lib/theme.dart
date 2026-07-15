import 'package:flutter/material.dart';

/// Warm filter-coffee palette. Deliberately un-templated: roasted coffee brown,
/// brass/turmeric accent, and a paper-cream surface — no serif display fonts.
class BrewTheme {
  static const seed = Color(0xFF6F4A2F); // roasted coffee
  static const brass = Color(0xFFC8862B); // filter-coffee brass
  static const cream = Color(0xFFFAF4EA);
  static const espresso = Color(0xFF2A1B12);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF7A4B2B),
      secondary: brass,
      tertiary: const Color(0xFF6B7A4B), // muted decoction green
      surface: cream,
    );
    return _base(scheme, const Color(0xFFF3E9D9));
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFE0B27A),
      secondary: const Color(0xFFE8B863),
      tertiary: const Color(0xFFAEBE86),
      surface: const Color(0xFF1A120C),
    );
    return _base(scheme, const Color(0xFF251A12));
  }

  static ThemeData _base(ColorScheme scheme, Color card) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.4),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2E2016) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF20160E) : Colors.white,
        indicatorColor: scheme.secondary.withValues(alpha: 0.22),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
