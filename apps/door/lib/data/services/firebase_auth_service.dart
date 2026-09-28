import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/app_failure.dart';
import 'auth_service.dart';

/// Email/password sign-in with Firebase Auth (docs/design/integrations/firebase.md).
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
      throw AppException(switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-email' ||
        'user-disabled' => AppFailure.invalidCredentials,
        'too-many-requests' => AppFailure.tooManyRequests,
        'network-request-failed' => AppFailure.network,
        _ => AppFailure.unknown,
      });
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> idToken() async => _auth.currentUser?.getIdToken();

  static AuthUser? _toUser(User? user) => user == null ? null : AuthUser(uid: user.uid, email: user.email);
}
