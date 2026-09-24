import 'package:flutter/material.dart';

/// Title + subtitle block used on placeholder and landing screens.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.card_giftcard, size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(title, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: text.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
