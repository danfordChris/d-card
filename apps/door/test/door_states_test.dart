import 'dart:io';

import 'package:dcard_api/api.dart' show ApiException, DoorDeviceRegisterInput, DoorLookupInput, DoorSyncUpload;
import 'package:dcard_door/app.dart';
import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/repositories/door_sync_repository.dart';
import 'package:dcard_door/data/repositories/offline_check_in_repository.dart';
import 'package:dcard_door/data/repositories/push_registration_repository.dart';
import 'package:dcard_door/data/repositories/session_repository.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:dcard_door/domain/models/door_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_test.dart' show fakeScanner, signIn, typeCardNumber;
import 'fakes/fakes.dart';

// T06-08: how the door reacts to revocation, lockouts and edge cases.

var now = DateTime.utc(2026, 12, 12, 15);

/// A door API with the extra behaviours these states need.
class EdgeDoorApi extends FakeDoorApi {
  EdgeDoorApi({super.events, super.cards}) : super(clock: _serverNow);

  static Duration _ahead = Duration.zero;

  /// The fake server's clock: [now] plus [serverAhead].
  static DateTime _serverNow() => now.add(_ahead);

  /// Revoked devices normally get 403 on uploads too; true lets the last upload through.
  bool acceptUploadsWhenRevoked = false;

  /// Sync downloads fail with a network error (other calls still work).
  bool downloadOffline = false;

  /// Server clock minus [now]; responses carry a `Date` header when set.
  Duration? get serverAhead => _ahead == Duration.zero && !_dateHeaders ? null : _ahead;
  set serverAhead(Duration? value) {
    _ahead = value ?? Duration.zero;
    _dateHeaders = value != null;
  }

  bool _dateHeaders = false;

  http.Response _dated(http.Response r) {
    final ahead = serverAhead;
    if (ahead == null) return r;
    return http.Response.bytes(r.bodyBytes, r.statusCode, headers: {...r.headers, 'date': HttpDate.format(_serverNow())});
  }

  @override
  Future<http.Response> doorSyncUploadWithHttpInfo({DoorSyncUpload? doorSyncUpload}) async {
    if (!acceptUploadsWhenRevoked || !revoked) return _dated(await super.doorSyncUploadWithHttpInfo(doorSyncUpload: doorSyncUpload));
    revoked = false;
    try {
      return await super.doorSyncUploadWithHttpInfo(doorSyncUpload: doorSyncUpload);
    } finally {
      revoked = true;
    }
  }

  @override
  Future<http.Response> doorSyncDownloadWithHttpInfo(String deviceId, {String? since, int? pending}) async {
    if (downloadOffline) {
      throw ApiException.withInner(400, 'Socket operation failed', const SocketException('down'), null);
    }
    return _dated(await super.doorSyncDownloadWithHttpInfo(deviceId, since: since, pending: pending));
  }

  @override
  Future<http.Response> registerDoorDeviceWithHttpInfo({DoorDeviceRegisterInput? doorDeviceRegisterInput}) async =>
      _dated(await super.registerDoorDeviceWithHttpInfo(doorDeviceRegisterInput: doorDeviceRegisterInput));

  @override
  Future<http.Response> doorLookupWithHttpInfo({DoorLookupInput? doorLookupInput}) async =>
      _dated(await super.doorLookupWithHttpInfo(doorLookupInput: doorLookupInput));
}

class Harness {
  Harness(this.api, this.sync, this.keys, this.auth);

  final EdgeDoorApi api;
  final DoorSyncRepository? sync;
  final MemoryKeyStore keys;
  final FakeAuthService auth;
}

List<Map<String, dynamic>> defaultCards() => [
  cardJson(),
  cardJson(id: 'inv-2', guestName: 'Baraka', partnerName: 'Neema', cardType: 'double', table: null),
  cardJson(id: 'used', guestName: 'Rehema', cardNumber: '010-0001', used: 1),
];

/// The app with the encrypted offline cache (in-memory SQLite) unless [withCache] is false.
Future<Harness> pumpDoor(
  WidgetTester tester, {
  String locale = 'en',
  bool withCache = true,
  List<Map<String, dynamic>>? events,
  List<Map<String, dynamic>>? cards,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final api = EdgeDoorApi(events: events, cards: cards ?? defaultCards());
  final door = DoorRepository(api, DoorDeviceStore(prefs), clock: () => now);
  final keys = MemoryKeyStore();
  final store = memoryCacheStore(keys: keys);
  final sync = withCache ? DoorSyncRepository(door: door, store: store, clock: () => now, autoSchedule: false) : null;
  final offline = sync == null ? null : OfflineCheckInRepository(store: store, sync: sync, clock: () => now);
  final auth = FakeAuthService();
  final session = SessionRepository(
    auth: auth,
    api: api,
    prefs: prefs,
    push: PushRegistrationRepository(api: api, source: FakePushTokenSource()),
    beforeSignOut: sync == null ? null : (because) => sync.signOut(upload: because != AppFailure.doorAccessDenied),
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
  return Harness(api, sync, keys, auth);
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

Future<void> openEvent(WidgetTester tester) async {
  await signIn(tester);
  await tapAndSettle(tester, 'events.e1');
}

void main() {
  setUp(() {
    now = DateTime.utc(2026, 12, 12, 15);
    EdgeDoorApi._ahead = Duration.zero;
  });

  group('revoked device', () {
    testWidgets('stops scanning and shows the revoked screen; another event or sign-out from there', (tester) async {
      final h = await pumpDoor(tester, withCache: false);
      await openEvent(tester);
      h.api.revoked = true;
      await tapAndSettle(tester, 'scan.qr-inv-1');

      expect(find.byKey(const Key('revoked.screen')), findsOneWidget);
      expect(find.text('This phone was removed'), findsOneWidget);
      expect(find.textContaining('check guests in for Harusi ya Asha'), findsOneWidget);
      expect(find.text('Nothing saved offline was lost.'), findsOneWidget);
      expect(find.byKey(const Key('scan.qr-inv-1')), findsNothing, reason: 'the scanner is gone');
      expect(h.auth.currentUser, isNotNull, reason: 'still signed in');

      h.api.revoked = false;
      await tapAndSettle(tester, 'revoked.chooseEvent');
      expect(find.text('Choose event'), findsOneWidget);
      await tapAndSettle(tester, 'events.e1');
      expect(find.byKey(const Key('scan.qr-inv-1')), findsOneWidget);
    });

    testWidgets('sign-out from the revoked screen goes back to sign-in (Swahili)', (tester) async {
      final h = await pumpDoor(tester, locale: 'sw', withCache: false);
      await openEvent(tester);
      h.api.revoked = true;
      await tapAndSettle(tester, 'scan.qr-inv-1');
      expect(find.text('Simu hii imeondolewa'), findsOneWidget);
      expect(find.text('Chagua tukio jingine'), findsOneWidget);

      await tapAndSettle(tester, 'revoked.signOut');
      expect(find.byKey(const Key('login.email')), findsOneWidget);
      expect(h.auth.currentUser, isNull);
      expect(h.api.pushUnregistered, ['door-token-1']);
    });

    testWidgets('pending offline entries get one upload try; refused ones are counted as lost, cache wiped', (
      tester,
    ) async {
      final h = await pumpDoor(tester);
      await openEvent(tester);
      h.api.offline = true;
      await tapAndSettle(tester, 'scan.qr-inv-1');
      await tapAndSettle(tester, 'result.admit1');
      await tapAndSettle(tester, 'result.next');
      expect(h.sync!.pendingCount, 1);

      h.api
        ..offline = false
        ..revoked = true;
      await tapAndSettle(tester, 'checkIn.syncStatus');

      expect(find.byKey(const Key('revoked.screen')), findsOneWidget);
      expect(find.text('1 entry saved offline could not be sent and was deleted. Tell the host.'), findsOneWidget);
      expect(h.api.uploads, isNotEmpty, reason: 'the upload was tried');
      expect(h.api.syncedEntries, isEmpty);
      expect(h.keys.key, isNull, reason: 'cache key deleted');
      expect(h.sync!.pendingCount, 0);
      expect(h.sync!.revoked, isTrue);
    });

    testWidgets('when the server still takes the upload, nothing is lost before the wipe', (tester) async {
      final h = await pumpDoor(tester);
      await openEvent(tester);
      h.api.offline = true;
      await tapAndSettle(tester, 'scan.qr-inv-2');
      await tapAndSettle(tester, 'result.admit2');
      await tapAndSettle(tester, 'result.next');

      h.api
        ..offline = false
        ..revoked = true
        ..acceptUploadsWhenRevoked = true;
      await tapAndSettle(tester, 'checkIn.syncStatus');

      expect(find.byKey(const Key('revoked.screen')), findsOneWidget);
      expect(find.text('Nothing saved offline was lost.'), findsOneWidget);
      expect(h.api.syncedEntries.values.single['admittedCount'], 2);
      expect(h.keys.key, isNull);
    });

    testWidgets('registering a revoked phone again shows the revoked screen', (tester) async {
      final h = await pumpDoor(tester, withCache: false);
      await signIn(tester);
      h.api.revoked = true;
      await tapAndSettle(tester, 'events.e1');
      expect(find.byKey(const Key('revoked.screen')), findsOneWidget);
    });
  });

  group('card-number lockout', () {
    testWidgets('shows the countdown and what to do instead; the lock holds after reopening the event', (
      tester,
    ) async {
      await pumpDoor(tester);
      await openEvent(tester);
      await tapAndSettle(tester, 'mode.number');
      for (var i = 0; i < 2; i++) {
        await typeCardNumber(tester, '111-1111');
        await tapAndSettle(tester, 'result.next');
      }
      await typeCardNumber(tester, '111-1111');
      await settle(tester);
      expect(find.byKey(const Key('checkIn.lockBanner')), findsOneWidget);
      expect(find.byKey(const Key('checkIn.lockedPad')), findsOneWidget);
      expect(find.text('5:00'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byKey(const Key('pad.1'))).onPressed, isNull);

      await tapAndSettle(tester, 'checkIn.changeEvent');
      await tapAndSettle(tester, 'events.e1');
      now = now.add(const Duration(minutes: 1));
      await settle(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('checkIn.lockBanner')), findsOneWidget, reason: 'restored from the phone');
      expect(find.text('4:00'), findsOneWidget);

      await tapAndSettle(tester, 'mode.number');
      await tapAndSettle(tester, 'lockedPad.name');
      expect(find.byKey(const Key('name.query')), findsOneWidget);
    });

    testWidgets('the server lock expiry is shown on the phone clock when the clocks differ', (tester) async {
      final h = await pumpDoor(tester, withCache: false);
      // The phone runs 10 minutes behind the server.
      h.api.serverAhead = const Duration(minutes: 10);
      await openEvent(tester);
      await tapAndSettle(tester, 'mode.number');
      for (var i = 0; i < 3; i++) {
        await typeCardNumber(tester, '111-1111');
        if (i < 2) await tapAndSettle(tester, 'result.next');
      }
      // The fake server locks until its own now + 5 min; still 5:00 on the phone.
      expect(find.text('5:00'), findsOneWidget);
    });
  });

  group('event timing', () {
    testWidgets('an event that has not started warns first; staff can continue', (tester) async {
      now = DateTime.utc(2026, 12, 11, 9);
      await pumpDoor(tester, withCache: false);
      await openEvent(tester);
      expect(find.byKey(const Key('checkIn.notStarted')), findsOneWidget);
      expect(find.text('Event has not started'), findsOneWidget);
      expect(find.byKey(const Key('scan.qr-inv-1')), findsNothing);

      await tapAndSettle(tester, 'state.continue');
      expect(find.byKey(const Key('scan.qr-inv-1')), findsOneWidget);
    });

    testWidgets('an event that has ended warns (Swahili); change event goes back', (tester) async {
      final ended = eventJson()..['endsAt'] = '2026-12-12T14:00:00.000Z';
      await pumpDoor(tester, locale: 'sw', withCache: false, events: [ended]);
      await openEvent(tester);
      expect(find.byKey(const Key('checkIn.ended')), findsOneWidget);
      expect(find.text('Tukio limeisha'), findsOneWidget);

      await tapAndSettle(tester, 'state.changeEvent');
      expect(find.text('Chagua tukio'), findsOneWidget);
    });

    test('timing uses a 3 h early window and 12 h default length', () {
      final event = DoorEvent(id: 'e', title: 't', startsAt: DateTime.utc(2026, 12, 12, 12), role: DoorRole.doorStaff);
      expect(event.timingAt(DateTime.utc(2026, 12, 12, 8, 59)), EventTiming.upcoming);
      expect(event.timingAt(DateTime.utc(2026, 12, 12, 9)), EventTiming.open);
      expect(event.timingAt(DateTime.utc(2026, 12, 13)), EventTiming.open);
      expect(event.timingAt(DateTime.utc(2026, 12, 13, 0, 1)), EventTiming.ended);
    });

    testWidgets('24 h after the event the offline copy is wiped and the door says so', (tester) async {
      now = DateTime.utc(2026, 12, 14, 1);
      final h = await pumpDoor(tester);
      await openEvent(tester);
      expect(find.byKey(const Key('checkIn.expired')), findsOneWidget);
      expect(find.text('Event is over'), findsOneWidget);
      expect(h.keys.key, isNull);
    });
  });

  group('card states', () {
    testWidgets('a cancelled card says so and what to do', (tester) async {
      await pumpDoor(tester, withCache: false, cards: [cardJson(status: 'cancelled')]);
      await openEvent(tester);
      await tapAndSettle(tester, 'scan.qr-inv-1');
      expect(find.text('Card cancelled'), findsOneWidget);
      expect(find.byKey(const Key('result.detail')), findsOneWidget);
      expect(find.textContaining('The host cancelled this card. Do not admit.'), findsOneWidget);
      expect(find.byKey(const Key('result.admit1')), findsNothing);
    });

    testWidgets('an over-used card is flagged with the reason and no admit', (tester) async {
      await pumpDoor(
        tester,
        withCache: false,
        cards: [
          cardJson(
            used: 2,
            overUsed: true,
            entries: [entryJson(), entryJson(id: 'en-2', deviceName: 'Gate 2')],
          ),
        ],
      );
      await openEvent(tester);
      await tapAndSettle(tester, 'scan.qr-inv-1');
      expect(find.text('Card over-used'), findsOneWidget);
      expect(find.textContaining('The host has been alerted'), findsOneWidget);
      expect(find.byKey(const Key('result.admit1')), findsNothing);
    });
  });

  group('network and clock', () {
    testWidgets('no network and no saved guest list: clear state with retry', (tester) async {
      final h = await pumpDoor(tester);
      h.api.downloadOffline = true;
      await openEvent(tester);
      expect(find.byKey(const Key('checkIn.noNetwork')), findsOneWidget);
      expect(find.text('No network'), findsOneWidget);
      expect(find.byKey(const Key('scan.qr-inv-1')), findsNothing);

      h.api.downloadOffline = false;
      await tapAndSettle(tester, 'state.retry');
      expect(find.byKey(const Key('checkIn.noNetwork')), findsNothing);
      expect(find.byKey(const Key('scan.qr-inv-1')), findsOneWidget);
    });

    testWidgets('event list without network and nothing saved offline', (tester) async {
      final h = await pumpDoor(tester);
      h.api.offline = true;
      await signIn(tester);
      await settle(tester);
      expect(find.byKey(const Key('events.noNetwork')), findsOneWidget);

      h.api.offline = false;
      await tapAndSettle(tester, 'events.retry');
      expect(find.byKey(const Key('events.e1')), findsOneWidget);
    });

    testWidgets('a phone clock that is off shows a warning', (tester) async {
      final h = await pumpDoor(tester, withCache: false);
      h.api.serverAhead = const Duration(minutes: 12);
      await openEvent(tester);
      expect(find.byKey(const Key('checkIn.clockSkew')), findsOneWidget);
      expect(find.textContaining("This phone's clock is 12 min off"), findsOneWidget);
    });

    testWidgets('a small clock difference is not reported', (tester) async {
      final h = await pumpDoor(tester, withCache: false);
      h.api.serverAhead = const Duration(minutes: 2);
      await openEvent(tester);
      expect(find.byKey(const Key('checkIn.clockSkew')), findsNothing);
    });
  });
}
