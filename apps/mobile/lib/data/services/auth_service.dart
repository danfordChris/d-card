/// Guest sign-in providers (AUTH-3: Google or Apple only, no OTP).
enum SocialProvider { google, apple }

/// The signed-in Firebase user, as far as the app needs to know.
class AuthUser {
  const AuthUser({required this.uid, required this.email, this.provider = 'password'});

  final String uid;
  final String? email;

  /// `password`, `google` or `apple`.
  final String provider;

  bool get isSocial => provider != 'password';
}

/// Sign-in provider boundary (Firebase in the app, fakes in tests and local dev).
abstract interface class AuthService {
  AuthUser? get currentUser;

  /// Throws `AppException` on failure.
  Future<AuthUser> signIn({required String email, required String password});

  /// Google or Apple sign-in. Throws `AppException` (`AppFailure.cancelled` when the person closes the sheet).
  Future<AuthUser> signInWithProvider(SocialProvider provider);

  Future<void> signOut();

  /// A current ID token for `Authorization: Bearer`, or null when signed out.
  Future<String?> idToken();
}
