import 'package:flutter/material.dart';

/// D-Card brand colours and Material 3 themes shared by both apps.
abstract final class DCardColors {
  static const Color primary = Color(0xFF7A1F5C); // plum
  static const Color secondary = Color(0xFFC9A227); // gold
}

abstract final class DCardTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: DCardColors.primary,
      secondary: DCardColors.secondary,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}
