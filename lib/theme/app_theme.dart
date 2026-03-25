import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors (matching the blue gradient UI)
  static const Color primaryBlue = Color(0xFF4361EE);
  static const Color primaryDark = Color(0xFF3A0CA3);
  static const Color accentBlue = Color(0xFF4CC9F0);
  static const Color softPurple = Color(0xFF7B2FBE);

  // Status Colors
  static const Color successGreen = Color(0xFF06D6A0);
  static const Color warningAmber = Color(0xFFFFBE0B);
  static const Color errorRed = Color(0xFFEF233C);
  static const Color infoOrange = Color(0xFFFF6B35);

  // Background
  static const Color bgLight = Color(0xFFF0F2FF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF1A1A2E);

  // Text
  static const Color textPrimary = Color(0xFF1B1F3B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, softPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4361EE), Color(0xFF7B2FBE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentBlue,
        surface: bgLight,
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
