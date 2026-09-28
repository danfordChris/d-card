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
    throw AppException(failureOf(e));
  } on SocketException {
    throw const AppException(AppFailure.network);
  } on HttpException {
    throw const AppException(AppFailure.network);
  }
}

AppFailure failureOf(ApiException e) {
  if (e.innerException is SocketException || e.innerException is HttpException) return AppFailure.network;
  return e.code == 401 || e.code == 403 ? AppFailure.unauthorized : AppFailure.unknown;
}
