import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'tokens.dart';
import 'typography.dart';

/// A tonal notice tile: icon, optional bold title and a message, with an optional trailing
/// widget (a countdown, a button). For tips, warnings and errors inside a screen; never
/// outlined.
class DcNoticeTile extends StatelessWidget {
  const DcNoticeTile({
    super.key,
    required this.message,
    this.tone = DcTone.warning,
    this.icon,
    this.title,
    this.trailing,
    this.onTap,
    this.messageKey,
  });

  final String message;
  final DcTone tone;
  final List<List<dynamic>>? icon;
  final String? title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Key? messageKey;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final (bg, fg) = tone == DcTone.neutral ? (c.tile, c.ink) : c.tone(tone);
    final defaultIcon = switch (tone) {
      DcTone.danger => HugeIcons.strokeRoundedAlert02,
      DcTone.success => HugeIcons.strokeRoundedCheckmarkCircle02,
      _ => HugeIcons.strokeRoundedInformationCircle,
    };
    final content = Padding(
      padding: const EdgeInsets.all(DcSpace.lg),
      child: Row(
        children: [
          HugeIcon(icon: icon ?? defaultIcon, color: fg, size: 24),
          const SizedBox(width: DcSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) Text(title!, style: DcType.ui(15, weight: FontWeight.w700).copyWith(color: fg)),
                Text(message, key: messageKey, style: DcType.ui(14).copyWith(color: fg)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: DcSpace.md),
            DefaultTextStyle.merge(style: TextStyle(color: fg), child: trailing!),
          ],
        ],
      ),
    );
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.tile)),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
