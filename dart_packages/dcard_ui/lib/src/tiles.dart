import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Background of a bento tile.
enum DcTileVariant { tile, tile2, soft, hero }

/// A bento tile: tonal fill, rounded corners, no border and no shadow.
/// With [onTap] the whole tile is one button (use [semanticLabel] when the content is not enough).
class DcTile extends StatelessWidget {
  const DcTile({
    super.key,
    required this.child,
    this.variant = DcTileVariant.tile,
    this.padding = const EdgeInsets.all(DcSpace.lg),
    this.radius = DcRadius.tile,
    this.onTap,
    this.semanticLabel,
    this.minHeight,
  });

  final Widget child;
  final DcTileVariant variant;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double? minHeight;

  /// Background and foreground for [variant].
  static (Color, Color) colors(DcColors c, DcTileVariant v) => switch (v) {
        DcTileVariant.tile => (c.tile, c.ink),
        DcTileVariant.tile2 => (c.tile2, c.ink),
        DcTileVariant.soft => (c.soft, c.onSoft),
        DcTileVariant.hero => (c.hero, c.onHero),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = colors(context.dc, variant);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    Widget content = Padding(
      padding: padding,
      child: DefaultTextStyle.merge(style: TextStyle(color: fg), child: IconTheme.merge(data: IconThemeData(color: fg), child: child)),
    );
    if (minHeight != null) content = ConstrainedBox(constraints: BoxConstraints(minHeight: minHeight!), child: content);
    final material = Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
    if (onTap == null) return material;
    return Semantics(button: true, label: semanticLabel, child: material);
  }
}

/// A thin rounded progress bar.
class DcProgress extends StatelessWidget {
  const DcProgress({super.key, required this.value, this.height = 8, this.color, this.trackColor, this.semanticLabel});

  /// 0–1.
  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Semantics(
      label: semanticLabel,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DcRadius.pill),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: height,
          color: color ?? c.primary,
          backgroundColor: trackColor ?? c.tile2,
        ),
      ),
    );
  }
}

/// Stat tile: a label, a big Playfair number and an optional note and progress bar.
class DcStatTile extends StatelessWidget {
  const DcStatTile({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.progress,
    this.variant = DcTileVariant.tile,
    this.valueSize = 28,
    this.onTap,
  });

  final String label;
  final String value;
  final String? note;
  final double? progress;
  final DcTileVariant variant;
  final double valueSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final (_, fg) = DcTile.colors(c, variant);
    final muted = switch (variant) {
      DcTileVariant.hero => c.heroMuted,
      DcTileVariant.soft => c.onSoft,
      _ => c.muted,
    };
    return DcTile(
      variant: variant,
      onTap: onTap,
      semanticLabel: onTap == null ? null : '$label: $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: DcType.ui(13).copyWith(color: muted)),
          const SizedBox(height: DcSpace.xs),
          Text(value, style: DcType.number(valueSize).copyWith(color: fg)),
          if (progress != null) ...[
            const SizedBox(height: DcSpace.gap),
            DcProgress(value: progress!, height: 6, color: variant == DcTileVariant.hero ? c.onHero : null),
          ],
          if (note != null) ...[
            const SizedBox(height: DcSpace.xs),
            Text(note!, style: DcType.ui(12).copyWith(color: muted)),
          ],
        ],
      ),
    );
  }
}

/// Lays tiles out as a bento grid: each row holds tiles whose [DcBentoItem.span]s add up to [columns].
class DcBento extends StatelessWidget {
  const DcBento({super.key, required this.items, this.columns = 2, this.gap = DcSpace.gap});

  final List<DcBentoItem> items;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <List<DcBentoItem>>[];
    var current = <DcBentoItem>[];
    var used = 0;
    for (final item in items) {
      final span = item.span.clamp(1, columns);
      if (used + span > columns) {
        rows.add(current);
        current = [];
        used = 0;
      }
      current.add(item);
      used += span;
    }
    if (current.isNotEmpty) rows.add(current);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows[r].length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(flex: rows[r][i].span.clamp(1, columns), child: rows[r][i].child),
                ],
                // Fill an incomplete row so tiles keep their column width.
                if (rows[r].fold<int>(0, (s, e) => s + e.span.clamp(1, columns)) < columns) ...[
                  SizedBox(width: gap),
                  Expanded(flex: columns - rows[r].fold<int>(0, (s, e) => s + e.span.clamp(1, columns)), child: const SizedBox()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One tile in a [DcBento]; [span] is the number of columns it covers.
class DcBentoItem {
  const DcBentoItem(this.child, {this.span = 1});

  final Widget child;
  final int span;
}
