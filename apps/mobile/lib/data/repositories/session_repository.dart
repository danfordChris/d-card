import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_failure.dart';
import '../services/auth_service.dart';
import 'api_errors.dart';

/// Who is signed in. After a sign-in it provisions the D-Card account once
/// (`POST /api/v1/me`) and remembers that per Firebase UID.
class SessionRepository extends ChangeNotifier {
  SessionRepository({required this._auth, required this._api, required this._prefs});

  static const _provisionedKey = 'session.provisioned_uid';

  final AuthService _auth;
  final DefaultApi _api;
  final SharedPreferences _prefs;

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
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
