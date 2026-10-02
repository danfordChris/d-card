import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'controls.dart';
import 'tokens.dart';
import 'typography.dart';

/// Page header: circular back button, Playfair title, optional trailing action.
class DcTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DcTopBar({super.key, this.title, this.onBack, this.backLabel = 'Back', this.action});

  final String? title;

  /// Null hides the back button; defaults to popping the route when there is one.
  final VoidCallback? onBack;
  final String backLabel;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final canPop = onBack != null || Navigator.of(context).canPop();
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DcSpace.md),
          child: Row(
            children: [
              if (canPop)
                DcCircleButton(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  label: backLabel,
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                )
              else
                const SizedBox(width: 44),
              Expanded(
                child: Text(
                  title ?? '',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: DcType.heading(19).copyWith(color: c.ink),
                ),
              ),
              action ?? const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}

/// 44 px round icon button on a tile background (or primary when [filled]).
class DcCircleButton extends StatelessWidget {
  const DcCircleButton({super.key, required this.icon, required this.label, required this.onPressed, this.filled = false});

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? c.primary : c.tile,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(width: 44, height: 44, child: Center(child: HugeIcon(icon: icon, size: 20, color: filled ? c.onPrimary : c.ink))),
        ),
      ),
    );
  }
}

/// One tab of [DcSpotlightNavBar].
class DcNavItem {
  const DcNavItem({required this.icon, required this.label});

  final List<List<dynamic>> icon;

  /// Screen-reader label (the bar shows icons only).
  final String label;
}

/// Floating dark bottom bar with icon-only tabs. The active tab has an accent strip on the
/// top edge, a spotlight cone and a glowing icon (docs/design/ui/design-system.md).
class DcSpotlightNavBar extends StatelessWidget {
  const DcSpotlightNavBar({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<DcNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Space to leave under scrolling content so the bar never covers it.
  static const double reservedHeight = 72 + 18 + 8;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: c.nav,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: c.navShadow, blurRadius: 28, offset: const Offset(0, 14))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(child: _NavButton(item: items[i], active: i == currentIndex, onTap: () => onTap(i))),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, required this.onTap});

  final DcNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final icon = HugeIcon(icon: item.icon, size: 26, color: active ? c.navAccent : c.navFg, strokeWidth: active ? 1.9 : 1.7);
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (active) ...[
              // Spotlight cone from the strip down onto the icon.
              Positioned(
                top: 4,
                width: 66,
                height: 68,
                child: ClipPath(
                  clipper: _ConeClipper(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [c.navAccent.withValues(alpha: 0.42), c.navAccent.withValues(alpha: 0.10), c.navAccent.withValues(alpha: 0)],
                        stops: const [0, 0.6, 1],
                      ),
                    ),
                  ),
                ),
              ),
              // Accent strip on the top edge.
              Positioned(
                top: 0,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: c.navAccent, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4))),
                ),
              ),
              // Glow: a blurred copy behind the icon.
              ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: icon),
            ],
            icon,
          ],
        ),
      ),
    );
  }
}

class _ConeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * 0.32, 0)
    ..lineTo(size.width * 0.68, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

enum DcStateKind { loading, empty, noResults, error }

/// The four async states in one place: loading, empty, no results, error (with retry).
class DcStateView extends StatelessWidget {
  const DcStateView({super.key, required this.kind, this.title, this.message, this.icon, this.actionLabel, this.onAction});

  final DcStateKind kind;
  final String? title;
  final String? message;
  final List<List<dynamic>>? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    if (kind == DcStateKind.loading) {
      return Semantics(label: title ?? 'Loading', child: Center(child: CircularProgressIndicator(color: c.primary)));
    }
    final defaultIcon = switch (kind) {
      DcStateKind.error => HugeIcons.strokeRoundedAlert02,
      DcStateKind.noResults => HugeIcons.strokeRoundedSearch01,
      _ => HugeIcons.strokeRoundedInbox,
    };
    final (discBg, discFg) = kind == DcStateKind.error ? (c.dangerBg, c.dangerFg) : (c.tile, c.primary);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DcSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: discBg, shape: BoxShape.circle),
              child: Center(child: HugeIcon(icon: icon ?? defaultIcon, size: 28, color: discFg)),
            ),
            const SizedBox(height: DcSpace.lg),
            if (title != null) Text(title!, textAlign: TextAlign.center, style: DcType.heading(20).copyWith(color: c.ink)),
            if (message != null) ...[
              const SizedBox(height: DcSpace.sm),
              Text(message!, textAlign: TextAlign.center, style: DcType.ui(14).copyWith(color: c.muted)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DcSpace.lg),
              DcButton(label: actionLabel!, onPressed: onAction, variant: kind == DcStateKind.error ? DcButtonVariant.primary : DcButtonVariant.tonal, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
