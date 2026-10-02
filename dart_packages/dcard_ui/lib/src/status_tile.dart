import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'tokens.dart';
import 'typography.dart';

/// Background, text, icon-disc background and icon colour for a [DcStatusTile] of [tone].
/// Toned tiles invert the pair for the disc so the icon reads at a glance; neutral uses the
/// tile colours with a primary disc.
(Color bg, Color fg, Color discBg, Color discFg) dcStatusColors(DcColors c, DcTone tone) => switch (tone) {
      DcTone.neutral => (c.tile, c.ink, c.primary, c.onPrimary),
      _ => () {
          final (bg, fg) = c.tone(tone);
          return (bg, fg, fg, bg);
        }(),
    };

/// One large status tile (28 px corners): an icon disc, a Playfair headline, an optional
/// message and extra content. Used for verdicts and blocking states (door result, revoked
/// phone, walk-in answer). The tile is a live region so screen readers announce changes.
class DcStatusTile extends StatelessWidget {
  const DcStatusTile({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    this.message,
    this.children = const [],
    this.busy = false,
    this.titleSize = 34,
    this.minHeight,
    this.titleKey,
    this.messageKey,
  });

  final DcTone tone;
  final List<List<dynamic>> icon;
  final String title;
  final String? message;

  /// Extra content under the message, in the tile's text colour.
  final List<Widget> children;

  /// Shows a progress ring in the disc instead of the icon (e.g. waiting for an answer).
  final bool busy;
  final double titleSize;
  final double? minHeight;

  /// Keys for the headline and message texts (tests and deep links).
  final Key? titleKey;
  final Key? messageKey;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, discBg, discFg) = dcStatusColors(context.dc, tone);
    return Semantics(
      liveRegion: true,
      container: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight ?? 0),
        child: DecoratedBox(
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(DcRadius.hero)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DcSpace.xxl, vertical: 28),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: fg),
              textAlign: TextAlign.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(color: discBg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: busy
                        ? SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: discFg, strokeWidth: 5))
                        : HugeIcon(icon: icon, color: discFg, size: 52, strokeWidth: 2.2),
                  ),
                  const SizedBox(height: DcSpace.lg),
                  Text(
                    title,
                    key: titleKey,
                    textAlign: TextAlign.center,
                    style: DcType.heading(titleSize, weight: FontWeight.w800, height: 1.08).copyWith(color: fg),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: DcSpace.md),
                    Text(
                      message!,
                      key: messageKey,
                      textAlign: TextAlign.center,
                      style: DcType.ui(16, height: 1.45).copyWith(color: fg),
                    ),
                  ],
                  for (final child in children) ...[const SizedBox(height: DcSpace.md), child],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
