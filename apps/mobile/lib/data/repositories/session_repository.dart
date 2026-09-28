import 'dart:async';
import 'dart:io';

import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_failure.dart';
import '../services/auth_service.dart';
import 'api_errors.dart';
import 'push_registration_repository.dart';

/// `DELETE /api/v1/me` refused: the user still hosts events (409 `conflict`).
class AccountDeletionBlockedException implements Exception {
  const AccountDeletionBlockedException();
}

/// Who is signed in. After a sign-in it provisions the D-Card account once
/// (`POST /api/v1/me`) and remembers that per Firebase UID. With a push registration,
/// the device's push token is registered after sign-in and removed on sign-out.
class SessionRepository extends ChangeNotifier {
  SessionRepository({required this._auth, required this._api, required this._prefs, this._push});

  static const _provisionedKey = 'session.provisioned_uid';

  final AuthService _auth;
  final DefaultApi _api;
  final SharedPreferences _prefs;
  final PushRegistrationRepository? _push;

  AuthUser? get user => _auth.currentUser;
  bool get isSignedIn => user != null && _prefs.getString(_provisionedKey) == user!.uid;

  Future<void> signIn({required String email, required String password}) async =>
      _afterSignIn(await _auth.signIn(email: email.trim(), password: password));

  /// Guest sign-in with Google or Apple (AUTH-3); provisions a `google`/`apple` account.
  Future<void> signInWithProvider(SocialProvider provider) async =>
      _afterSignIn(await _auth.signInWithProvider(provider));

  Future<void> _afterSignIn(AuthUser signedIn) async {
    if (_prefs.getString(_provisionedKey) != signedIn.uid) {
      try {
        await guardApi(_api.provisionMe);
      } on AppException {
        await _auth.signOut();
        rethrow;
      }
      await _prefs.setString(_provisionedKey, signedIn.uid);
    }
    notifyListeners();
    // Not awaited: the permission prompt and network call must not hold up the UI.
    unawaited(_push?.register());
  }

  /// At start-up: re-register the push token when a session is restored.
  void restore() {
    if (isSignedIn) unawaited(_push?.register());
  }

  Future<void> signOut() async {
    await _push?.unregister();
    await _auth.signOut();
    notifyListeners();
  }

  /// "Delete my account" (`DELETE /api/v1/me`), then signs out locally.
  /// Throws [AccountDeletionBlockedException] while the user still hosts events.
  Future<void> deleteAccount() async {
    try {
      await _api.deleteMe();
    } on ApiException catch (e) {
      if (e.code == 409) throw const AccountDeletionBlockedException();
      throw AppException(apiFailure(e));
    } on SocketException {
      throw const AppException(AppFailure.network);
    }
    await _push?.unregister();
    await _prefs.remove(_provisionedKey);
    try {
      await _auth.signOut();
    } catch (_) {
      // The server already removed the Firebase user; the local session just ends.
    }
    notifyListeners();
  }
}
