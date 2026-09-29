import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryNavy = Color(0xFF0A192F);
  static const Color secondaryNavy = Color(0xFF112240);
  static const Color accentCyan = Color(0xFF64FFDA);
  static const Color textMain = Color(0xFFE6F1FF);
  static const Color textMuted = Color(0xFF8892B0);

  // Status Colors
  static const Color statusHealthy = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusCritical = Color(0xFFEF4444);
  static const Color statusNeutral = Color(0xFF3B82F6);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentCyan,
      scaffoldBackgroundColor: primaryNavy,
      cardColor: secondaryNavy,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: statusNeutral,
        surface: secondaryNavy,
        error: statusCritical,
      ),
      fontFamily: 'Roboto', // Professional default
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryNavy,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: accentCyan),
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      dividerColor: const Color(0xFF233554),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: textMain, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            color: textMain, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textMain, fontSize: 16),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: secondaryNavy,
        selectedIconTheme: IconThemeData(color: accentCyan),
        unselectedIconTheme: IconThemeData(color: textMuted),
        selectedLabelTextStyle:
            TextStyle(color: accentCyan, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: textMuted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF233554)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryNavy,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF233554)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: secondaryNavy,
        contentTextStyle: TextStyle(color: textMain),
      ),
      iconTheme: const IconThemeData(color: textMuted),
    );
  }
}
