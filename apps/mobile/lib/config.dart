import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Build-time configuration, passed with `--dart-define` (see apps/mobile/README.md).
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.authMode, this.firebaseOptions});

  factory AppConfig.fromEnvironment() {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    return AppConfig(
      // 10.0.2.2 is the host machine from the Android emulator.
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000'),
      authMode: const String.fromEnvironment('AUTH_MODE', defaultValue: 'firebase'),
      firebaseOptions: apiKey.isEmpty
          ? null
          : const FirebaseOptions(
              apiKey: apiKey,
              appId: String.fromEnvironment('FIREBASE_APP_ID'),
              messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
              projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
            ),
    );
  }

  final String apiBaseUrl;
  final String authMode;
  final FirebaseOptions? firebaseOptions;

  /// Dev-only fake sign-in that matches the API's `AUTH_VERIFIER=fake`. Never in release builds.
  bool get useFakeAuth => kDebugMode && authMode == 'fake';
}
