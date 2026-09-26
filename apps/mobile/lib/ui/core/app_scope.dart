import 'package:flutter/widgets.dart';

import '../../data/repositories/contributions_repository.dart';
import '../../data/repositories/guests_repository.dart';
import '../../data/repositories/walk_in_alerts_repository.dart';
import '../../data/repositories/walk_ins_repository.dart';
import '../../data/services/contacts_source.dart';

/// Dependencies that deeper screens need without threading them through every constructor.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.guests,
    required this.contacts,
    required this.contributions,
    required this.walkIns,
    required this.walkInAlerts,
    required super.child,
  });

  final GuestsRepository guests;
  final ContactsSource contacts;
  final ContributionsRepository contributions;
  final WalkInsRepository walkIns;
  final WalkInAlertsRepository walkInAlerts;

  static AppScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      guests != oldWidget.guests ||
      contacts != oldWidget.contacts ||
      contributions != oldWidget.contributions ||
      walkIns != oldWidget.walkIns ||
      walkInAlerts != oldWidget.walkInAlerts;
}
