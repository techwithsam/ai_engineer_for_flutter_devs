import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color xBlue = Color(0xFF1D9BF0);
  static const Color xBlack = Color(0xFF000000);
  static const Color xDarkCard = Color(0xFF16181C);
  static const Color xDarkBorder = Color(0xFF2F3336);
  static const Color xDarkTextPrimary = Color(0xFFE7E9EA);
  static const Color xDarkTextSecondary = Color(0xFF71767B);

  static const Color xWhite = Color(0xFFFFFFFF);
  static const Color xLightCard = Color(0xFFF7F9F9);
  static const Color xLightBorder = Color(0xFFCFD9DE);
  static const Color xLightTextPrimary = Color(0xFF0F1419);
  static const Color xLightTextSecondary = Color(0xFF536471);

  // Status & Badge Colors
  static const Color xSuccessGreen = Color(0xFF00BA7C);
  static const Color xDangerRed = Color(0xFFF4212E);
  static const Color xWarningYellow = Color(0xFFFFD400);
  static const Color xCloudPurple = Color(0xFF7856FF);

  /// Light Mode 
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: xWhite,
      colorScheme: const ColorScheme.light(
        primary: xBlue,
        secondary: xCloudPurple,
        surface: xLightCard,
        outline: xLightBorder,
        onSurface: xLightTextPrimary,
        onSurfaceVariant: xLightTextSecondary,
        error: xDangerRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: xWhite,
        foregroundColor: xLightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: xLightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: xLightBorder, width: 1),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: const TextStyle(color: xLightTextPrimary),
        bodyMedium: const TextStyle(color: xLightTextSecondary),
      ),
    );
  }

  /// Dark Mode
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: xBlack,
      colorScheme: const ColorScheme.dark(
        primary: xBlue,
        secondary: xCloudPurple,
        surface: xDarkCard,
        outline: xDarkBorder,
        onSurface: xDarkTextPrimary,
        onSurfaceVariant: xDarkTextSecondary,
        error: xDangerRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: xBlack,
        foregroundColor: xDarkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: xDarkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: xDarkBorder, width: 1),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: xDarkTextPrimary),
        bodyMedium: const TextStyle(color: xDarkTextSecondary),
      ),
    );
  }
}
