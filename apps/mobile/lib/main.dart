import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'config.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/billing_repository.dart';
import 'data/repositories/contributions_repository.dart';
import 'data/repositories/events_repository.dart';
import 'data/repositories/guests_repository.dart';
import 'data/repositories/my_cards_repository.dart';
import 'data/repositories/push_registration_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/walk_in_alerts_repository.dart';
import 'data/repositories/walk_ins_repository.dart';
import 'data/services/api_factory.dart';
import 'data/services/auth_service.dart';
import 'data/services/contacts_source.dart';
import 'data/services/dev_auth_service.dart';
import 'data/services/file_saver.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/push_message_source.dart';
import 'data/services/push_token_source.dart';

/// Crash reports go to Sentry (free plan) only when built with `--dart-define=SENTRY_DSN=...`.
/// No personal data: default PII off, and phone numbers and card links are masked.
Future<void> main() async {
  const dsn = String.fromEnvironment('SENTRY_DSN');
  if (dsn.isEmpty) return _run();
  await SentryFlutter.init((options) {
    options.dsn = dsn;
    options.sendDefaultPii = false;
    options.tracesSampleRate = 0;
    options.beforeSend = (event, hint) => event.copyWith(
          message: event.message == null ? null : SentryMessage(_scrub(event.message!.formatted)),
          exceptions: event.exceptions?.map((e) => e.copyWith(value: e.value == null ? null : _scrub(e.value!))).toList(),
        );
  }, appRunner: _run);
}

final _phone = RegExp(r'\b(?:\+?255|0)[67]\d{8}\b');
final _cardLink = RegExp(r'(/c/|/cards/)[A-Za-z0-9_-]{20,100}');
String _scrub(String text) => text.replaceAll(_phone, '[phone]').replaceAllMapped(_cardLink, (m) => '${m[1]}[token]');

Future<void> _run() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final AuthService auth;
  PushTokenSource pushTokens = const NoPushTokenSource();
  PushMessageSource pushMessages = const NoPushMessageSource();
  if (config.useFakeAuth) {
    auth = DevAuthService();
  } else if (config.firebaseOptions != null) {
    await Firebase.initializeApp(options: config.firebaseOptions);
    auth = FirebaseAuthService(FirebaseAuth.instance);
    pushTokens = FirebasePushTokenSource(FirebaseMessaging.instance);
    pushMessages = FirebasePushMessageSource(FirebaseMessaging.instance);
  } else {
    runApp(const _MissingConfigApp());
    return;
  }
  final api = createApi(baseUrl: config.apiBaseUrl, apiKey: config.apiKey, auth: auth);
  final prefs = await SharedPreferences.getInstance();
  final session = SessionRepository(
    auth: auth,
    api: api,
    prefs: prefs,
    push: PushRegistrationRepository(api: api, source: pushTokens),
  )..restore();
  runApp(
    DCardApp(
      session: session,
      events: EventsRepository(api),
      guests: GuestsRepository(api),
      contacts: DeviceContactsSource(),
      contributions: ContributionsRepository(api),
      walkIns: WalkInsRepository(api),
      walkInAlerts: WalkInAlertsRepository(pushMessages),
      billing: BillingRepository(api),
      myCards: MyCardsRepository(api),
      account: AccountRepository(api, const DocumentsFileSaver()),
    ),
  );
}

/// Shown to developers when the build has no Firebase config (see apps/mobile/README.md).
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Firebase is not configured. Build with --dart-define=FIREBASE_API_KEY=... '
            'or --dart-define=AUTH_MODE=fake (debug only).',
          ),
        ),
      ),
    ),
  );
}
