import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/event_summary.dart';
import '../../../../l10n/app_localizations.dart';

/// Events are in Tanzania (UTC+03:00, no daylight saving): the wall-clock time there.
DateTime eatTime(DateTime at) => at.toUtc().add(const Duration(hours: 3));

/// Show the Tanzanian wall-clock date and time.
String formatEventDate(BuildContext context, DateTime startsAt) {
  final local = eatTime(startsAt);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.yMMMEd(locale).format(local)} · ${DateFormat.Hm(locale).format(local)}';
}

/// Day of month and short month name (EAT) for a date block.
(String day, String month) eventDayMonth(BuildContext context, DateTime startsAt) {
  final local = eatTime(startsAt);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return ('${local.day}', DateFormat.MMM(locale).format(local));
}

/// Whole days from today to the event (both in EAT); negative once it has passed.
int daysUntil(DateTime startsAt, {DateTime? now}) {
  final a = eatTime(now ?? DateTime.now());
  final b = eatTime(startsAt);
  return DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
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
  Widget build(BuildContext context) => DcBadge(
    label: statusLabel(AppLocalizations.of(context), status),
    tone: switch (status) {
      EventStatus.published => DcTone.success,
      EventStatus.cancelled => DcTone.danger,
      EventStatus.draft => DcTone.warning,
      EventStatus.completed => DcTone.neutral,
    },
  );
}
