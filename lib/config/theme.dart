import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Hex Colors from your React Native project
  static const Color appOrange = Color(0xFFFB8500);
  static const Color appBlue = Color(0xFF0288D1);
  static const Color darkText = Color(0xFF1A202C);
  static const Color navySurface = Color(0xFF14213D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: appOrange,
        onPrimary: Colors.white,
        secondary: appBlue,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: darkText, // Matches your RN light mode text
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: darkText),
          bodyMedium: TextStyle(color: darkText),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black, // True black background
      colorScheme: const ColorScheme.dark(
        primary: appOrange,
        onPrimary: Colors.white,
        secondary:
            appOrange, // In your RN dark mode, everything uses orange accents
        surface: navySurface, // Navy cards on black background
        onSurface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: navySurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: appOrange,
        elevation: 0,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
