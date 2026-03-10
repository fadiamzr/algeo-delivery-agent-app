import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark Palette ──
  static const Color primaryDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF1C2333);
  static const Color borderDark = Color(0xFF30363D);

  // ── Light Palette ──
  static const Color primaryLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF0F2F5);
  static const Color borderLight = Color(0xFFD0D7DE);

  // ── Accent Colors ──
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentGold = Color(0xFFD4A843);

  // ── Semantic Colors ──
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningYellow = Color(0xFFEAB308);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // ── Text Colors (Dark) ──
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);

  // ── Text Colors (Light) ──
  static const Color textPrimaryLight = Color(0xFF1F2328);
  static const Color textSecondaryLight = Color(0xFF656D76);
  static const Color textMutedLight = Color(0xFF8C959F);

  // Score colors (universal)
  static Color getScoreColor(double score) {
    if (score >= 0.8) return successGreen;
    if (score >= 0.5) return warningYellow;
    return errorRed;
  }

  static String getScoreLabel(double score) {
    if (score >= 0.8) return 'High Confidence';
    if (score >= 0.5) return 'Medium Confidence';
    return 'Low Confidence';
  }

  // Status colors (universal)
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return accentAmber;
      case 'in progress':
        return infoBlue;
      case 'completed':
        return successGreen;
      case 'failed':
        return errorRed;
      default:
        return textMuted;
    }
  }

  // ════════════════════ DARK THEME ════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: accentAmber,
      colorScheme: const ColorScheme.dark(
        primary: accentAmber,
        secondary: accentOrange,
        surface: surfaceDark,
        surfaceContainerHighest: cardDark,
        outline: borderDark,
        error: errorRed,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        onError: textPrimary,
      ),
      textTheme: _buildTextTheme(
        primary: textPrimary,
        secondary: textSecondary,
        muted: textMuted,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: _buildInputDecoration(
        fillColor: cardDark,
        borderColor: borderDark,
        hintColor: textMuted,
        labelColor: textSecondary,
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentAmber,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: borderDark, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        side: const BorderSide(color: borderDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentAmber,
        foregroundColor: primaryDark,
      ),
    );
  }

  // ════════════════════ LIGHT THEME ════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryLight,
      primaryColor: accentAmber,
      colorScheme: const ColorScheme.light(
        primary: accentAmber,
        secondary: accentOrange,
        surface: surfaceLight,
        surfaceContainerHighest: cardLight,
        outline: borderLight,
        error: errorRed,
        onPrimary: primaryLight,
        onSecondary: primaryLight,
        onSurface: textPrimaryLight,
        onSurfaceVariant: textSecondaryLight,
        onError: primaryLight,
      ),
      textTheme: _buildTextTheme(
        primary: textPrimaryLight,
        secondary: textSecondaryLight,
        muted: textMutedLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: _buildInputDecoration(
        fillColor: cardLight,
        borderColor: borderLight,
        hintColor: textMutedLight,
        labelColor: textSecondaryLight,
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: accentAmber,
        unselectedItemColor: textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: borderLight, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: cardLight,
        side: const BorderSide(color: borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(color: textPrimaryLight, fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentAmber,
        foregroundColor: primaryLight,
      ),
    );
  }

  // ── Shared builders ──

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color muted,
  }) {
    return GoogleFonts.outfitTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: secondary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: muted),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecoration({
    required Color fillColor,
    required Color borderColor,
    required Color hintColor,
    required Color labelColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentAmber, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: hintColor),
      labelStyle: TextStyle(color: labelColor),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentAmber,
        foregroundColor: primaryDark,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentAmber,
        side: const BorderSide(color: accentAmber),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
