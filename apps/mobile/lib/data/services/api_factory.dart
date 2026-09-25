import 'package:dcard_api/api.dart';

import 'auth_service.dart';

/// Adds a fresh ID token to every API request.
class IdTokenAuthentication implements Authentication {
  IdTokenAuthentication(this._auth);

  final AuthService _auth;

  @override
  Future<void> applyToParams(List<QueryParam> queryParams, Map<String, String> headerParams) async {
    final token = await _auth.idToken();
    if (token != null) headerParams['Authorization'] = 'Bearer $token';
  }
}

DefaultApi createApi({required String baseUrl, required AuthService auth}) =>
    DefaultApi(ApiClient(basePath: baseUrl, authentication: IdTokenAuthentication(auth)));
