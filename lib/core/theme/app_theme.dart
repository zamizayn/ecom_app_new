import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Blue from design

  static TextTheme _buildTextTheme(TextTheme base) {
    // GoogleFonts.poppinsTextTheme may leave some styles with null fontSize.
    // .apply(fontSizeFactor:) asserts fontSize != null, so we scale manually.
    final poppins = GoogleFonts.poppinsTextTheme(base);
    TextStyle? scale(TextStyle? s) =>
        s == null ? null : (s.fontSize != null ? s.copyWith(fontSize: s.fontSize! * 0.9) : s);
    return poppins.copyWith(
      displayLarge:   scale(poppins.displayLarge),
      displayMedium:  scale(poppins.displayMedium),
      displaySmall:   scale(poppins.displaySmall),
      headlineLarge:  scale(poppins.headlineLarge),
      headlineMedium: scale(poppins.headlineMedium),
      headlineSmall:  scale(poppins.headlineSmall),
      titleLarge:     scale(poppins.titleLarge),
      titleMedium:    scale(poppins.titleMedium),
      titleSmall:     scale(poppins.titleSmall),
      bodyLarge:      scale(poppins.bodyLarge),
      bodyMedium:     scale(poppins.bodyMedium),
      bodySmall:      scale(poppins.bodySmall),
      labelLarge:     scale(poppins.labelLarge),
      labelMedium:    scale(poppins.labelMedium),
      labelSmall:     scale(poppins.labelSmall),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[50],
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Pill shape for main buttons
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      )
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
