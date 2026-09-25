/// Failures the UI knows how to explain to the user.
enum AppFailure { invalidCredentials, tooManyRequests, network, unauthorized, unknown }

class AppException implements Exception {
  const AppException(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'AppException($failure)';
}
