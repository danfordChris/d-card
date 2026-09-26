import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/repositories/door_sync_repository.dart';
import 'package:dcard_door/data/repositories/offline_check_in_repository.dart';
import 'package:dcard_door/data/services/door_cache_store.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:dcard_door/domain/models/check_in.dart';
import 'package:dcard_door/domain/models/door_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fakes.dart';

/// One door phone: its own encrypted cache, sync and offline check-in.
class Phone {
  Phone(this.api, this.deviceId, this.clock, {FakeConnectivity? connectivity}) {
    store = DoorCacheStore(keys: keys, opener: opener);
    sync = DoorSyncRepository(
      door: door,
      store: store,
      clock: clock,
      autoSchedule: false,
      connectivity: connectivity ?? FakeConnectivity(),
    )..onAccessDenied = (f) async => denied.add(f);
    offline = OfflineCheckInRepository(store: store, sync: sync, clock: clock, newId: () => '$deviceId-a${ids++}');
  }

  static late DoorDeviceStore devices;

  final FakeDoorApi api;
  final String deviceId;
  final DateTime Function() clock;
  final keys = MemoryKeyStore();
  final opener = MemoryDbOpener();
  final denied = <AppFailure>[];
  var ids = 0;
  late final door = DoorRepository(api, devices);
  late final DoorCacheStore store;
  late final DoorSyncRepository sync;
  late final OfflineCheckInRepository offline;

  late final session = DoorSession(
    event: DoorEvent(
      id: 'e1',
      title: 'Harusi ya Asha',
      startsAt: DateTime.utc(2026, 12, 12, 12),
      role: DoorRole.doorStaff,
    ),
    deviceId: deviceId,
    deviceName: 'Gate $deviceId',
  );

  Future<void> start() => sync.start(session);

  Future<CheckInCard> admit(String invitationId, int count, {String? entryId}) => offline.admit(
    session,
    entryId: entryId ?? '$deviceId-e${ids++}',
    invitationId: invitationId,
    count: count,
    method: CheckInMethod.qr,
  );

  Future<CheckInCard> find(CardQuery q) async => (await offline.lookup(session, q)).single;
}

Matcher refusedWith(RefusalReason r) => throwsA(isA<DoorRefusedException>().having((e) => e.reason, 'reason', r));

void main() {
  late FakeDoorApi api;
  late DateTime now;
  late Phone phone;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Phone.devices = DoorDeviceStore(await SharedPreferences.getInstance());
    now = DateTime.utc(2026, 12, 12, 15);
    api = FakeDoorApi(
      clock: () => now,
      cards: [
        cardJson(id: 'inv-1', cardNumber: '007-1234'),
        cardJson(id: 'inv-2', guestName: 'Baraka', partnerName: 'Neema', cardNumber: '008-5555', cardType: 'double'),
        cardJson(id: 'inv-3', guestName: 'Rehema', cardNumber: '009-1111', status: 'cancelled'),
        cardJson(id: 'inv-4', guestName: 'Juma', cardNumber: null, status: 'pending'),
      ],
    );
    phone = Phone(api, 'dev-a', () => now);
    await phone.start();
  });

  tearDown(() => phone.sync.dispose());

  test('opening the event downloads the full cache; later syncs send the cursor and upsert changes', () async {
    expect(api.syncDownloads.single, {'deviceId': 'dev-a', 'since': null, 'pending': 0});
    expect(phone.sync.cacheReady, isTrue);
    expect(phone.sync.online, isTrue);
    expect(phone.sync.lastSyncAt, now);
    expect(phone.sync.approvers.single.name, 'host@example.com');
    expect(phone.offline.isAvailable(phone.session), isTrue);

    api.cards['inv-1']!['status'] = 'cancelled';
    api.touch('inv-1');
    now = now.add(const Duration(seconds: 30));
    expect(await phone.sync.syncNow(), isTrue);
    expect(api.syncDownloads.last['since'], '0');
    expect((await phone.find(const CardNumberQuery('007-1234'))).refusal, RefusalReason.cancelled);
    expect(phone.sync.lastSyncAt, now);
  });

  test('offline QR check hashes the scanned token (SHA-256) and matches the cached digest', () async {
    expect(qrDigestOf('qr-inv-1'), FakeDoorApi.digest('qr-inv-1'));
    expect(qrDigestOf('https://dcard.co.tz/c/qr-inv-1'), FakeDoorApi.digest('qr-inv-1'));
    expect((await phone.find(const QrQuery('qr-inv-2'))).guestName, 'Baraka');
    expect((await phone.find(const QrQuery('https://dcard.co.tz/c/qr-inv-1'))).invitationId, 'inv-1');
    await expectLater(phone.find(const QrQuery('qr-inv-4')), refusedWith(RefusalReason.notFound), reason: 'not issued: no digest');
    await expectLater(phone.find(const QrQuery('forged')), refusedWith(RefusalReason.notFound));
    final names = await phone.offline.lookup(phone.session, const NameQuery('neema'));
    expect(names.single.invitationId, 'inv-2');
  });

  test('offline admit (Single) queues an immutable entry, then the card is refused as fully used', () async {
    final card = await phone.admit('inv-1', 1, entryId: 'entry-1');
    expect((card.entriesUsed, card.entriesLeft), (1, 0));
    expect(phone.sync.pendingCount, 1);

    final again = await phone.find(const QrQuery('qr-inv-1'));
    expect(again.refusal, RefusalReason.fullyUsed);
    await expectLater(phone.admit('inv-1', 1), refusedWith(RefusalReason.fullyUsed));
    await expectLater(phone.admit('inv-3', 1), refusedWith(RefusalReason.cancelled));

    await phone.sync.syncNow();
    final upload = api.uploads.single;
    expect(upload['deviceId'], 'dev-a');
    expect(upload['pending'], 0);
    expect(upload['entries'], [
      {'id': 'entry-1', 'invitationId': 'inv-1', 'admittedCount': 1, 'method': 'qr', 'occurredAt': '2026-12-12T15:00:00.000Z'},
    ]);
    expect(
      [for (final a in upload['attempts'] as List) (a['outcome'], a['invitationId'])],
      [('fully_used', 'inv-1'), ('fully_used', 'inv-1'), ('cancelled', 'inv-3')],
    );
    expect(api.cards['inv-1']!['entriesUsed'], 1);
    expect(phone.sync.pendingCount, 0);
  });

  test('offline admit (Double): 1 + 1, then too many / fully used', () async {
    await expectLater(phone.admit('inv-2', 3), refusedWith(RefusalReason.tooMany));
    expect((await phone.admit('inv-2', 1)).entriesLeft, 1);
    await expectLater(phone.admit('inv-2', 2), refusedWith(RefusalReason.tooMany));
    expect((await phone.admit('inv-2', 1)).entriesLeft, 0);
    await expectLater(phone.admit('inv-2', 1), refusedWith(RefusalReason.fullyUsed));
    expect(phone.sync.pendingCount, 2);
  });

  test('CHK-5 offline: 3 wrong card numbers in a row lock for 5 minutes, reported as a locked attempt', () async {
    await expectLater(phone.find(const CardNumberQuery('111-1111')), refusedWith(RefusalReason.notFound));
    await expectLater(phone.find(const CardNumberQuery('111-1112')), refusedWith(RefusalReason.notFound));
    await expectLater(
      phone.find(const CardNumberQuery('111-1113')),
      throwsA(
        isA<DoorRefusedException>()
            .having((e) => e.reason, 'reason', RefusalReason.locked)
            .having((e) => e.lockedUntil, 'lockedUntil', now.add(const Duration(minutes: 5))),
      ),
    );
    await expectLater(phone.find(const CardNumberQuery('007-1234')), refusedWith(RefusalReason.locked));
    expect((await phone.find(const QrQuery('qr-inv-1'))).invitationId, 'inv-1', reason: 'QR still works');

    now = now.add(const Duration(minutes: 5, seconds: 1));
    expect((await phone.find(const CardNumberQuery('007-1234'))).invitationId, 'inv-1');

    // A right number resets the count.
    await expectLater(phone.find(const CardNumberQuery('111-1111')), refusedWith(RefusalReason.notFound));
    await phone.find(const CardNumberQuery('0071234'));
    await expectLater(phone.find(const CardNumberQuery('111-1111')), refusedWith(RefusalReason.notFound));
    await expectLater(phone.find(const CardNumberQuery('111-1111')), refusedWith(RefusalReason.notFound));

    await phone.sync.syncNow();
    final attempts = (api.uploads.single['attempts'] as List).cast<Map<String, dynamic>>();
    expect(
      [for (final a in attempts) (a['outcome'], a['query'], a['method'])],
      [
        ('not_found', '111-1111', 'card_number'),
        ('not_found', '111-1112', 'card_number'),
        ('locked', '111-1113', 'card_number'),
        ('not_found', '111-1111', 'card_number'),
        ('not_found', '111-1111', 'card_number'),
        ('not_found', '111-1111', 'card_number'),
      ],
    );
    expect(api.syncedAttempts, hasLength(6));
    expect(await phone.find(const CardNumberQuery('007-1234')), isNotNull, reason: '2 wrong after a right one: not locked');
  });

  test('uploads retry with backoff and resending the same IDs is idempotent', () async {
    await phone.admit('inv-2', 1, entryId: 'entry-1');
    api.offline = true;
    expect(await phone.sync.syncNow(), isFalse);
    expect(phone.sync.online, isFalse);
    expect(phone.sync.pendingCount, 1);
    expect(
      [for (final n in [1, 2, 3, 4, 5]) phone.sync.backoffFor(n).inSeconds],
      [5, 10, 20, 40, 60],
    );
    expect(phone.sync.backoffFor(0), const Duration(seconds: 30));

    // The network returns but the first response is lost after the server merged the entry.
    api.offline = false;
    api.loseUploadResponses = 1;
    expect(await phone.sync.syncNow(), isFalse);
    expect(api.syncedEntries.keys, ['entry-1']);
    expect(phone.sync.pendingCount, 1, reason: 'kept until the server confirms');

    expect(await phone.sync.syncNow(), isTrue);
    expect(api.uploads, hasLength(2), reason: 'the offline try never reached the server');
    expect([for (final u in api.uploads) (u['entries'] as List).single['id']], ['entry-1', 'entry-1']);
    expect(api.cards['inv-2']!['entriesUsed'], 1, reason: 'counted once');
    expect(phone.sync.pendingCount, 0);
    expect(phone.sync.online, isTrue);
    final card = await phone.find(const CardNumberQuery('008-5555'));
    expect((card.entriesUsed, card.entriesLeft), (1, 1), reason: 'server count, no double counting');
  });

  test('two offline phones admitting the same Double card keep both entries; the card is over-used after sync', () async {
    final other = Phone(api, 'dev-b', () => now);
    addTearDown(other.sync.dispose);
    await other.start();

    expect((await phone.admit('inv-2', 2)).entriesLeft, 0);
    expect((await other.admit('inv-2', 2)).entriesLeft, 0);

    await phone.sync.syncNow();
    expect((await phone.find(const QrQuery('qr-inv-2'))).overUsed, isFalse);
    await other.sync.syncNow();
    expect(api.syncedEntries, hasLength(2), reason: 'both entries are real people and both are kept');
    expect(api.cards['inv-2']!['entriesUsed'], 4);
    expect((await other.find(const QrQuery('qr-inv-2'))).overUsed, isTrue);

    await phone.sync.syncNow();
    final seen = await phone.find(const QrQuery('qr-inv-2'));
    expect((seen.overUsed, seen.entriesUsed, seen.refusal), (true, 4, RefusalReason.fullyUsed));
  });

  test('entries the server rejects (unknown card) are dropped locally', () async {
    await phone.admit('inv-1', 1);
    api.cards.remove('inv-1');
    expect(await phone.sync.syncNow(), isTrue);
    expect(phone.sync.pendingCount, 0);
    expect(api.syncedEntries, isEmpty);
  });

  test('a known-offline phone probes again when connectivity returns', () async {
    final net = FakeConnectivity(up: false);
    final p = Phone(api, 'dev-c', () => now, connectivity: net);
    addTearDown(p.sync.dispose);
    await p.start();
    expect(p.sync.online, isFalse);
    expect(api.syncDownloads.where((d) => d['deviceId'] == 'dev-c'), isEmpty);

    net.set(true);
    await Future<void>.delayed(Duration.zero);
    await p.sync.syncNow();
    expect(api.syncDownloads.where((d) => d['deviceId'] == 'dev-c'), isNotEmpty);
    expect(p.sync.online, isTrue);

    net.set(false);
    await Future<void>.delayed(Duration.zero);
    expect(p.sync.online, isFalse);
  });

  group('wipe', () {
    test('after the event window: pending items upload, then the cache and key are deleted', () async {
      await phone.admit('inv-1', 1, entryId: 'late-entry');
      now = api.wipeAfter.add(const Duration(minutes: 1));
      expect(await phone.sync.syncNow(), isFalse);
      expect(api.syncedEntries.keys, ['late-entry']);
      expect(phone.keys.key, isNull);
      expect(phone.keys.deletes, 1);
      expect(phone.sync.expired, isTrue);
      expect(phone.sync.cacheReady, isFalse);
      expect(phone.offline.isAvailable(phone.session), isFalse);
      expect(await phone.sync.cachedSession(), isNull);
    });

    test('a stale cache is wiped when it is opened (e.g. at app start)', () async {
      now = api.wipeAfter.add(const Duration(hours: 1));
      final restarted = DoorSyncRepository(door: phone.door, store: phone.store, clock: () => now, autoSchedule: false);
      addTearDown(restarted.dispose);
      expect(await restarted.cachedSession(), isNull);
      expect(phone.keys.deletes, 1);
    });

    test('the cached event can be reopened without network while it is valid', () async {
      final restarted = DoorSyncRepository(door: phone.door, store: phone.store, clock: () => now, autoSchedule: false);
      addTearDown(restarted.dispose);
      final cached = (await restarted.cachedSession())!;
      expect((cached.event.title, cached.deviceId, cached.deviceName), ('Harusi ya Asha', 'dev-a', 'Gate dev-a'));
    });

    test('a revoked device (403) wipes the cache and reports access denied', () async {
      await phone.admit('inv-1', 1);
      api.revoked = true;
      expect(await phone.sync.syncNow(), isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(phone.denied, [AppFailure.doorAccessDenied]);
      expect(phone.keys.key, isNull);
      expect(phone.sync.pendingCount, 0);
      expect(phone.sync.cacheReady, isFalse);
    });

    test('sign-out uploads what is waiting, then wipes', () async {
      await phone.admit('inv-1', 1, entryId: 'e-signout');
      await phone.sync.signOut();
      expect(api.syncedEntries.keys, ['e-signout']);
      expect(phone.keys.key, isNull);
      expect(phone.sync.session, isNull);
    });

    test('sign-out without network still wipes', () async {
      await phone.admit('inv-1', 1);
      api.offline = true;
      await phone.sync.signOut();
      expect(api.syncedEntries, isEmpty);
      expect(phone.keys.key, isNull);
      expect(phone.opener.deletes, greaterThanOrEqualTo(2));
    });
  });
}
