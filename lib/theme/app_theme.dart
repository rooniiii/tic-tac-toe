import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0B0B2B);
  static const Color purple = Color(0xFF7B2FF7);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPink = Color(0xFFFF2BD6);
  static const Color neonYellow = Color(0xFFFFD600);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: purple,
        secondary: neonCyan,
      ),
    );
  }
}