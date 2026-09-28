/// Failures the UI knows how to explain to the user.
enum AppFailure {
  invalidCredentials,
  tooManyRequests,
  network,
  unauthorized,

  /// The person closed the Google/Apple sign-in sheet; nothing to show.
  cancelled,

  /// The email already signs in with another method (e.g. password vs Google).
  otherSignInMethod,
  unknown,
}

class AppException implements Exception {
  const AppException(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'AppException($failure)';
}
