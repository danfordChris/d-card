import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'tokens.dart';
import 'typography.dart';

/// Round tonal disc with a Hugeicon (list rows, action tiles).
class DcIconDisc extends StatelessWidget {
  const DcIconDisc({super.key, required this.icon, this.size = 40, this.background, this.foreground});

  final List<List<dynamic>> icon;
  final double size;

  /// Defaults to `tile2` / `primary`.
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background ?? c.tile2, shape: BoxShape.circle),
      child: HugeIcon(icon: icon, size: size / 2, color: foreground ?? c.primary),
    );
  }
}

/// Section heading: Playfair title with an optional trailing action.
class DcSectionHeader extends StatelessWidget {
  const DcSectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DcSpace.xl, bottom: DcSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: DcType.heading(21).copyWith(color: context.dc.ink)),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// A plain list row (no box): optional leading, a bold title, a muted subtitle and a trailing
/// widget, with a faint `line` divider above every row but the first.
class DcListRow extends StatelessWidget {
  const DcListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.divider = true,
    this.titleStyle,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Draws the faint divider above the row (false for the first row of a list).
  final bool divider;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final content = Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(border: divider ? Border(top: BorderSide(color: c.line)) : null),
      padding: const EdgeInsets.symmetric(vertical: DcSpace.gap),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: titleStyle ?? DcType.ui(15, weight: FontWeight.w700).copyWith(color: c.ink)),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: DcType.ui(13).copyWith(color: c.muted)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: DcSpace.md), trailing!],
        ],
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(DcRadius.input), child: content),
    );
  }
}

/// Date block for event rows: the day as a big Playfair number over a short month.
class DcDateBlock extends StatelessWidget {
  const DcDateBlock({super.key, required this.day, required this.month, this.size = 52});

  final String day;
  final String month;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.tile, borderRadius: BorderRadius.circular(DcRadius.input)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: DcType.number(20).copyWith(color: c.ink)),
          Text(month.toUpperCase(), style: DcType.ui(11, weight: FontWeight.w700, height: 1.2).copyWith(color: c.muted)),
        ],
      ),
    );
  }
}

/// Small square action tile (3-column grids): icon disc on top and a short label.
class DcActionTile extends StatelessWidget {
  const DcActionTile({super.key, required this.icon, required this.label, required this.onTap});

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Semantics(
      button: true,
      child: Material(
        color: c.tile,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.action)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DcIconDisc(icon: icon, size: 36, background: c.bg),
                  const SizedBox(height: DcSpace.sm),
                  Text(label, maxLines: 2, style: DcType.ui(13, weight: FontWeight.w700, height: 1.25).copyWith(color: c.ink)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A selectable option (plan, payment method, RSVP answer): primary fill when selected, else a
/// tonal fill. Marked as selected for screen readers.
class DcChoice extends StatelessWidget {
  const DcChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
    this.icon,
    this.busy = false,
    this.onTile = false,
  });

  final String label;
  final String? description;
  final List<List<dynamic>>? icon;
  final bool selected;
  final VoidCallback? onTap;

  /// Shows a progress ring in place of the icon.
  final bool busy;

  /// Unselected fill is the page background (for choices inside a tile) instead of `tile`.
  final bool onTile;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final (bg, fg, sub) = selected ? (c.primary, c.onPrimary, c.onPrimary) : (onTile ? c.bg : c.tile, c.ink, c.muted);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      enabled: onTap != null,
      child: Opacity(
        opacity: onTap == null && !selected ? 0.6 : 1,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.input)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DcSpace.lg, vertical: DcSpace.md),
                child: Row(
                  children: [
                    if (busy)
                      SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                    else if (icon != null)
                      HugeIcon(icon: icon!, size: 20, color: fg),
                    if (busy || icon != null) const SizedBox(width: DcSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label, style: DcType.ui(15, weight: FontWeight.w700).copyWith(color: fg)),
                          if (description != null) Text(description!, style: DcType.ui(12.5).copyWith(color: sub)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header of a tab's root screen (no back button): optional muted greeting, a large Playfair
/// title and an optional trailing action.
class DcPageHeader extends StatelessWidget {
  const DcPageHeader({super.key, required this.title, this.greeting, this.action});

  final String title;
  final String? greeting;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.xl, DcSpace.page, DcSpace.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (greeting != null) Text(greeting!, style: DcType.ui(14).copyWith(color: c.muted)),
                Semantics(header: true, child: Text(title, style: DcType.heading(30).copyWith(color: c.ink))),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
