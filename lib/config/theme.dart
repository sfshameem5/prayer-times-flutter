import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Hex Colors from your React Native project
  static const Color appOrange = Color(0xFFFB8500);
  static const Color appBlue = Color(0xFF0288D1);
  static const Color darkText = Color(0xFF1A202C);
  static const Color navySurface = Color(0xFF14213D);
  static const Color navyDark = Color(0xFF0D1527);
  static const Color navyLight = Color(0xFF1A2744);

  // Gradients
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyLight, navySurface],
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF8F9FA)],
  );

  // Border radius
  static const double cardRadius = 16.0;
  static const double smallRadius = 12.0;

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
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: .08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: darkText, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
          ),
          displaySmall: TextStyle(color: darkText, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: darkText, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: darkText, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: darkText),
          bodyMedium: TextStyle(color: darkText),
          labelLarge: TextStyle(color: darkText, fontWeight: FontWeight.w500),
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
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: appOrange,
        elevation: 0,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          displaySmall: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          labelLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
