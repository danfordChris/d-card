import 'package:flutter/widgets.dart';

import '../../data/repositories/billing_repository.dart';
import '../../data/repositories/contributions_repository.dart';
import '../../data/repositories/guests_repository.dart';
import '../../data/repositories/messages_repository.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/repositories/walk_in_alerts_repository.dart';
import '../../data/repositories/walk_ins_repository.dart';
import '../../data/services/contacts_source.dart';
import '../../data/services/link_opener.dart';

/// Dependencies that deeper screens need without threading them through every constructor.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.guests,
    required this.contacts,
    required this.contributions,
    required this.messages,
    required this.team,
    required this.walkIns,
    required this.walkInAlerts,
    required this.billing,
    required this.links,
    required super.child,
  });

  final GuestsRepository guests;
  final ContactsSource contacts;
  final ContributionsRepository contributions;
  final MessagesRepository messages;
  final TeamRepository team;
  final WalkInsRepository walkIns;
  final WalkInAlertsRepository walkInAlerts;
  final BillingRepository billing;
  final LinkOpener links;

  static AppScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      guests != oldWidget.guests ||
      contacts != oldWidget.contacts ||
      contributions != oldWidget.contributions ||
      messages != oldWidget.messages ||
      team != oldWidget.team ||
      walkIns != oldWidget.walkIns ||
      walkInAlerts != oldWidget.walkInAlerts ||
      billing != oldWidget.billing ||
      links != oldWidget.links;
}
