import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'config.dart';
import 'data/repositories/door_repository.dart';
import 'data/repositories/door_sync_repository.dart';
import 'data/repositories/offline_check_in_repository.dart';
import 'data/repositories/push_registration_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/services/api_factory.dart';
import 'data/services/auth_service.dart';
import 'data/services/connectivity_source.dart';
import 'data/services/dev_auth_service.dart';
import 'data/services/door_cache_store.dart';
import 'data/services/door_device_store.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/push_token_source.dart';
import 'domain/models/app_failure.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final AuthService auth;
  PushTokenSource pushTokens = const NoPushTokenSource();
  if (config.useFakeAuth) {
    auth = DevAuthService();
  } else if (config.firebaseOptions != null) {
    await Firebase.initializeApp(options: config.firebaseOptions);
    auth = FirebaseAuthService(FirebaseAuth.instance);
    pushTokens = FirebasePushTokenSource(FirebaseMessaging.instance);
  } else {
    runApp(const _MissingConfigApp());
    return;
  }
  final api = createApi(baseUrl: config.apiBaseUrl, apiKey: config.apiKey, auth: auth);
  final prefs = await SharedPreferences.getInstance();
  final door = DoorRepository(api, DoorDeviceStore(prefs));
  // Encrypted offline cache: SQLCipher, key in the platform keystore (offline-sync 9.1).
  final cacheStore = DoorCacheStore(keys: SecureCacheKeyStore());
  final sync = DoorSyncRepository(door: door, store: cacheStore, connectivity: PlatformConnectivity());
  final offline = OfflineCheckInRepository(store: cacheStore, sync: sync);
  final session = SessionRepository(
    auth: auth,
    api: api,
    prefs: prefs,
    push: PushRegistrationRepository(api: api, source: pushTokens),
    // Sign-out wipes the cache; a normal sign-out first tries to upload what is waiting.
    beforeSignOut: (because) => sync.signOut(upload: because != AppFailure.doorAccessDenied),
  )..restore();
  // A cache past its event window is deleted at start-up.
  await sync.cachedSession();
  runApp(DCardApp(session: session, door: door, sync: sync, offline: offline));
}

/// Shown to developers when the build has no Firebase config (see apps/door/README.md).
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
