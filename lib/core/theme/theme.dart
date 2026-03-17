import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C5CE7), // Modern purple base
      primary: const Color(0xFF6C5CE7),
      secondary: const Color(0xFF00D2D3),
      tertiary: const Color(0xFFFF6B6B),
      // background: const Color(0xFFF9F9F9),
      surface: Colors.white,
      // onBackground: Color(0xFF2D3436),
    ),
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3436),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: const Color(0xFF6C5CE7),
      unselectedItemColor: Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: Colors.white.withValues(alpha: 0.9), // Glass effect
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white.withValues(alpha: 0.9), // Glass card
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey.shade600),
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3436),
      ),
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3436),
      ),
      bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF2D3436)),
      bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFF636E72)),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: const Color(0xFF6C5CE7),
      textColor: const Color(0xFF2D3436),
      collapsedTextColor: const Color(0xFF2D3436),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFA29BFE),
      brightness: Brightness.dark,
      primary: const Color(0xFFA29BFE),
      secondary: const Color(0xFF55E6C1),
      tertiary: const Color(0xFFFF7979),
      // background: const Color(0xFF1E272E),
      surface: const Color(0xFF2C3A47),
    ),
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: const Color(0xFFA29BFE),
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: const Color(0xFF2C3A47).withValues(alpha: 0.9),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF2C3A47).withValues(alpha: 0.9),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3B4B5A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFA29BFE), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF7979), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey.shade400),
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: const TextStyle(fontSize: 14, color: Colors.white54),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: const Color(0xFFA29BFE),
      textColor: Colors.white,
      collapsedTextColor: Colors.white70,
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
    ),
  );
}
