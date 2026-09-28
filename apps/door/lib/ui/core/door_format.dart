import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Events are in Tanzania (UTC+03:00, no daylight saving); show that wall-clock time.
DateTime tanzaniaTime(DateTime t) => t.toUtc().add(const Duration(hours: 3));

String formatEventDate(BuildContext context, DateTime startsAt) {
  final local = tanzaniaTime(startsAt);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.yMMMEd(locale).format(local)} · ${DateFormat.Hm(locale).format(local)}';
}

/// Entry times on the door: "12 Dec, 18:05".
String formatEntryTime(BuildContext context, DateTime occurredAt) {
  final local = tanzaniaTime(occurredAt);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.MMMd(locale).format(local)}, ${DateFormat.Hm(locale).format(local)}';
}

/// "4:07" for a lockout countdown.
String formatCountdown(Duration d) {
  final seconds = d.inSeconds + (d.inMilliseconds % 1000 > 0 ? 1 : 0);
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// "18:05" in Tanzania time.
String formatTime(BuildContext context, DateTime t) =>
    DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(tanzaniaTime(t));
