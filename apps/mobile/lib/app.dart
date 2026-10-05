import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

import 'data/repositories/account_repository.dart';
import 'data/repositories/billing_repository.dart';
import 'data/repositories/contributions_repository.dart';
import 'data/repositories/events_repository.dart';
import 'data/repositories/guests_repository.dart';
import 'data/repositories/my_cards_repository.dart';
import 'data/repositories/messages_repository.dart';
import 'data/repositories/team_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/theme_repository.dart';
import 'data/repositories/walk_in_alerts_repository.dart';
import 'data/repositories/walk_ins_repository.dart';
import 'data/services/contacts_source.dart';
import 'data/services/link_opener.dart';
import 'l10n/app_localizations.dart';
import 'ui/core/app_scope.dart';
import 'ui/features/auth/view_models/login_view_model.dart';
import 'ui/features/auth/views/login_screen.dart';
import 'ui/features/home/home_shell.dart';
import 'ui/features/walk_ins/views/walk_in_push_handler.dart';

/// Root widget: theme, Swahili/English localisation, and the sign-in gate.
class DCardApp extends StatelessWidget {
  const DCardApp({
    super.key,
    required this.session,
    required this.events,
    required this.guests,
    required this.contacts,
    required this.contributions,
    required this.messages,
    required this.team,
    required this.walkIns,
    required this.walkInAlerts,
    required this.billing,
    required this.myCards,
    required this.account,
    required this.theme,
    this.links = const ExternalLinkOpener(),
    this.locale,
  });

  final SessionRepository session;
  final EventsRepository events;
  final GuestsRepository guests;
  final ContactsSource contacts;
  final ContributionsRepository contributions;
  final MessagesRepository messages;
  final TeamRepository team;
  final WalkInsRepository walkIns;

  /// Walk-in pushes (foreground banners, tapped notifications).
  final WalkInAlertsRepository walkInAlerts;

  /// Host billing and checkout (T05-03).
  final BillingRepository billing;

  /// Guest cards: list, link, card view and RSVP (T06-02).
  final MyCardsRepository myCards;

  /// "Download my data".
  final AccountRepository account;

  /// Light / Dark / System choice from Account.
  final ThemeRepository theme;

  /// Opens the hosted payment page outside the app.
  final LinkOpener links;

  /// Forces a locale (tests); null follows the device.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      guests: guests,
      contacts: contacts,
      contributions: contributions,
      messages: messages,
      team: team,
      walkIns: walkIns,
      walkInAlerts: walkInAlerts,
      billing: billing,
      links: links,
      child: ListenableBuilder(
        listenable: theme,
        builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: DcTheme.light(),
        darkTheme: DcTheme.dark(),
        themeMode: theme.mode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ListenableBuilder(
          listenable: session,
          builder: (context, _) => session.isSignedIn
              ? WalkInPushHandler(
                  key: ValueKey(session.user!.uid),
                  alerts: walkInAlerts,
                  events: events,
                  child: HomeShell(session: session, events: events, myCards: myCards, account: account, theme: theme),
                )
              : LoginScreen(viewModel: LoginViewModel(session)),
        ),
        ),
      ),
    );
  }
}
