import 'package:flutter/material.dart';

import '../../../../domain/models/guest_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Small flat pill (card status, RSVP).
class Pill extends StatelessWidget {
  const Pill({super.key, required this.text, required this.background, required this.foreground});

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: TextStyle(color: foreground, fontSize: 12)),
  );
}

class CardStatusBadge extends StatelessWidget {
  const CardStatusBadge({super.key, required this.status});

  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return status == CardStatus.issued
        ? Pill(text: l10n.cardStatusIssued, background: scheme.primaryContainer, foreground: scheme.onPrimaryContainer)
        : Pill(text: l10n.cardStatusCancelled, background: scheme.errorContainer, foreground: scheme.onErrorContainer);
  }
}

class RsvpBadge extends StatelessWidget {
  const RsvpBadge({super.key, required this.answer});

  final RsvpAnswer answer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return switch (answer) {
      RsvpAnswer.yes => Pill(
        text: l10n.rsvpBadgeYes,
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      RsvpAnswer.no => Pill(
        text: l10n.rsvpBadgeNo,
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      ),
      RsvpAnswer.none => Pill(
        text: l10n.rsvpBadgeNone,
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      ),
    };
  }
}

String cardTypeLabel(AppLocalizations l10n, {required bool isDouble}) =>
    isDouble ? l10n.cardTypeDouble : l10n.cardTypeSingle;
