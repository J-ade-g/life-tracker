import 'package:flutter/material.dart';

class AppTheme {
  // 计划内 vs 即兴的颜色
  static const Color plannedColor = Color(0xFF5B9BD5);   // 蓝色 - 计划内
  static const Color spontaneousColor = Color(0xFFFF9F43); // 橙色 - 即兴

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6C63FF),
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      color: const Color(0xFF1A1A2E),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0D0D0D),
      indicatorColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
    ),
  );
}
