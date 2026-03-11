import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F4FA3),
    ),

    scaffoldBackgroundColor: Colors.white,

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),

     textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFF35424A),
        fontWeight: FontWeight.bold,
        fontFamily: "Quicksand",
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF989EB1),
        fontFamily: "Quicksand",
        fontWeight: FontWeight.normal
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF1F4FA3),
        fontFamily: "Asap",
        fontWeight: FontWeight.w700,
        fontSize: 14
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F4FA3),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: "Asap",
          fontWeight: FontWeight.w700,
          fontSize: 17
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
  );
}