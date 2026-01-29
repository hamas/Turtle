import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seedColor = Color(0xFF4CAF50); // A "Turtle" green seed

  static ThemeData get lightTheme {
    return createTheme(
      ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light),
    );
  }

  static ThemeData get darkTheme {
    return createTheme(
      ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
    );
  }

  static ThemeData createTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme:
          GoogleFonts.outfitTextTheme(
            colorScheme.brightness == Brightness.dark
                ? ThemeData.dark().textTheme
                : ThemeData.light().textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 57,
            ),
            displayMedium: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 45,
            ),
            displaySmall: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 36,
            ),
            headlineLarge: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
            headlineMedium: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
            headlineSmall: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
            titleLarge: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
