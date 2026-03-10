import 'package:flutter/material.dart';

class AppTheme {
  // Duolingo-inspired bright & playful colors
  static const Color background = Color(0xFFF7F7F7);       // light gray bg
  static const Color cardBackground = Colors.white;
  static const Color emeraldGreen = Color(0xFF58CC02);      // Duolingo green
  static const Color darkGreen = Color(0xFF46A302);         // button shadow
  static const Color plannedColor = Color(0xFF1CB0F6);      // Duolingo blue
  static const Color spontaneousColor = Color(0xFFFF9600);  // Duolingo orange
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color cardBorder = Color(0xFFE5E5E5);
  static const Color featherYellow = Color(0xFFFFC800);     // accent yellow
  static const Color heartRed = Color(0xFFFF4B4B);          // accent red

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: emeraldGreen,
    scaffoldBackgroundColor: background,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
      labelLarge: TextStyle(color: textSecondary),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      color: cardBackground,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: emeraldGreen.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: emeraldGreen);
        }
        return const IconThemeData(color: textSecondary);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: emeraldGreen, fontSize: 12, fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: textSecondary, fontSize: 12);
      }),
      elevation: 3,
      shadowColor: Colors.black12,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: emeraldGreen,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}
