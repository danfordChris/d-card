import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Material themes built from the D-Card tokens (docs/design/ui/design-system.md).
abstract final class DcTheme {
  static ThemeData light() => _build(DcColors.light, Brightness.light);
  static ThemeData dark() => _build(DcColors.dark, Brightness.dark);

  static ThemeData _build(DcColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.soft,
      onPrimaryContainer: c.onSoft,
      secondary: c.primary,
      onSecondary: c.onPrimary,
      secondaryContainer: c.tile2,
      onSecondaryContainer: c.ink,
      error: c.dangerFg,
      onError: c.dangerBg,
      errorContainer: c.dangerBg,
      onErrorContainer: c.dangerFg,
      surface: c.bg,
      onSurface: c.ink,
      onSurfaceVariant: c.muted,
      surfaceContainerLowest: c.bg,
      surfaceContainerLow: c.tile,
      surfaceContainer: c.tile,
      surfaceContainerHigh: c.tile2,
      surfaceContainerHighest: c.tile2,
      outline: c.line,
      outlineVariant: c.line,
    );
    final text = DcType.textTheme(c.ink);
    final filledShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.button));
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: DcType.sans,
      textTheme: text,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: DcType.heading(19).copyWith(color: c.ink),
      ),
      cardTheme: CardThemeData(
        color: c.tile,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.tile)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, 56),
          shape: filledShape,
          textStyle: text.labelLarge,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, 56),
          shape: filledShape,
          textStyle: text.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.tile,
          foregroundColor: c.ink,
          side: BorderSide.none,
          minimumSize: const Size(64, 56),
          shape: filledShape,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.primary, textStyle: text.labelMedium, minimumSize: const Size(44, 44)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.tile,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: text.bodyLarge?.copyWith(color: c.muted),
        labelStyle: text.labelMedium?.copyWith(color: c.ink),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DcRadius.input), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DcRadius.input), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DcRadius.input), borderSide: BorderSide(color: c.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DcRadius.input), borderSide: BorderSide(color: c.dangerFg, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DcRadius.input), borderSide: BorderSide(color: c.dangerFg, width: 1.5)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.tile,
        selectedColor: c.primary,
        labelStyle: text.labelMedium,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.nav,
        contentTextStyle: text.bodyMedium?.copyWith(color: DcColors.dark.ink),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.input)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DcRadius.hero))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.tile)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary, linearTrackColor: c.tile2),
      listTileTheme: ListTileThemeData(iconColor: c.primary, textColor: c.ink),
    );
  }
}
