import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/app_failure.dart';
import 'auth_service.dart';

/// Firebase Auth: email/password for hosts, Google/Apple for guests
/// (docs/design/integrations/firebase.md, AUTH-3).
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth);

  final FirebaseAuth _auth;

  @override
  AuthUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _toUser(result.user)!;
    } on FirebaseAuthException catch (e) {
      throw AppException(_failure(e.code));
    }
  }

  @override
  Future<AuthUser> signInWithProvider(SocialProvider provider) async {
    final AuthProvider authProvider = switch (provider) {
      SocialProvider.google => GoogleAuthProvider()..addScope('email'),
      SocialProvider.apple => AppleAuthProvider()
        ..addScope('email')
        ..addScope('name'),
    };
    try {
      final result = await _auth.signInWithProvider(authProvider);
      final user = _toUser(result.user);
      if (user == null) throw const AppException(AppFailure.unknown);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AppException(_failure(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> idToken() async => _auth.currentUser?.getIdToken();

  static AppFailure _failure(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-email' ||
    'user-disabled' => AppFailure.invalidCredentials,
    'too-many-requests' => AppFailure.tooManyRequests,
    'network-request-failed' => AppFailure.network,
    'canceled' ||
    'cancelled' ||
    'web-context-canceled' ||
    'web-context-cancelled' ||
    'popup-closed-by-user' ||
    'user-cancelled' => AppFailure.cancelled,
    'account-exists-with-different-credential' || 'credential-already-in-use' => AppFailure.otherSignInMethod,
    _ => AppFailure.unknown,
  };

  static AuthUser? _toUser(User? user) {
    if (user == null) return null;
    final ids = user.providerData.map((p) => p.providerId).toSet();
    final provider = ids.contains('google.com')
        ? 'google'
        : ids.contains('apple.com')
        ? 'apple'
        : 'password';
    return AuthUser(uid: user.uid, email: user.email, provider: provider);
  }
}
