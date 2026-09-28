import 'auth_service.dart';

/// Local development only (`--dart-define=AUTH_MODE=fake`, debug builds): issues
/// `fake:<uid>:<email>` tokens accepted by the API when `AUTH_VERIFIER=fake`.
class DevAuthService implements AuthService {
  AuthUser? _user;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final normalised = email.trim().toLowerCase();
    return _user = AuthUser(uid: 'dev-${normalised.replaceAll(RegExp('[^a-z0-9]'), '-')}', email: normalised);
  }

  @override
  Future<void> signOut() async => _user = null;

  @override
  Future<String?> idToken() async => _user == null ? null : 'fake:${_user!.uid}:${_user!.email}';
}
