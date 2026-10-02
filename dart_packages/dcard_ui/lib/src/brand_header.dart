import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'tokens.dart';
import 'typography.dart';

/// Title + subtitle block used on placeholder and landing screens.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: c.tile, borderRadius: BorderRadius.circular(DcRadius.action)),
          child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedTicket01, size: 30, color: c.primary)),
        ),
        const SizedBox(height: DcSpace.lg),
        Text(title, style: DcType.heading(28).copyWith(color: c.ink), textAlign: TextAlign.center),
        const SizedBox(height: DcSpace.sm),
        Text(subtitle, style: DcType.ui(14).copyWith(color: c.muted), textAlign: TextAlign.center),
      ],
    );
  }
}
