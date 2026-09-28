import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/repositories/door_sync_repository.dart';
import 'package:dcard_door/data/repositories/offline_check_in_repository.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:dcard_door/domain/models/check_in.dart';
import 'package:dcard_door/domain/models/door_event.dart';
import 'package:dcard_door/ui/features/check_in/view_models/check_in_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fakes.dart';

void main() {
  late FakeDoorApi api;
  late DoorRepository door;
  late DoorSyncRepository sync;
  late OfflineCheckInRepository offline;
  late DoorSession session;
  late CheckInViewModel vm;
  late DateTime now;

  CheckInViewModel newVm() => CheckInViewModel(
    door: door,
    session: session,
    clock: () => now,
    onAccessDenied: (_) async {},
    offline: offline,
    sync: sync,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime.utc(2026, 12, 12, 15);
    api = FakeDoorApi(
      clock: () => now,
      cards: [
        cardJson(id: 'inv-1', cardNumber: '007-1234'),
        cardJson(id: 'inv-2', guestName: 'Baraka', partnerName: 'Neema', cardNumber: '008-5555', cardType: 'double'),
        cardJson(id: 'inv-3', guestName: 'Rehema', cardNumber: '009-1111', status: 'cancelled'),
      ],
    );
    door = DoorRepository(api, DoorDeviceStore(await SharedPreferences.getInstance()));
    final store = memoryCacheStore();
    sync = DoorSyncRepository(door: door, store: store, clock: () => now, autoSchedule: false);
    offline = OfflineCheckInRepository(store: store, sync: sync, clock: () => now);
    session = await door.openEvent((await door.listEvents()).single);
    await sync.start(session);
    vm = newVm();
  });

  tearDown(() {
    vm.dispose();
    sync.dispose();
  });

  test('a network error decides from the cache, shows Offline, and uploads when the network is back', () async {
    api.offline = true;
    await vm.scanned(api.qrFor('inv-1'));
    final found = vm.result as CardFound;
    expect((found.card.guestName, found.offline), ('Asha Juma', true));
    expect(vm.isOffline, isTrue);
    expect(vm.failure, isNull);

    await vm.admit(1);
    final admitted = vm.result as Admitted;
    expect((admitted.offline, admitted.card.entriesLeft), (true, 0));
    expect(vm.pendingCount, 1);
    vm.next();

    // Known offline: no online call is tried.
    final lookups = api.lookups.length;
    await vm.scanned(api.qrFor('inv-1'));
    expect(api.lookups, hasLength(lookups));
    expect((vm.result as CardFound).card.refusal, RefusalReason.fullyUsed);
    vm.next();

    api.offline = false;
    await vm.syncNow();
    expect(vm.isOffline, isFalse);
    expect(vm.pendingCount, 0);
    expect(vm.lastSyncAt, now);
    expect(api.syncedEntries.values.single['deviceId'], isNull, reason: 'device ID travels on the batch');
    expect(api.uploads.last['deviceId'], session.deviceId);

    await vm.scanned(api.qrFor('inv-2'));
    expect((vm.result as CardFound).offline, isFalse);
    expect(api.lookups.length, lookups + 1);
  });

  test('a lost admit response is kept offline under the same entry ID and counted once after sync', () async {
    await vm.scanned(api.qrFor('inv-2'));
    api.loseNextAdmitResponse = true;
    await vm.admit(1);
    final admitted = vm.result as Admitted;
    expect(admitted.offline, isTrue);
    final entryId = api.admits.single['id'];

    await sync.syncNow();
    expect((api.uploads.single['entries'] as List).single['id'], entryId);
    expect(api.syncedEntries, isEmpty, reason: 'the server already had it: a duplicate');
    expect(api.cards['inv-2']!['entriesUsed'], 1);
  });

  test('online results refresh the cache so going offline cannot re-admit', () async {
    await vm.scanned(api.qrFor('inv-1'));
    await vm.admit(1);
    expect((vm.result as Admitted).offline, isFalse);
    vm.next();

    api.offline = true;
    await vm.lookupCardNumber('007-1234');
    final found = vm.result as CardFound;
    expect((found.offline, found.card.refusal), (true, RefusalReason.fullyUsed));
  });

  test('offline refusals and not found are marked offline', () async {
    sync.markOffline();
    await vm.lookupCardNumber('009-1111');
    expect((vm.result as CardFound).card.refusal, RefusalReason.cancelled);
    vm.next();
    await vm.scanned('forged');
    final refused = vm.result as Refused;
    expect((refused.reason, refused.offline), (RefusalReason.notFound, true));
    vm.next();
    await vm.searchName('neema');
    expect(vm.nameMatchesOffline, isTrue);
    vm.selectMatch(vm.nameMatches!.single);
    expect((vm.result as CardFound).offline, isTrue);
  });

  test('offline lockout: 3 wrong card numbers lock the keypad', () async {
    sync.markOffline();
    for (var i = 0; i < 2; i++) {
      await vm.lookupCardNumber('111-1111');
      expect((vm.result as Refused).reason, RefusalReason.notFound);
      vm.next();
    }
    await vm.lookupCardNumber('111-1111');
    expect(vm.isLocked, isTrue);
    expect(vm.lockRemaining, const Duration(minutes: 5));
    expect(api.lookups, isEmpty);
  });

  test('without a downloaded cache a network error is shown as before', () async {
    sync.stop();
    api.offline = true;
    final fresh = newVm();
    addTearDown(fresh.dispose);
    await fresh.scanned(api.qrFor('inv-1'));
    expect(fresh.failure, AppFailure.network);
    expect(fresh.result, isNull);
    expect(fresh.offlineReady, isFalse);
  });
}
