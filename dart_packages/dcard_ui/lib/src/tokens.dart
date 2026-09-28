import 'package:flutter/material.dart';

/// D-Card colour roles (docs/design/ui/design-system.md). Screens read colours only
/// through this extension: `context.dc.primary`, never hex literals.
@immutable
class DcColors extends ThemeExtension<DcColors> {
  const DcColors({
    required this.bg,
    required this.tile,
    required this.tile2,
    required this.soft,
    required this.onSoft,
    required this.hero,
    required this.onHero,
    required this.heroMuted,
    required this.primary,
    required this.onPrimary,
    required this.ink,
    required this.muted,
    required this.line,
    required this.successBg,
    required this.successFg,
    required this.warningBg,
    required this.warningFg,
    required this.dangerBg,
    required this.dangerFg,
    required this.nav,
    required this.navFg,
    required this.navAccent,
    required this.navShadow,
  });

  final Color bg;
  final Color tile;
  final Color tile2;
  final Color soft;
  final Color onSoft;
  final Color hero;
  final Color onHero;
  final Color heroMuted;
  final Color primary;
  final Color onPrimary;
  final Color ink;
  final Color muted;
  final Color line;
  final Color successBg;
  final Color successFg;
  final Color warningBg;
  final Color warningFg;
  final Color dangerBg;
  final Color dangerFg;
  final Color nav;
  final Color navFg;
  final Color navAccent;

  /// Shadow under the floating bottom bar (transparent in dark mode).
  final Color navShadow;

  static const light = DcColors(
    bg: Color(0xFFFFFFFF),
    tile: Color(0xFFF5F1FA),
    tile2: Color(0xFFEDE5F6),
    soft: Color(0xFFE4D7F2),
    onSoft: Color(0xFF3E1C5E),
    hero: Color(0xFF5A2D82),
    onHero: Color(0xFFFFFFFF),
    heroMuted: Color(0xFFE4D7F2),
    primary: Color(0xFF5A2D82),
    onPrimary: Color(0xFFFFFFFF),
    ink: Color(0xFF1A1523),
    muted: Color(0xFF625A72),
    line: Color(0xFFEEE9F4),
    successBg: Color(0xFFE3F2E9),
    successFg: Color(0xFF1B6B43),
    warningBg: Color(0xFFFBF0D9),
    warningFg: Color(0xFF7A5000),
    dangerBg: Color(0xFFFCE7E5),
    dangerFg: Color(0xFFA11F15),
    nav: Color(0xFF1A1024),
    navFg: Color(0xFFA396B6),
    navAccent: Color(0xFFC8ADEE),
    navShadow: Color(0x381A1024),
  );

  static const dark = DcColors(
    bg: Color(0xFF110D16),
    tile: Color(0xFF1B1522),
    tile2: Color(0xFF241C2E),
    soft: Color(0xFF3A2456),
    onSoft: Color(0xFFEADCFB),
    hero: Color(0xFF3A2456),
    onHero: Color(0xFFF3EFF8),
    heroMuted: Color(0xFFD9C8F0),
    primary: Color(0xFFC8ADEE),
    onPrimary: Color(0xFF2A1142),
    ink: Color(0xFFF3EFF8),
    muted: Color(0xFFB6AEC4),
    line: Color(0xFF2A2233),
    successBg: Color(0xFF16301F),
    successFg: Color(0xFF8BDDB0),
    warningBg: Color(0xFF33280F),
    warningFg: Color(0xFFF0C674),
    dangerBg: Color(0xFF3A1714),
    dangerFg: Color(0xFFF4A097),
    nav: Color(0xFF221A2C),
    navFg: Color(0xFF9C90AE),
    navAccent: Color(0xFFD4BEF3),
    navShadow: Color(0x00000000),
  );

  @override
  DcColors copyWith({Color? primary, Color? onPrimary}) => DcColors(
        bg: bg,
        tile: tile,
        tile2: tile2,
        soft: soft,
        onSoft: onSoft,
        hero: hero,
        onHero: onHero,
        heroMuted: heroMuted,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        ink: ink,
        muted: muted,
        line: line,
        successBg: successBg,
        successFg: successFg,
        warningBg: warningBg,
        warningFg: warningFg,
        dangerBg: dangerBg,
        dangerFg: dangerFg,
        nav: nav,
        navFg: navFg,
        navAccent: navAccent,
        navShadow: navShadow,
      );

  @override
  DcColors lerp(ThemeExtension<DcColors>? other, double t) {
    if (other is! DcColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DcColors(
      bg: l(bg, other.bg),
      tile: l(tile, other.tile),
      tile2: l(tile2, other.tile2),
      soft: l(soft, other.soft),
      onSoft: l(onSoft, other.onSoft),
      hero: l(hero, other.hero),
      onHero: l(onHero, other.onHero),
      heroMuted: l(heroMuted, other.heroMuted),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      successBg: l(successBg, other.successBg),
      successFg: l(successFg, other.successFg),
      warningBg: l(warningBg, other.warningBg),
      warningFg: l(warningFg, other.warningFg),
      dangerBg: l(dangerBg, other.dangerBg),
      dangerFg: l(dangerFg, other.dangerFg),
      nav: l(nav, other.nav),
      navFg: l(navFg, other.navFg),
      navAccent: l(navAccent, other.navAccent),
      navShadow: l(navShadow, other.navShadow),
    );
  }
}

/// 4-point spacing scale.
abstract final class DcSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double gap = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page padding on phones.
  static const double page = 20;
}

/// Corner radii.
abstract final class DcRadius {
  static const double input = 16;
  static const double button = 18;
  static const double action = 20;
  static const double tile = 24;
  static const double hero = 28;
  static const double pill = 999;
}

/// Tone of a status badge or result.
enum DcTone { success, warning, danger, neutral }

extension DcColorsTone on DcColors {
  (Color bg, Color fg) tone(DcTone t) => switch (t) {
        DcTone.success => (successBg, successFg),
        DcTone.warning => (warningBg, warningFg),
        DcTone.danger => (dangerBg, dangerFg),
        DcTone.neutral => (tile, muted),
      };
}

extension DcThemeContext on BuildContext {
  /// The D-Card colour roles of the current theme.
  DcColors get dc => Theme.of(this).extension<DcColors>() ?? DcColors.light;
}
