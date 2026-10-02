import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/guest_card.dart';
import '../../../../l10n/app_localizations.dart';

class CardStatusBadge extends StatelessWidget {
  const CardStatusBadge({super.key, required this.status});

  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return status == CardStatus.issued
        ? DcBadge(label: l10n.cardStatusIssued, tone: DcTone.success)
        : DcBadge(label: l10n.cardStatusCancelled, tone: DcTone.danger);
  }
}

class RsvpBadge extends StatelessWidget {
  const RsvpBadge({super.key, required this.answer});

  final RsvpAnswer answer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (answer) {
      RsvpAnswer.yes => DcBadge(label: l10n.rsvpBadgeYes, tone: DcTone.success),
      RsvpAnswer.no => DcBadge(label: l10n.rsvpBadgeNo, tone: DcTone.neutral),
      RsvpAnswer.none => DcBadge(label: l10n.rsvpBadgeNone, tone: DcTone.warning),
    };
  }
}

String cardTypeLabel(AppLocalizations l10n, {required bool isDouble}) =>
    isDouble ? l10n.cardTypeDouble : l10n.cardTypeSingle;
