/// The signed-in Firebase user, as far as the app needs to know.
class AuthUser {
  const AuthUser({required this.uid, required this.email});

  final String uid;
  final String? email;
}

/// Sign-in provider boundary (Firebase in the app, fakes in tests and local dev).
abstract interface class AuthService {
  AuthUser? get currentUser;

  /// Throws `AppException` on failure.
  Future<AuthUser> signIn({required String email, required String password});

  Future<void> signOut();

  /// A current ID token for `Authorization: Bearer`, or null when signed out.
  Future<String?> idToken();
}
