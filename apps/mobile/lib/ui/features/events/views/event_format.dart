import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/event_summary.dart';
import '../../../../l10n/app_localizations.dart';

/// Events are in Tanzania (UTC+03:00, no daylight saving); show that wall-clock time.
String formatEventDate(BuildContext context, DateTime startsAt) {
  final local = startsAt.toUtc().add(const Duration(hours: 3));
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.yMMMEd(locale).format(local)} · ${DateFormat.Hm(locale).format(local)}';
}

String statusLabel(AppLocalizations l10n, EventStatus status) => switch (status) {
  EventStatus.draft => l10n.statusDraft,
  EventStatus.published => l10n.statusPublished,
  EventStatus.completed => l10n.statusCompleted,
  EventStatus.cancelled => l10n.statusCancelled,
};

class EventStatusChip extends StatelessWidget {
  const EventStatusChip({super.key, required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      EventStatus.published => (scheme.primaryContainer, scheme.onPrimaryContainer),
      EventStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(statusLabel(AppLocalizations.of(context), status), style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}
