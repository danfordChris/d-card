import 'dart:async';

import 'package:dcard_api/api.dart';
import 'package:dcard_door/data/repositories/push_registration_repository.dart';
import 'package:dcard_door/data/services/push_token_source.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePushTokenSource implements PushTokenSource {
  FakePushTokenSource({this.current = 'door-token-1'});

  String? current;
  final refreshes = StreamController<String>.broadcast();

  @override
  DevicePlatform get platform => DevicePlatform.android;

  @override
  Future<String?> token() async => current;

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;
}

class FakeDevicesApi extends DefaultApi {
  final registered = <DeviceRegisterInput>[];
  final unregistered = <String>[];
  bool fail = false;

  @override
  Future<Device?> registerDevice({DeviceRegisterInput? deviceRegisterInput}) async {
    if (fail) throw ApiException(503, 'down');
    registered.add(deviceRegisterInput!);
    return null;
  }

  @override
  Future<void> unregisterDevice(String token) async => unregistered.add(token);
}

void main() {
  test('registers the token as a door device, follows refreshes and unregisters', () async {
    final api = FakeDevicesApi();
    final source = FakePushTokenSource();
    final push = PushRegistrationRepository(api: api, source: source);

    await push.register();
    expect(api.registered.single.token, 'door-token-1');
    expect(api.registered.single.app, DeviceApp.door);
    expect(api.registered.single.platform, DevicePlatform.android);

    source.refreshes.add('door-token-2');
    await pumpEventQueue();
    expect(api.registered.map((d) => d.token), ['door-token-1', 'door-token-2']);

    await push.unregister();
    expect(api.unregistered, ['door-token-2']);
  });

  test('does nothing without a token and swallows API failures', () async {
    final api = FakeDevicesApi();
    await PushRegistrationRepository(api: api, source: const NoPushTokenSource()).register();
    expect(api.registered, isEmpty);

    api.fail = true;
    final push = PushRegistrationRepository(api: api, source: FakePushTokenSource());
    await push.register();
    expect(push.registeredToken, isNull);
    await push.unregister();
    expect(api.unregistered, isEmpty);
  });
}
