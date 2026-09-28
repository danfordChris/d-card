import 'package:dcard_api/api.dart';

import 'auth_service.dart';

/// Adds the app's API key and a fresh ID token to every API request.
class IdTokenAuthentication implements Authentication {
  IdTokenAuthentication(this._auth, {required this.apiKey});

  final AuthService _auth;

  /// Client key the server checks on every /api/v1 request (X-API-Key).
  final String apiKey;

  @override
  Future<void> applyToParams(List<QueryParam> queryParams, Map<String, String> headerParams) async {
    headerParams['X-API-Key'] = apiKey;
    final token = await _auth.idToken();
    if (token != null) headerParams['Authorization'] = 'Bearer $token';
  }
}

DefaultApi createApi({required String baseUrl, required String apiKey, required AuthService auth}) => DefaultApi(
  ApiClient(
    basePath: baseUrl,
    authentication: IdTokenAuthentication(auth, apiKey: apiKey),
  ),
);
