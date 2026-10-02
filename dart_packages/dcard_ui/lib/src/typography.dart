import 'package:flutter/material.dart';

/// Type scale (docs/design/ui/design-system.md): Playfair Display for headings, names and big
/// numbers; Plus Jakarta Sans for labels, inputs, buttons and body text. Both fonts are
/// bundled variable fonts, so every style sets the weight axis explicitly.
abstract final class DcType {
  static const String display = 'PlayfairDisplay';
  static const String sans = 'PlusJakartaSans';
  static const String package = 'dcard_ui';

  static TextStyle _style(String family, double size, FontWeight weight, {double? height, double? letterSpacing}) => TextStyle(
        fontFamily: family,
        package: package,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Playfair Display at [size] and [weight] (default bold).
  static TextStyle heading(double size, {FontWeight weight = FontWeight.w700, double height = 1.12}) =>
      _style(display, size, weight, height: height);

  /// Big Playfair numbers (money, counts, card numbers) with tabular figures.
  static TextStyle number(double size, {FontWeight weight = FontWeight.w800}) =>
      _style(display, size, weight, height: 1.05).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Plus Jakarta Sans for UI text.
  static TextStyle ui(double size, {FontWeight weight = FontWeight.w500, double height = 1.4}) =>
      _style(sans, size, weight, height: height);

  /// Small caps-style eyebrow label above a hero title.
  static TextStyle eyebrow() => _style(sans, 12, FontWeight.w700, letterSpacing: 1.3);

  /// Material text theme built from the scale (colours come from the theme).
  static TextTheme textTheme(Color ink) {
    TextStyle c(TextStyle s) => s.copyWith(color: ink);
    return TextTheme(
      displayLarge: c(heading(44, weight: FontWeight.w800)),
      displayMedium: c(heading(38)),
      displaySmall: c(heading(34)),
      headlineLarge: c(heading(32)),
      headlineMedium: c(heading(28)),
      headlineSmall: c(heading(24)),
      titleLarge: c(heading(20)),
      titleMedium: c(ui(16, weight: FontWeight.w700)),
      titleSmall: c(ui(14, weight: FontWeight.w700)),
      bodyLarge: c(ui(16)),
      bodyMedium: c(ui(14)),
      bodySmall: c(ui(12)),
      labelLarge: c(ui(15, weight: FontWeight.w700)),
      labelMedium: c(ui(13, weight: FontWeight.w600)),
      labelSmall: c(ui(12, weight: FontWeight.w600)),
    );
  }
}
