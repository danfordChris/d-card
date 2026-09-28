import 'package:dcard_door/app.dart';
import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/repositories/door_sync_repository.dart';
import 'package:dcard_door/data/repositories/offline_check_in_repository.dart';
import 'package:dcard_door/data/repositories/push_registration_repository.dart';
import 'package:dcard_door/data/repositories/session_repository.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_test.dart' show fakeScanner, signIn, usePhoneScreen;
import 'fakes/fakes.dart';

var now = DateTime.utc(2026, 12, 12, 15);

class Harness {
  Harness(this.api, this.sync, this.keys);

  final FakeDoorApi api;
  final DoorSyncRepository sync;
  final MemoryKeyStore keys;
}

Future<Harness> pumpOfflineApp(WidgetTester tester, {String locale = 'en'}) async {
  usePhoneScreen(tester);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final api = FakeDoorApi(
    clock: () => now,
    cards: [
      cardJson(),
      cardJson(id: 'inv-2', guestName: 'Baraka', partnerName: 'Neema', cardType: 'double', table: null),
      cardJson(id: 'used', guestName: 'Rehema', cardNumber: '010-0001', used: 1),
    ],
  );
  final door = DoorRepository(api, DoorDeviceStore(prefs));
  final keys = MemoryKeyStore();
  final store = memoryCacheStore(keys: keys);
  final sync = DoorSyncRepository(door: door, store: store, clock: () => now, autoSchedule: false);
  final offline = OfflineCheckInRepository(store: store, sync: sync, clock: () => now);
  final session = SessionRepository(
    auth: FakeAuthService(),
    api: api,
    prefs: prefs,
    push: PushRegistrationRepository(api: api, source: FakePushTokenSource()),
    beforeSignOut: (because) => sync.signOut(upload: because != AppFailure.doorAccessDenied),
  );
  await tester.pumpWidget(
    DCardApp(
      session: session,
      door: door,
      sync: sync,
      offline: offline,
      scanner: fakeScanner,
      locale: Locale(locale),
      clock: () => now,
    ),
  );
  await tester.pumpAndSettle();
  return Harness(api, sync, keys);
}

/// Lets the cache (real SQLite, off the fake clock) finish, then settles the UI.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}

Future<void> tapAndSettle(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
  await settle(tester);
}

void main() {
  setUp(() => now = DateTime.utc(2026, 12, 12, 15));

  testWidgets('offline check-in shows Offline, waiting count and last sync; sync clears it', (tester) async {
    final h = await pumpOfflineApp(tester);
    await signIn(tester);
    await tapAndSettle(tester, 'events.e1');
    expect(find.byKey(const Key('checkIn.online')), findsOneWidget);
    expect(find.textContaining('All synced'), findsOneWidget);
    expect(find.textContaining('Last sync Dec 12, 18:00'), findsOneWidget);

    h.api.offline = true;
    await tapAndSettle(tester, 'scan.qr-inv-2');
    expect(find.text('Valid card'), findsOneWidget);
    expect(find.byKey(const Key('result.offline')), findsOneWidget);
    expect(find.byKey(const Key('checkIn.offline')), findsOneWidget);

    await tapAndSettle(tester, 'result.admit2');
    expect(find.text('2 guests admitted'), findsOneWidget);
    expect(find.textContaining('1 waiting to sync'), findsOneWidget);
    expect(h.api.admits, isEmpty);

    await tapAndSettle(tester, 'result.next');
    h.api.offline = false;
    await tapAndSettle(tester, 'checkIn.syncStatus');
    expect(find.byKey(const Key('checkIn.online')), findsOneWidget);
    expect(find.textContaining('All synced'), findsOneWidget);
    expect(h.api.syncedEntries.values.single['admittedCount'], 2);

    // The sync chip opened the sync panel; try-now works from there and back returns to scanning.
    expect(find.byKey(const Key('sync.panel')), findsOneWidget);
    expect(find.text('Waiting to upload'), findsOneWidget);
    await tapAndSettle(tester, 'sync.tryNow');
    expect(find.byKey(const Key('checkIn.online')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scan.qr-inv-1')), findsOneWidget);
  });

  testWidgets('walk-in from a refusal: offline admission needs a reason (Swahili)', (tester) async {
    final h = await pumpOfflineApp(tester, locale: 'sw');
    await signIn(tester);
    await tapAndSettle(tester, 'events.e1');
    h.api.offline = true;

    await tapAndSettle(tester, 'scan.qr-used');
    expect(find.text('Kadi imeshatumika yote'), findsOneWidget);
    await tapAndSettle(tester, 'result.walkIn');
    expect(find.text('Kadi: Rehema'), findsOneWidget);
    expect(find.byKey(const Key('walkIn.offlineSwitch')), findsOneWidget);
    expect(find.text('Ingiza bila mtandao'), findsWidgets, reason: 'offline admission is offered');

    await tester.enterText(find.byKey(const Key('walkIn.description')), 'Mjomba wa bibi harusi');
    await tapAndSettle(tester, 'walkIn.submit');
    expect(find.text('Weka sababu (angalau herufi 3).'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('walkIn.reason')), 'mwenyeji ameidhinisha kwa simu');
    await tapAndSettle(tester, 'walkIn.submit');
    expect(find.text('Mgeni 1 ameingia bila mtandao'), findsOneWidget);

    await tapAndSettle(tester, 'walkIn.done');
    expect(find.textContaining('1 inasubiri kutumwa'), findsOneWidget);
  });

  testWidgets('online walk-in waits for the host and shows who refused', (tester) async {
    final h = await pumpOfflineApp(tester);
    await signIn(tester);
    await tapAndSettle(tester, 'events.e1');
    await tapAndSettle(tester, 'checkIn.walkIn');
    expect(find.byKey(const Key('walkIn.offlineSwitch')), findsNothing, reason: 'online: ask the host');
    await tester.enterText(find.byKey(const Key('walkIn.description')), 'Groom\'s friend');
    await tester.tap(find.byKey(const Key('walkIn.submit')));
    // The waiting spinner never settles: pump frames instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Waiting for the host or an approver…'), findsOneWidget);

    h.api.answerWalkIn(h.api.walkIns.keys.single, approve: false, by: 'neema@example.com');
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    await settle(tester);
    expect(find.text('Refused: do not let them in'), findsOneWidget);
    expect(find.text('Refused by neema@example.com'), findsOneWidget);
    await tapAndSettle(tester, 'walkIn.done');
    expect(find.byKey(const Key('scan.qr-inv-1')), findsOneWidget);
  });

  testWidgets('sign-out with entries waiting asks first, then wipes the cache', (tester) async {
    final h = await pumpOfflineApp(tester);
    await signIn(tester);
    await tapAndSettle(tester, 'events.e1');
    h.api.offline = true;
    await tapAndSettle(tester, 'scan.qr-inv-1');
    await tapAndSettle(tester, 'result.admit1');
    await tapAndSettle(tester, 'result.next');
    await tapAndSettle(tester, 'checkIn.changeEvent');

    await tester.tap(find.byKey(const Key('events.signOut')));
    await tester.pumpAndSettle();
    expect(find.text('Not synced yet'), findsOneWidget);
    await tapAndSettle(tester, 'signOut.confirm');
    expect(find.byKey(const Key('login.email')), findsOneWidget);
    expect(h.keys.key, isNull, reason: 'cache key deleted');
    expect(h.sync.pendingCount, 0);
  });

  testWidgets('without network the cached event can be reopened from event select', (tester) async {
    final h = await pumpOfflineApp(tester);
    await signIn(tester);
    await tapAndSettle(tester, 'events.e1');
    await tapAndSettle(tester, 'checkIn.changeEvent');

    h.api.offline = true;
    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.text('Continue offline: Harusi ya Asha'), findsOneWidget);
    await tapAndSettle(tester, 'events.offline');
    await tapAndSettle(tester, 'scan.qr-inv-1');
    expect(find.text('Valid card'), findsOneWidget);
    expect(find.byKey(const Key('result.offline')), findsOneWidget);
  });
}
