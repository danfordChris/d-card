import 'dart:async';

import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_failure.dart';
import '../services/auth_service.dart';
import 'api_errors.dart';
import 'push_registration_repository.dart';

/// Who is signed in at the door. After a sign-in it provisions the D-Card account once
/// (`POST /api/v1/me`, idempotent) and remembers that per Firebase UID. The push token is
/// registered after sign-in (walk-in alerts) and removed on sign-out.
class SessionRepository extends ChangeNotifier {
  SessionRepository({
    required this._auth,
    required this._api,
    required this._prefs,
    this._push,
    this._beforeSignOut,
  });

  static const _provisionedKey = 'session.provisioned_uid';

  final AuthService _auth;
  final DefaultApi _api;
  final SharedPreferences _prefs;
  final PushRegistrationRepository? _push;

  /// Runs before every sign-out (the door wipes its offline cache).
  final Future<void> Function(AppFailure? because)? _beforeSignOut;

  /// Why the last sign-out happened when it was not the user's choice (shown on the sign-in screen).
  AppFailure? signedOutBecause;

  AuthUser? get user => _auth.currentUser;
  bool get isSignedIn => user != null && _prefs.getString(_provisionedKey) == user!.uid;

  Future<void> signIn({required String email, required String password}) async {
    final signedIn = await _auth.signIn(email: email.trim(), password: password);
    if (_prefs.getString(_provisionedKey) != signedIn.uid) {
      try {
        await guardApi(_api.provisionMe);
      } on AppException {
        await _auth.signOut();
        rethrow;
      }
      await _prefs.setString(_provisionedKey, signedIn.uid);
    }
    signedOutBecause = null;
    notifyListeners();
    // Not awaited: the permission prompt and network call must not hold up the UI.
    unawaited(_push?.register());
  }

  /// At start-up: re-register the push token when a session is restored.
  void restore() {
    if (isSignedIn) unawaited(_push?.register());
  }

  /// Signs out; [because] is set when the app forces it (e.g. the host revoked this device).
  Future<void> signOut({AppFailure? because}) async {
    try {
      await _beforeSignOut?.call(because);
    } catch (_) {}
    await _push?.unregister();
    await _auth.signOut();
    signedOutBecause = because;
    notifyListeners();
  }
}
