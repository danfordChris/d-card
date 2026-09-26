import 'dart:async';

import 'package:dcard_api/api.dart';
import 'package:dcard_mobile/app.dart';
import 'package:dcard_mobile/data/repositories/billing_repository.dart';
import 'package:dcard_mobile/data/repositories/contributions_repository.dart';
import 'package:dcard_mobile/data/repositories/events_repository.dart';
import 'package:dcard_mobile/data/repositories/guests_repository.dart';
import 'package:dcard_mobile/data/repositories/push_registration_repository.dart';
import 'package:dcard_mobile/data/repositories/session_repository.dart';
import 'package:dcard_mobile/data/repositories/walk_in_alerts_repository.dart';
import 'package:dcard_mobile/data/repositories/walk_ins_repository.dart';
import 'package:dcard_mobile/data/services/push_token_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fakes.dart';

class FakePushTokenSource implements PushTokenSource {
  FakePushTokenSource({this.current = 'fcm-token-1'});

  String? current;
  int tokenRequests = 0;
  final refreshes = StreamController<String>.broadcast();

  @override
  DevicePlatform get platform => DevicePlatform.android;

  @override
  Future<String?> token() async {
    tokenRequests++;
    return current;
  }

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;
}

/// FakeApi plus the device endpoints.
class DevicesFakeApi extends FakeApi {
  DevicesFakeApi() : super(events: [fakeEvent()]);

  final registered = <DeviceRegisterInput>[];
  final unregistered = <String>[];
  bool failRegister = false;

  @override
  Future<Device?> registerDevice({DeviceRegisterInput? deviceRegisterInput}) async {
    if (failRegister) throw ApiException(500, 'down');
    registered.add(deviceRegisterInput!);
    return Device(
      id: 'd${registered.length}',
      platform: deviceRegisterInput.platform,
      app: deviceRegisterInput.app,
      createdAt: DateTime.utc(2026, 9),
      lastSeenAt: DateTime.utc(2026, 9),
    );
  }

  @override
  Future<void> unregisterDevice(String token) async => unregistered.add(token);
}

void main() {
  group('PushRegistrationRepository', () {
    test('registers the token as a mobile device and re-registers refreshed tokens', () async {
      final api = DevicesFakeApi();
      final source = FakePushTokenSource();
      final push = PushRegistrationRepository(api: api, source: source);

      await push.register();
      expect(api.registered.single.token, 'fcm-token-1');
      expect(api.registered.single.platform, DevicePlatform.android);
      expect(api.registered.single.app, DeviceApp.mobile);

      source.refreshes.add('fcm-token-2');
      await pumpEventQueue();
      expect(api.registered.map((d) => d.token), ['fcm-token-1', 'fcm-token-2']);
      expect(push.registeredToken, 'fcm-token-2');
    });

    test('skips registration without a token (permission denied)', () async {
      final api = DevicesFakeApi();
      await PushRegistrationRepository(api: api, source: FakePushTokenSource(current: null)).register();
      expect(api.registered, isEmpty);
    });

    test('swallows API failures', () async {
      final api = DevicesFakeApi()..failRegister = true;
      final push = PushRegistrationRepository(api: api, source: FakePushTokenSource());
      await push.register();
      expect(push.registeredToken, isNull);
    });

    test('unregister removes the token (URL-encoded) and stops listening for refreshes', () async {
      final api = DevicesFakeApi();
      final source = FakePushTokenSource(current: 'abc:APA91-x');
      final push = PushRegistrationRepository(api: api, source: source);
      await push.register();
      await push.unregister();
      expect(api.unregistered, ['abc%3AAPA91-x']);
      source.refreshes.add('later');
      await pumpEventQueue();
      expect(api.registered, hasLength(1));
    });
  });

  group('app', () {
    testWidgets('registers the push token after sign-in and removes it on sign-out', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final auth = FakeAuthService();
      final api = DevicesFakeApi();
      final source = FakePushTokenSource();
      final push = PushRegistrationRepository(api: api, source: source);
      await tester.pumpWidget(
        DCardApp(
          session: SessionRepository(auth: auth, api: api, prefs: prefs, push: push),
          events: EventsRepository(api),
          guests: GuestsRepository(api),
          contacts: FakeContactsSource(),
          contributions: ContributionsRepository(api),
          walkIns: WalkInsRepository(api),
          walkInAlerts: WalkInAlertsRepository(FakePushMessageSource()),
          billing: BillingRepository(api),
          links: FakeLinkOpener(),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(source.tokenRequests, 0, reason: 'no token before sign-in');

      await tester.enterText(find.byKey(const Key('login.email')), 'host@example.com');
      await tester.enterText(find.byKey(const Key('login.password')), 'secret1');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(api.registered.single.token, 'fcm-token-1');

      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();
      expect(api.unregistered, ['fcm-token-1']);
      expect(auth.currentUser, isNull);
    });

    test('restore registers when a session is already signed in', () async {
      SharedPreferences.setMockInitialValues({'session.provisioned_uid': 'uid-host@example.com'});
      final prefs = await SharedPreferences.getInstance();
      final auth = FakeAuthService();
      await auth.signIn(email: 'host@example.com', password: 'x');
      final api = DevicesFakeApi();
      SessionRepository(
        auth: auth,
        api: api,
        prefs: prefs,
        push: PushRegistrationRepository(api: api, source: FakePushTokenSource()),
      ).restore();
      await pumpEventQueue();
      expect(api.registered, hasLength(1));
    });
  });
}
