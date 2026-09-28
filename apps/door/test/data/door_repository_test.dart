import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:dcard_door/domain/models/check_in.dart';
import 'package:dcard_door/domain/models/door_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fakes.dart';

void main() {
  late FakeDoorApi api;
  late DoorRepository door;
  late DoorDeviceStore store;
  var ids = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ids = 0;
    api = FakeDoorApi(
      cards: [
        cardJson(),
        cardJson(
          id: 'inv-2',
          guestName: 'Baraka',
          partnerName: 'Neema',
          cardNumber: '008-5555',
          cardType: 'double',
          used: 2,
          table: null,
          entries: [
            entryJson(id: 'b', occurredAt: '2026-12-12T16:10:00.000Z'),
            entryJson(id: 'a', occurredAt: '2026-12-12T15:05:00.000Z', deviceName: null, staffName: null),
          ],
        ),
      ],
    );
    store = DoorDeviceStore(
      await SharedPreferences.getInstance(),
      newId: () => '00000000-0000-4000-8000-00000000000${ids++}',
    );
    door = DoorRepository(api, store, newEntryId: () => 'entry-1');
  });

  Future<DoorSession> open() async => door.openEvent((await door.listEvents()).single);

  test('maps door events', () async {
    api.events = [eventJson(), eventJson(id: 'e2', title: 'Send-off', role: 'host')];
    final events = await door.listEvents();
    expect(events.map((e) => e.title), ['Harusi ya Asha', 'Send-off']);
    expect(events.first.role, DoorRole.doorStaff);
    expect(events.last.role, DoorRole.host);
    expect(events.first.startsAt, DateTime.utc(2026, 12, 12, 12));
    expect(events.first.endsAt, isNull);
    expect(events.first.venueName, 'Diamond Jubilee');
  });

  test('registers one stable device ID per event, without null fields', () async {
    final first = await open();
    final again = await open();
    expect(first.deviceId, again.deviceId);
    expect(api.registrations, hasLength(2));
    expect(api.registrations.first, {'eventId': 'e1', 'deviceId': first.deviceId});

    await door.setDeviceName('  Gate 2 ');
    api.events = [eventJson(id: 'e2')];
    final other = await open();
    expect(other.deviceId, isNot(first.deviceId));
    expect(other.deviceName, 'Gate 2');
    expect(api.registrations.last, {'eventId': 'e2', 'deviceId': other.deviceId, 'name': 'Gate 2'});
  });

  test('a revoked device or lost access is doorAccessDenied', () async {
    api.revoked = true;
    await expectLater(
      open(),
      throwsA(isA<AppException>().having((e) => e.failure, 'failure', AppFailure.doorAccessDenied)),
    );
  });

  test('network errors are AppFailure.network', () async {
    api.offlineOnce = true;
    await expectLater(
      door.listEvents(),
      throwsA(isA<AppException>().having((e) => e.failure, 'failure', AppFailure.network)),
    );
  });

  test('lookup sends exactly one key and maps cards', () async {
    final s = await open();
    final byName = await door.lookup(s, const NameQuery(' neema '));
    expect(api.lookups.last, {'deviceId': s.deviceId, 'name': 'neema'});
    final card = byName.single;
    expect(card.guestName, 'Baraka');
    expect(card.partnerName, 'Neema');
    expect(card.cardType, CardType.double);
    expect(card.status, CardStatus.issued);
    expect((card.totalEntries, card.entriesUsed, card.entriesLeft), (2, 2, 0));
    expect(card.table, isNull);
    expect(card.refusal, RefusalReason.fullyUsed);
    expect(card.entries.map((e) => e.occurredAt.hour), [15, 16], reason: 'entries sorted oldest first');
    expect(card.entries.first.deviceName, isNull);
    expect(card.entries.last.method, CheckInMethod.qr);

    await door.lookup(s, const CardNumberQuery('007-1234'));
    expect(api.lookups.last, {'deviceId': s.deviceId, 'cardNumber': '007-1234'});
  });

  test('QR values are sent raw; a scanned card URL sends its last path segment', () async {
    final s = await open();
    final cards = await door.lookup(s, const QrQuery('  qr-inv-1\n'));
    expect(api.lookups.last, {'deviceId': s.deviceId, 'qrToken': 'qr-inv-1'});
    expect(cards.single.invitationId, 'inv-1');
    await door.lookup(s, const QrQuery('https://dcard.co.tz/c/qr-inv-1'));
    expect(api.lookups.last['qrToken'], 'qr-inv-1');
    expect(qrTokenFrom('abc/def'), 'abc/def');
  });

  test('404 and 423 become refusals; 423 carries lockedUntil', () async {
    final s = await open();
    await expectLater(
      door.lookup(s, const QrQuery('nope')),
      throwsA(isA<DoorRefusedException>().having((e) => e.reason, 'reason', RefusalReason.notFound)),
    );
    for (var i = 0; i < 2; i++) {
      await expectLater(door.lookup(s, const CardNumberQuery('999-9999')), throwsA(isA<DoorRefusedException>()));
    }
    await expectLater(
      door.lookup(s, const CardNumberQuery('999-9999')),
      throwsA(
        isA<DoorRefusedException>()
            .having((e) => e.reason, 'reason', RefusalReason.locked)
            .having((e) => e.lockedUntil, 'lockedUntil', isNotNull),
      ),
    );
  });

  test('admit sends the entry and returns the updated card; 409 maps with the card', () async {
    final s = await open();
    final card = await door.admit(s, entryId: door.newEntryId(), invitationId: 'inv-1', count: 1, method: CheckInMethod.cardNumber);
    expect(api.admits.single, {
      'id': 'entry-1',
      'deviceId': s.deviceId,
      'invitationId': 'inv-1',
      'admittedCount': 1,
      'method': 'card_number',
    });
    expect(card.entriesLeft, 0);
    expect(card.entries.single.method, CheckInMethod.cardNumber);

    await expectLater(
      door.admit(s, entryId: 'entry-2', invitationId: 'inv-1', count: 1, method: CheckInMethod.qr),
      throwsA(
        isA<DoorRefusedException>()
            .having((e) => e.reason, 'reason', RefusalReason.fullyUsed)
            .having((e) => e.card?.entries.length, 'entries', 1),
      ),
    );
  });

  test('refusal codes map to reasons', () async {
    final s = await open();
    api.cards['inv-3'] = cardJson(id: 'inv-3', status: 'cancelled');
    api.cards['inv-4'] = cardJson(id: 'inv-4', status: 'pending', cardNumber: null);
    api.cards['inv-5'] = cardJson(id: 'inv-5', cardType: 'double', used: 1);
    Future<RefusalReason?> reasonFor(String id, int count) async {
      try {
        await door.admit(s, entryId: 'x-$id', invitationId: id, count: count, method: CheckInMethod.name);
        return null;
      } on DoorRefusedException catch (e) {
        return e.reason;
      }
    }

    expect(await reasonFor('inv-3', 1), RefusalReason.cancelled);
    expect(await reasonFor('inv-4', 1), RefusalReason.notIssued);
    expect(await reasonFor('inv-5', 2), RefusalReason.tooMany);
    expect(await reasonFor('missing', 1), RefusalReason.notFound);
  });
}
