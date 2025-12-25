import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Defining the core color palette
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF14213D), // Prussian Blue
        onPrimary: Colors.white,

        secondary: Color(0xFFFCA311), // Orange / Gold
        onSecondary: Colors.black, // Black text for contrast on gold

        surface: Colors.white, // Cards and Dialogs
        onSurface: Color(0xFF000000), // Black text

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      // Customizing specific components for a "Premium" feel
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF14213D), // Prussian Blue
        foregroundColor: Colors.white, // White text/icons
        elevation: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFCA311), // Gold Accent
        foregroundColor: Colors.black,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: Colors.black),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF14213D), // Prussian Blue
        onPrimary: Colors.white,

        secondary: Color(0xFFFCA311), // Gold Accent
        onSecondary: Colors.black,

        // In Dark Mode, surfaces are slightly lighter than the background
        surface: Color(0xFF14213D), // Dark Navy surfaces
        onSurface: Color(0xFFE5E5E5), // Alabaster text

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Color(
          0xFFFCA311,
        ), // Gold titles in dark mode look great
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF14213D), // Navy cards on black background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
