import 'package:dcard_door/app.dart';
import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/repositories/push_registration_repository.dart';
import 'package:dcard_door/data/repositories/session_repository.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fakes.dart';

var now = DateTime.utc(2026, 12, 12, 15);

Widget fakeScanner(BuildContext context, ValueChanged<String> onScanned) => Column(
  children: [
    for (final token in ['qr-inv-1', 'qr-inv-2', 'qr-used', 'unknown'])
      TextButton(key: Key('scan.$token'), onPressed: () => onScanned(token), child: Text(token)),
  ],
);

Future<(FakeAuthService, FakeDoorApi)> pumpApp(
  WidgetTester tester, {
  String? locale = 'en',
  FakeAuthService? auth,
  FakeDoorApi? api,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final a = auth ?? FakeAuthService();
  final p =
      api ??
      FakeDoorApi(
        clock: () => now,
        cards: [
          cardJson(),
          cardJson(id: 'inv-2', guestName: 'Baraka', partnerName: 'Neema', cardType: 'double', table: null),
          cardJson(
            id: 'used',
            guestName: 'Rehema',
            cardNumber: '010-0001',
            used: 1,
            entries: [entryJson(occurredAt: '2026-12-12T15:05:00.000Z')],
          ),
        ],
      );
  await tester.pumpWidget(
    DCardApp(
      session: SessionRepository(
        auth: a,
        api: p,
        prefs: prefs,
        push: PushRegistrationRepository(api: p, source: FakePushTokenSource()),
      ),
      door: DoorRepository(p, DoorDeviceStore(prefs)),
      scanner: fakeScanner,
      locale: locale == null ? null : Locale(locale),
      clock: () => now,
    ),
  );
  await tester.pumpAndSettle();
  return (a, p);
}

Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('login.email')), 'door@example.com');
  await tester.enterText(find.byKey(const Key('login.password')), 'secret1');
  await tester.tap(find.byKey(const Key('login.submit')));
  await tester.pumpAndSettle();
}

Future<void> openEvent(WidgetTester tester) async {
  await signIn(tester);
  await tester.tap(find.byKey(const Key('events.e1')));
  await tester.pumpAndSettle();
}

Future<void> typeCardNumber(WidgetTester tester, String number) async {
  for (final d in number.replaceAll('-', '').split('')) {
    await tester.tap(find.byKey(Key('pad.$d')));
  }
  await tester.pump();
  await tester.tap(find.byKey(const Key('pad.find')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => now = DateTime.utc(2026, 12, 12, 15));

  testWidgets('defaults to Swahili unless the device is English', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('fr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pumpApp(tester, locale: null);
    expect(find.text('Ingia kukagua wageni mlangoni'), findsOneWidget);
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
    expect(find.text('Weka barua pepe yako.'), findsOneWidget);
  });

  testWidgets('signs in, registers push, opens the event and checks a guest in by QR', (tester) async {
    final (_, api) = await pumpApp(tester);
    await signIn(tester);
    expect(api.provisionCalls, 1);
    expect(api.pushRegistered, ['door-token-1']);
    expect(find.text('Choose event'), findsOneWidget);
    expect(find.textContaining('Door staff'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('events.deviceName')), 'Gate 1');
    await tester.tap(find.byKey(const Key('events.e1')));
    await tester.pumpAndSettle();
    expect(api.registrations.single['name'], 'Gate 1');
    expect(find.text('Harusi ya Asha'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scan.qr-inv-1')));
    await tester.pumpAndSettle();
    expect(find.text('Valid card'), findsOneWidget);
    expect(find.text('Asha Juma'), findsOneWidget);
    expect(find.text('SINGLE'), findsOneWidget);
    expect(find.text('1 of 1 left'), findsOneWidget);
    expect(find.text('Table 12'), findsOneWidget);
    expect(find.text('Issued'), findsOneWidget);
    expect(find.byKey(const Key('result.admit2')), findsNothing);

    await tester.tap(find.byKey(const Key('result.admit1')));
    await tester.pumpAndSettle();
    expect(find.text('1 guest admitted'), findsOneWidget);
    expect(find.text('0 of 1 left'), findsOneWidget);
    expect(api.admits.single['deviceId'], api.registrations.single['deviceId']);

    await tester.tap(find.byKey(const Key('result.next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scan.qr-inv-1')), findsOneWidget);
  });

  testWidgets('double card offers Admit 2 and shows both names', (tester) async {
    await pumpApp(tester);
    await openEvent(tester);
    await tester.tap(find.byKey(const Key('scan.qr-inv-2')));
    await tester.pumpAndSettle();
    expect(find.text('Baraka & Neema'), findsOneWidget);
    expect(find.text('DOUBLE'), findsOneWidget);
    expect(find.text('No table'), findsOneWidget);
    await tester.tap(find.byKey(const Key('result.admit2')));
    await tester.pumpAndSettle();
    expect(find.text('2 guests admitted'), findsOneWidget);
  });

  testWidgets('fully used card is refused with the earlier entry times (Swahili)', (tester) async {
    await pumpApp(tester, locale: 'sw');
    await openEvent(tester);
    await tester.tap(find.byKey(const Key('scan.qr-used')));
    await tester.pumpAndSettle();
    expect(find.text('Kadi imeshatumika yote'), findsOneWidget);
    expect(find.text('Walioingia awali'), findsOneWidget);
    expect(find.textContaining('18:05 · 1 waliingia · Gate 1 · Juma'), findsOneWidget);
    expect(find.byKey(const Key('result.admit1')), findsNothing);

    await tester.tap(find.byKey(const Key('result.next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scan.unknown')));
    await tester.pumpAndSettle();
    expect(find.text('Kadi haipatikani'), findsOneWidget);
  });

  testWidgets('name search lists cards and opens the chosen one', (tester) async {
    await pumpApp(tester);
    await openEvent(tester);
    await tester.tap(find.byKey(const Key('mode.name')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name.query')), 'neema');
    await tester.tap(find.byKey(const Key('name.search')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('match.inv-2')));
    await tester.pumpAndSettle();
    expect(find.text('Baraka & Neema'), findsOneWidget);
    expect(find.text('Valid card'), findsOneWidget);
  });

  testWidgets('3 wrong card numbers lock the keypad with a countdown', (tester) async {
    final (_, api) = await pumpApp(tester);
    await openEvent(tester);
    await tester.tap(find.byKey(const Key('mode.number')));
    await tester.pumpAndSettle();

    await typeCardNumber(tester, '007-1234');
    expect(find.text('Asha Juma'), findsOneWidget);
    expect(api.lookups.last['cardNumber'], '007-1234');
    await tester.tap(find.byKey(const Key('result.next')));
    await tester.pumpAndSettle();

    for (var i = 0; i < 2; i++) {
      await typeCardNumber(tester, '111-1111');
      expect(find.text('Card not found'), findsOneWidget);
      await tester.tap(find.byKey(const Key('result.next')));
      await tester.pumpAndSettle();
    }
    await typeCardNumber(tester, '111-1111');
    expect(find.text('Card-number entry locked'), findsOneWidget);
    expect(find.byKey(const Key('checkIn.lockCountdown')), findsOneWidget);
    expect(find.text('5:00'), findsOneWidget);
    final key = tester.widget<FilledButton>(find.byKey(const Key('pad.1')));
    expect(key.onPressed, isNull);

    now = now.add(const Duration(seconds: 61));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('3:59'), findsOneWidget);

    now = now.add(const Duration(minutes: 4));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('checkIn.lockBanner')), findsNothing);
    expect(tester.widget<FilledButton>(find.byKey(const Key('pad.1'))).onPressed, isNotNull);
  });

  testWidgets('a revoked device returns to sign-in with a message', (tester) async {
    final (auth, api) = await pumpApp(tester);
    await openEvent(tester);
    api.revoked = true;
    await tester.tap(find.byKey(const Key('scan.qr-inv-1')));
    await tester.pumpAndSettle();
    expect(auth.currentUser, isNull);
    expect(find.byKey(const Key('login.email')), findsOneWidget);
    expect(find.text('This phone can no longer check guests in for this event. Ask the host.'), findsOneWidget);
    expect(api.pushUnregistered, ['door-token-1']);
  });

  testWidgets('sign-in failure is shown; sign-out removes the push token', (tester) async {
    final auth = FakeAuthService(failure: AppFailure.invalidCredentials);
    final (_, api) = await pumpApp(tester, auth: auth);
    await signIn(tester);
    expect(find.text('Wrong email or password.'), findsOneWidget);
    expect(api.provisionCalls, 0);

    auth.failure = null;
    await signIn(tester);
    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login.email')), findsOneWidget);
    expect(api.pushUnregistered, ['door-token-1']);
  });
}
