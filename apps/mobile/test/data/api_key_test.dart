import 'package:dcard_mobile/data/services/api_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fakes.dart';

void main() {
  test('every request carries X-API-Key, plus the bearer token when signed in', () async {
    final auth = FakeAuthService();
    final authentication = IdTokenAuthentication(auth, apiKey: 'dk_mobile_test');
    final signedOut = <String, String>{};
    await authentication.applyToParams([], signedOut);
    expect(signedOut, {'X-API-Key': 'dk_mobile_test'});

    await auth.signIn(email: 'host@example.com', password: 'x');
    final signedIn = <String, String>{};
    await authentication.applyToParams([], signedIn);
    expect(signedIn, {'X-API-Key': 'dk_mobile_test', 'Authorization': 'Bearer token'});
  });
}
