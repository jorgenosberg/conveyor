import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFFFA9549); // Satisfactory orange
  static const _backgroundColor = Color(0xFF1A1A2E);
  static const _surfaceColor = Color(0xFF252540);
  static const _cardColor = Color(0xFF2D2D4A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _primaryColor.withValues(alpha: 0.8),
        surface: _surfaceColor,
        onSurface: Colors.white,
        onPrimary: Colors.black,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      cardTheme: CardThemeData(
        color: _cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceColor,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceColor,
        selectedColor: _primaryColor,
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }
}