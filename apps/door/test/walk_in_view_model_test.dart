import 'package:dcard_door/data/repositories/door_repository.dart';
import 'package:dcard_door/data/repositories/door_sync_repository.dart';
import 'package:dcard_door/data/repositories/offline_check_in_repository.dart';
import 'package:dcard_door/data/services/door_device_store.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:dcard_door/domain/models/check_in.dart';
import 'package:dcard_door/domain/models/door_event.dart';
import 'package:dcard_door/ui/features/walk_in/view_models/walk_in_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fakes.dart';

const linked = CheckInCard(
  invitationId: 'inv-1',
  guestName: 'Asha Juma',
  cardType: CardType.single,
  status: CardStatus.issued,
  totalEntries: 1,
  entriesUsed: 1,
  entriesLeft: 0,
);

void main() {
  late FakeDoorApi api;
  late DoorRepository door;
  late DoorSyncRepository sync;
  late OfflineCheckInRepository offline;
  late DoorSession session;
  late DateTime now;
  final denied = <AppFailure>[];
  var ids = 0;

  WalkInViewModel newVm({CheckInCard? card, Duration poll = const Duration(minutes: 1), bool withOffline = true}) =>
      WalkInViewModel(
        door: door,
        session: session,
        onAccessDenied: (f) async => denied.add(f),
        offline: withOffline ? offline : null,
        sync: withOffline ? sync : null,
        linkedCard: card,
        pollInterval: poll,
        newId: () => '00000000-0000-4000-8000-00000000000${ids++}',
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime.utc(2026, 12, 12, 15);
    ids = 0;
    denied.clear();
    api = FakeDoorApi(clock: () => now, cards: [cardJson(id: 'inv-1', used: 1)]);
    door = DoorRepository(api, DoorDeviceStore(await SharedPreferences.getInstance()));
    final store = memoryCacheStore();
    sync = DoorSyncRepository(door: door, store: store, clock: () => now, autoSchedule: false);
    offline = OfflineCheckInRepository(store: store, sync: sync, clock: () => now);
    session = await door.openEvent((await door.listEvents()).single);
    await sync.start(session);
  });

  tearDown(() => sync.dispose());

  test('online: the request waits for the first answer and shows who approved', () async {
    final vm = newVm(card: linked);
    addTearDown(vm.dispose);
    vm
      ..setDescription(' Bride\'s uncle ')
      ..setCount(2);
    await vm.submit();
    expect(vm.step, WalkInStep.waiting);
    final sent = api.walkInRequests.single;
    expect(sent, {
      'id': '00000000-0000-4000-8000-000000000000',
      'deviceId': session.deviceId,
      'description': "Bride's uncle",
      'invitationId': 'inv-1',
      'admittedCount': 2,
    });

    await vm.refresh();
    expect(vm.step, WalkInStep.waiting);
    api.answerWalkIn(sent['id'] as String, approve: true, by: 'neema@example.com');
    api.answerWalkIn(sent['id'] as String, approve: false, by: 'late@example.com');
    await vm.refresh();
    expect(vm.step, WalkInStep.approved);
    expect(vm.request!.decidedBy, 'neema@example.com');
    expect(api.walkInPolls, hasLength(2));
  });

  test('online: a refusal shows who refused; the screen polls by itself', () async {
    final vm = newVm(poll: const Duration(milliseconds: 10));
    addTearDown(vm.dispose);
    vm.setDescription('Two friends of the groom');
    await vm.submit();
    expect(api.walkInRequests.single.containsKey('invitationId'), isFalse);
    api.answerWalkIn(vm.request!.id, approve: false);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(vm.step, WalkInStep.refused);
    expect(vm.request!.decidedBy, 'host@example.com');
    final polls = api.walkInPolls.length;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(api.walkInPolls, hasLength(polls), reason: 'polling stops after the decision');
  });

  test('the description is required (2–200 characters)', () async {
    final vm = newVm();
    addTearDown(vm.dispose);
    vm.setDescription(' a ');
    await vm.submit();
    expect(vm.showErrors, isTrue);
    expect(vm.descriptionValid, isFalse);
    expect(api.walkInRequests, isEmpty);
    vm.setDescription('x' * 201);
    expect(vm.descriptionValid, isFalse);
  });

  test('a retried request after a network error reuses its ID', () async {
    final vm = newVm(withOffline: false);
    addTearDown(vm.dispose);
    vm.setDescription('Uncle Juma');
    api.offlineOnce = true;
    await vm.submit();
    expect(vm.failure, AppFailure.network);
    expect(vm.offlineMode, isFalse, reason: 'no offline cache: cannot admit offline');
    await vm.submit();
    expect(vm.step, WalkInStep.waiting);
    expect(api.walkInRequests.single['id'], '00000000-0000-4000-8000-000000000000');
  });

  test('offline: admitting needs a reason; the walk-in uploads with sync as admitted offline', () async {
    final vm = newVm(card: linked);
    addTearDown(vm.dispose);
    api.offline = true;
    vm.setDescription('Uncle Juma');
    await vm.submit();
    expect(vm.failure, AppFailure.network);
    expect(vm.networkDown, isTrue);
    expect(vm.offlineMode, isTrue, reason: 'the request failed: offer offline admission');

    await vm.submit();
    expect(vm.reasonValid, isFalse);
    expect(vm.step, WalkInStep.form, reason: 'no reason, no admission');

    vm.setReason('host approved by phone call');
    await vm.submit();
    expect(vm.step, WalkInStep.admittedOffline);
    expect(sync.pendingCount, 1);

    api.offline = false;
    await sync.syncNow();
    final uploaded = api.syncedWalkIns.values.single;
    expect(uploaded['description'], 'Uncle Juma');
    expect(uploaded['offlineReason'], 'host approved by phone call');
    expect(uploaded['invitationId'], 'inv-1');
    expect(uploaded['admittedCount'], 1);
    expect(sync.pendingCount, 0);
  });

  test('a phone known to be offline starts in offline mode', () async {
    sync.markOffline();
    final vm = newVm();
    addTearDown(vm.dispose);
    expect(vm.offlineMode, isTrue);
    vm.setOfflineMode(false);
    expect(vm.offlineMode, isFalse);
  });

  test('a revoked device while waiting asks the app to sign out', () async {
    final vm = newVm();
    addTearDown(vm.dispose);
    vm.setDescription('Uncle Juma');
    await vm.submit();
    api.revoked = true;
    await vm.refresh();
    expect(denied, [AppFailure.doorAccessDenied]);
  });
}
