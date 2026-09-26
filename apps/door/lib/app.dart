import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

import 'data/repositories/door_repository.dart';
import 'data/repositories/door_sync_repository.dart';
import 'data/repositories/offline_check_in_repository.dart';
import 'data/repositories/session_repository.dart';
import 'l10n/app_localizations.dart';
import 'ui/features/auth/view_models/login_view_model.dart';
import 'ui/features/auth/views/login_screen.dart';
import 'ui/features/check_in/views/qr_scanner_view.dart';
import 'ui/features/home/door_home.dart';

/// Root widget: theme, Swahili (default) / English, and the sign-in gate.
class DCardApp extends StatelessWidget {
  const DCardApp({
    super.key,
    required this.session,
    required this.door,
    this.sync,
    this.offline,
    this.scanner = cameraScanner,
    this.locale,
    this.clock,
  });

  final SessionRepository session;
  final DoorRepository door;

  /// Offline cache and sync (T04-05); null runs online-only.
  final DoorSyncRepository? sync;
  final OfflineCheckInRepository? offline;

  /// Camera QR scanner; tests pass a fake.
  final ScannerBuilder scanner;

  /// Forces a locale (tests); null follows the device (Swahili unless it is English).
  final Locale? locale;

  /// Time source for the lockout countdown (tests).
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: DCardTheme.light(),
      darkTheme: DCardTheme.dark(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (device, _) =>
          device?.languageCode == 'en' ? const Locale('en') : const Locale('sw'),
      home: ListenableBuilder(
        listenable: session,
        builder: (context, _) => session.isSignedIn
            ? DoorHome(
                key: ValueKey(session.user!.uid),
                session: session,
                door: door,
                sync: sync,
                offline: offline,
                scanner: scanner,
                clock: clock,
              )
            : LoginScreen(viewModel: LoginViewModel(session)),
      ),
    );
  }
}
