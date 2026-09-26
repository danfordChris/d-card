/// Failures the UI knows how to explain to the user.
enum AppFailure {
  invalidCredentials,
  tooManyRequests,
  network,
  unauthorized,

  /// 403 from a door endpoint: the host revoked this device, or the account lost door access (AUTH-9).
  doorAccessDenied,

  /// 409 plan_limit when registering: the event already has as many door staff as its plan allows.
  doorPlanLimit,
  unknown,
}

class AppException implements Exception {
  const AppException(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'AppException($failure)';
}
