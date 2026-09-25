import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

import 'data/repositories/contributions_repository.dart';
import 'data/repositories/events_repository.dart';
import 'data/repositories/guests_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/services/contacts_source.dart';
import 'l10n/app_localizations.dart';
import 'ui/core/app_scope.dart';
import 'ui/features/auth/view_models/login_view_model.dart';
import 'ui/features/auth/views/login_screen.dart';
import 'ui/features/events/view_models/events_view_model.dart';
import 'ui/features/events/views/events_screen.dart';

/// Root widget: theme, Swahili/English localisation, and the sign-in gate.
class DCardApp extends StatelessWidget {
  const DCardApp({
    super.key,
    required this.session,
    required this.events,
    required this.guests,
    required this.contacts,
    required this.contributions,
    this.locale,
  });

  final SessionRepository session;
  final EventsRepository events;
  final GuestsRepository guests;
  final ContactsSource contacts;
  final ContributionsRepository contributions;

  /// Forces a locale (tests); null follows the device.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      guests: guests,
      contacts: contacts,
      contributions: contributions,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: DCardTheme.light(),
        darkTheme: DCardTheme.dark(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ListenableBuilder(
          listenable: session,
          builder: (context, _) => session.isSignedIn
              ? EventsScreen(
                  key: ValueKey(session.user!.uid),
                  viewModel: EventsViewModel(events),
                  onSignOut: session.signOut,
                )
              : LoginScreen(viewModel: LoginViewModel(session)),
        ),
      ),
    );
  }
}
