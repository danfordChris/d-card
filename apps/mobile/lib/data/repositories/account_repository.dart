import 'dart:io';

import 'package:dcard_api/api.dart' as api;
import 'package:http/http.dart' as http;

import '../../domain/models/app_failure.dart';
import '../services/file_saver.dart';
import 'api_errors.dart';

/// Account privacy actions: "Download my data" (`GET /api/v1/me/export`).
/// "Delete my account" lives in `SessionRepository`, which owns the sign-in state.
class AccountRepository {
  AccountRepository(this._api, this._files);

  final api.DefaultApi _api;
  final FileSaver _files;

  /// Downloads the JSON export and saves it; returns where it was saved.
  Future<String> exportMyData() async {
    final http.Response response;
    try {
      response = await _api.exportMyDataWithHttpInfo();
    } on api.ApiException catch (e) {
      throw AppException(apiFailure(e));
    } on SocketException {
      throw const AppException(AppFailure.network);
    } on HttpException {
      throw const AppException(AppFailure.network);
    }
    final status = response.statusCode;
    if (status == 401 || status == 403) throw const AppException(AppFailure.unauthorized);
    if (status == 429) throw const AppException(AppFailure.tooManyRequests);
    if (status >= 400 || response.bodyBytes.isEmpty) throw const AppException(AppFailure.unknown);
    return _files.save(fileNameFrom(response.headers['content-disposition']), response.bodyBytes);
  }

  /// The server's `attachment; filename="…"`, or a dated default.
  static String fileNameFrom(String? disposition, {DateTime? now}) {
    final match = RegExp(r'filename="?([A-Za-z0-9._-]+)"?').firstMatch(disposition ?? '');
    if (match != null) return match.group(1)!;
    final day = (now ?? DateTime.now()).toIso8601String().substring(0, 10);
    return 'dcard-my-data-$day.json';
  }
}
