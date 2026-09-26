import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:dcard_door/domain/models/check_in.dart';
import 'package:dcard_door/ui/features/check_in/view_models/check_in_view_model.dart';
import 'package:dcard_door/ui/features/events/view_models/event_select_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fakes.dart';

void main() {
  late FakeDoorApi api;
  late DoorRepository door;
  late CheckInViewModel vm;
  late DateTime now;
  final denied = <AppFailure>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime.utc(2026, 12, 12, 15);
    denied.clear();
    api = FakeDoorApi(
      clock: () => now,
      cards: [
        cardJson(),
        cardJson(id: 'inv-2', guestName: 'Baraka', partnerName: 'Neema', cardNumber: '008-5555', cardType: 'double'),
        cardJson(id: 'inv-3', guestName: 'Baraka Mushi', cardNumber: '009-1111', status: 'cancelled'),
      ],
    );
    door = DoorRepository(api, DoorDeviceStore(await SharedPreferences.getInstance()));
    final events = EventSelectViewModel(door);
    await events.load();
    final session = (await events.open(events.events.single))!;
    vm = CheckInViewModel(door: door, session: session, clock: () => now, onAccessDenied: (f) async => denied.add(f));
  });

  tearDown(() => vm.dispose());

  test('QR lookup shows the card; Admit 1 records the entry with a device UUID', () async {
    await vm.scanned(api.qrFor('inv-1'));
    final found = vm.result as CardFound;
    expect(found.card.guestName, 'Asha Juma');
    expect(found.method, CheckInMethod.qr);

    await vm.scanned(api.qrFor('inv-2'));
    expect(api.lookups, hasLength(1), reason: 'scans are ignored while a result is on screen');

    await vm.admit(1);
    final admitted = vm.result as Admitted;
    expect(admitted.count, 1);
    expect(admitted.card.entriesLeft, 0);
    final sent = api.admits.single;
    expect(sent['deviceId'], vm.session.deviceId);
    expect(sent['id'], matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(sent['method'], 'qr');

    vm.next();
    expect(vm.result, isNull);
  });

  test('double card: Admit 2 empties it, then it is refused as fully used with the entry times', () async {
    await vm.lookupCardNumber('008-5555');
    await vm.admit(2);
    expect((vm.result as Admitted).card.entriesLeft, 0);
    vm.next();

    await vm.lookupCardNumber('008-5555');
    final found = vm.result as CardFound;
    expect(found.card.refusal, RefusalReason.fullyUsed);
    expect(found.card.entries.single.admittedCount, 2);
    await vm.admit(1);
    expect(api.admits, hasLength(1), reason: 'refused cards cannot be admitted from the app');
  });

  test('Admit 2 is not sent when only one entry is left', () async {
    await vm.lookupCardNumber('007-1234');
    await vm.admit(2);
    expect(api.admits, isEmpty);
    expect(vm.result, isA<CardFound>());
  });

  test('a server refusal on admit shows the refusal with the card', () async {
    await vm.scanned(api.qrFor('inv-2'));
    // Another gate admits both in the meantime.
    api.cards['inv-2']!
      ..['entriesUsed'] = 2
      ..['entriesLeft'] = 0
      ..['entries'] = [entryJson(count: 2, deviceName: 'Gate 2')];
    await vm.admit(1);
    final refused = vm.result as Refused;
    expect(refused.reason, RefusalReason.fullyUsed);
    expect(refused.card!.entries.single.deviceName, 'Gate 2');
  });

  test('unknown card is Card not found; a cancelled card is refused on lookup', () async {
    await vm.scanned('unknown-token');
    expect((vm.result as Refused).reason, RefusalReason.notFound);
    vm.next();
    await vm.lookupCardNumber('009-1111');
    expect((vm.result as CardFound).card.refusal, RefusalReason.cancelled);
  });

  test('3 wrong card numbers lock card-number entry with a countdown', () async {
    for (var i = 0; i < 2; i++) {
      await vm.lookupCardNumber('111-1111');
      expect((vm.result as Refused).reason, RefusalReason.notFound);
      vm.next();
    }
    await vm.lookupCardNumber('111-1111');
    expect(vm.result, isNull);
    expect(vm.isLocked, isTrue);
    expect(vm.lockRemaining, const Duration(minutes: 5));

    await vm.lookupCardNumber('007-1234');
    expect(api.lookups, hasLength(3), reason: 'no lookup is sent while locked');

    now = now.add(const Duration(minutes: 2));
    expect(vm.lockRemaining, const Duration(minutes: 3));
    await vm.scanned(api.qrFor('inv-1'));
    expect(vm.result, isA<CardFound>(), reason: 'QR still works while card numbers are locked');
    vm.next();

    now = now.add(const Duration(minutes: 3, seconds: 1));
    expect(vm.isLocked, isFalse);
    await vm.lookupCardNumber('007-1234');
    expect(vm.result, isA<CardFound>());
  });

  test('name search lists matches, empty result and short queries', () async {
    await vm.searchName('b');
    expect(vm.nameTooShort, isTrue);
    expect(api.lookups, isEmpty);

    await vm.searchName('baraka');
    expect(vm.nameMatches!.map((c) => c.invitationId), ['inv-2', 'inv-3']);
    vm.selectMatch(vm.nameMatches!.first);
    expect((vm.result as CardFound).method, CheckInMethod.name);
    vm.next();

    await vm.searchName('zzz');
    expect(vm.nameMatches, isEmpty);
  });

  test('a lost admit response is retried with the same entry ID', () async {
    await vm.scanned(api.qrFor('inv-2'));
    api.loseNextAdmitResponse = true;
    await vm.admit(1);
    expect(vm.failure, AppFailure.network);
    expect(vm.result, isA<CardFound>());

    await vm.admit(1);
    expect(api.admits, hasLength(2));
    expect(api.admits[0]['id'], api.admits[1]['id']);
    expect((vm.result as Admitted).card.entriesLeft, 1, reason: 'counted once');
  });

  test('a revoked device asks the app to sign out', () async {
    api.revoked = true;
    await vm.scanned(api.qrFor('inv-1'));
    expect(denied, [AppFailure.doorAccessDenied]);
    expect(vm.result, isNull);
  });

  test('event select reports a revoked device instead of opening', () async {
    api.revoked = true;
    final events = EventSelectViewModel(door);
    await events.load();
    expect(await events.open(events.events.single), isNull);
    expect(events.notice, AppFailure.doorAccessDenied);
  });
}
