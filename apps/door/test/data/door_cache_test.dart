import 'package:dcard_door/data/models/offline_models.dart';
import 'package:dcard_door/data/services/door_cache.dart';
import 'package:dcard_door/domain/models/check_in.dart';
import 'package:dcard_door/domain/models/door_event.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fakes.dart';

CachedCard card(
  String id, {
  String name = 'Asha Juma',
  String? partner,
  String? number,
  String? digest,
  CardType type = CardType.single,
  CardStatus status = CardStatus.issued,
  int used = 0,
}) => CachedCard(
  invitationId: id,
  guestName: name,
  partnerName: partner,
  cardNumber: number,
  qrTokenDigest: digest,
  cardType: type,
  status: status,
  totalEntries: type == CardType.double ? 2 : 1,
  entriesUsed: used,
);

PendingEntry entry(String id, String invitationId, {int count = 1, String device = 'dev-1'}) => PendingEntry(
  id: id,
  deviceId: device,
  invitationId: invitationId,
  admittedCount: count,
  method: CheckInMethod.qr,
  occurredAt: DateTime.utc(2026, 12, 12, 15),
);

DoorSession session(String eventId, {String deviceId = 'dev-1'}) => DoorSession(
  event: DoorEvent(id: eventId, title: 'Harusi', startsAt: DateTime.utc(2026, 12, 12, 12), role: DoorRole.doorStaff),
  deviceId: deviceId,
  deviceName: 'Gate 1',
);

void main() {
  late MemoryKeyStore keys;
  late MemoryDbOpener opener;
  late DoorCache cache;

  setUp(() async {
    keys = MemoryKeyStore();
    opener = MemoryDbOpener();
    cache = await memoryCacheStore(keys: keys, opener: opener).open();
  });

  test('looks cards up by QR digest, card number digits and name', () async {
    await cache.replaceCards([
      card('a', number: '007-1234', digest: 'ABCDEF'),
      card('b', name: 'Baraka', partner: 'Neema', number: '008-5555', type: CardType.double),
    ]);
    expect((await cache.cardByDigest('abcdef'))!.invitationId, 'a');
    expect(await cache.cardByDigest('0000'), isNull);
    expect((await cache.cardByNumber('0071234'))!.invitationId, 'a');
    expect((await cache.cardByNumber(' 007-1234 '))!.invitationId, 'a');
    expect(await cache.cardByNumber('111-1111'), isNull);
    expect((await cache.searchName('NEEMA')).single.invitationId, 'b');
    expect((await cache.searchName('a')).map((c) => c.invitationId), ['a', 'b']);
    expect(await cache.searchName('%'), hasLength(2), reason: 'wildcards are not special');
  });

  test('local entries count on the card until the server count includes them', () async {
    await cache.replaceCards([card('b', type: CardType.double)]);
    await cache.addEntry(entry('e1', 'b'));
    await cache.addEntry(entry('e1', 'b'));
    var b = (await cache.cardById('b'))!;
    expect((b.entriesUsed, b.localUsed), (0, 1), reason: 'the same entry ID counts once');
    expect(b.toCheckInCard().entriesLeft, 1);
    expect(await cache.pendingCount(), 1);

    // Uploaded: the pending row goes, the local count stays until the next download.
    await cache.removeSent(await cache.pendingFor('dev-1'));
    expect(await cache.pendingCount(), 0);
    expect((await cache.cardById('b'))!.localUsed, 1);

    await cache.upsertCards([card('b', type: CardType.double, used: 1)]);
    b = (await cache.cardById('b'))!;
    expect((b.entriesUsed, b.localUsed), (1, 0));

    // A full snapshot keeps entries that have not uploaded yet.
    await cache.addEntry(entry('e2', 'b'));
    await cache.replaceCards([card('b', type: CardType.double, used: 1)]);
    b = (await cache.cardById('b'))!;
    expect((b.entriesUsed, b.localUsed), (1, 1));
    expect(b.toCheckInCard().refusal, RefusalReason.fullyUsed);
  });

  test('over-use shows when more entered than allowed', () async {
    await cache.replaceCards([card('a', used: 1)]);
    await cache.markOverUsed(['a']);
    final a = (await cache.cardById('a'))!.toCheckInCard();
    expect(a.overUsed, isTrue);
    expect(card('x', used: 2).toCheckInCard().overUsed, isTrue);
  });

  test('pending items are grouped by device and batched', () async {
    await cache.replaceCards([card('a'), card('b', type: CardType.double)]);
    await cache.addEntry(entry('e1', 'a'));
    await cache.addEntry(entry('e2', 'b', device: 'old-device'));
    await cache.addAttempt(
      PendingAttempt(
        id: 't1',
        deviceId: 'dev-1',
        method: CheckInMethod.cardNumber,
        query: '111-1111',
        outcome: RefusalReason.notFound,
        occurredAt: DateTime.utc(2026, 12, 12, 15),
      ),
    );
    await cache.addWalkIn(
      PendingWalkIn(
        id: 'w1',
        deviceId: 'dev-1',
        description: 'Uncle',
        admittedCount: 1,
        offlineReason: 'host approved by phone call',
        occurredAt: DateTime.utc(2026, 12, 12, 15),
      ),
    );
    expect(await cache.pendingDevices(), unorderedEquals(['dev-1', 'old-device']));
    expect(await cache.pendingCount(), 3);
    expect(await cache.pendingCount(deviceId: 'dev-1'), 2);
    final batch = await cache.pendingFor('dev-1');
    expect(batch.entries.single.toJson(), {
      'id': 'e1',
      'invitationId': 'a',
      'admittedCount': 1,
      'method': 'qr',
      'occurredAt': '2026-12-12T15:00:00.000Z',
    });
    expect(batch.attempts.single.toJson(), {
      'id': 't1',
      'method': 'card_number',
      'query': '111-1111',
      'outcome': 'not_found',
      'occurredAt': '2026-12-12T15:00:00.000Z',
    });
    expect(batch.walkIns.single.toJson()['offlineReason'], 'host approved by phone call');
    expect(batch.walkIns.single.toJson().containsKey('invitationId'), isFalse);

    await cache.dropDevice('old-device');
    expect(await cache.pendingDevices(), ['dev-1']);
  });

  test('state belongs to one event; another event clears cards and state but not pending items', () async {
    await cache.bindSession(session('e1'));
    await cache.replaceCards([card('a')]);
    await cache.addEntry(entry('e1', 'a'));
    await cache.saveSync(
      cursor: 'c1',
      wipeAfter: DateTime.utc(2026, 12, 14),
      at: DateTime.utc(2026, 12, 12, 15),
      approvers: const [Approver(userId: 'u1', name: 'host@example.com')],
    );
    var state = (await cache.readState())!;
    expect(state.event.id, 'e1');
    expect(state.session.deviceName, 'Gate 1');
    expect(state.cursor, 'c1');
    expect(state.approvers.single.name, 'host@example.com');

    await cache.bindSession(session('e1'));
    expect((await cache.readState())!.cursor, 'c1', reason: 'same event keeps its cursor');

    await cache.bindSession(session('e2', deviceId: 'dev-2'));
    state = (await cache.readState())!;
    expect((state.event.id, state.deviceId, state.cursor), ('e2', 'dev-2', null));
    expect(await cache.cardCount(), 0);
    expect(await cache.pendingCount(), 1, reason: 'e1 entries still upload with their device ID');
  });

  test('lockout state persists', () async {
    expect(await cache.readLockout(), (0, null));
    await cache.writeLockout(2, null);
    expect(await cache.readLockout(), (2, null));
    await cache.writeLockout(0, DateTime.utc(2026, 12, 12, 15, 5));
    expect(await cache.readLockout(), (0, DateTime.utc(2026, 12, 12, 15, 5)));
  });

  test('digitsOf strips formatting', () {
    expect(digitsOf('007-1234'), '0071234');
  });
}
