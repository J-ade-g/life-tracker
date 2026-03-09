import 'package:flutter/material.dart';

class AppTheme {
  // Momo design language colors
  static const Color background = Color(0xFF0B1929);
  static const Color cardBackground = Color(0xFF0F2137);
  static const Color emeraldGreen = Color(0xFF2CD87A);
  static const Color plannedColor = Color(0xFF5B9BD5);   // blue - planned
  static const Color spontaneousColor = Color(0xFFFF9F43); // orange - spontaneous

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: emeraldGreen,
    scaffoldBackgroundColor: background,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      color: cardBackground,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: emeraldGreen.withValues(alpha: 0.3),
    ),
  );
}
