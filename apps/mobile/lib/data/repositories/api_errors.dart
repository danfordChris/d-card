import 'dart:io';

import 'package:dcard_api/api.dart';

import '../../domain/models/app_failure.dart';

/// Runs an API call and converts transport/HTTP errors into [AppException].
Future<T> guardApi<T>(Future<T?> Function() call) async {
  try {
    final result = await call();
    if (result == null) throw const AppException(AppFailure.unknown);
    return result;
  } on ApiException catch (e) {
    throw AppException(apiFailure(e));
  } on SocketException {
    throw const AppException(AppFailure.network);
  }
}

/// The [AppFailure] for an [ApiException] the caller does not handle itself.
AppFailure apiFailure(ApiException e) {
  if (e.innerException is SocketException || e.innerException is HttpException) return AppFailure.network;
  if (e.code == 429) return AppFailure.tooManyRequests;
  return e.code == 401 || e.code == 403 ? AppFailure.unauthorized : AppFailure.unknown;
}
