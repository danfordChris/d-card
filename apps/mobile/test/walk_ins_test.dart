import 'package:dcard_api/api.dart';
import 'package:dcard_mobile/data/repositories/walk_in_alerts_repository.dart';
import 'package:dcard_mobile/data/repositories/walk_ins_repository.dart';
import 'package:dcard_mobile/domain/models/app_failure.dart';
import 'package:dcard_mobile/domain/models/walk_in.dart' as domain;
import 'package:dcard_mobile/ui/features/walk_ins/view_models/walk_ins_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart' show pumpApp, signIn;
import 'fakes/fakes.dart';

FakeApi walkInApi({EventAccessEnum? access, List<WalkIn>? walkIns}) => FakeApi(events: [fakeEvent(access: access)])
  ..walkIns =
      walkIns ??
      [
        fakeWalkIn(id: 'w1', description: 'Mjomba wa bibi harusi', admittedCount: 2, guestName: 'Asha Mohamed'),
        fakeWalkIn(id: 'w2', description: 'Rafiki wa bwana harusi', offlineReason: 'Mwenyeji alikubali kwa simu'),
        fakeWalkIn(id: 'w3', description: 'Mpiga picha', status: WalkInStatus.refused, decidedBy: 'mc@example.com'),
      ];

/// A phone-sized portrait screen so every section is laid out.
void tallScreen(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

Future<void> openWalkInsFromEvent(WidgetTester tester, {String label = 'Walk-ins'}) async {
  await signIn(tester);
  await tester.tap(find.text('Harusi ya Asha'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Map<String, Object?> walkInPush({String eventId = 'e1', String walkInId = 'w9', String status = 'pending'}) => {
  'type': 'walk_in',
  'eventId': eventId,
  'walkInId': walkInId,
  'status': status,
};

void main() {
  group('WalkInsViewModel', () {
    WalkInsViewModel vmFor(FakeApi api, {bool canDecide = true, WalkInAlertsRepository? alerts}) =>
        WalkInsViewModel(eventId: 'e1', repository: WalkInsRepository(api), canDecide: canDecide, alerts: alerts);

    test('splits pending, needs-review and decided history', () async {
      final vm = vmFor(walkInApi());
      await vm.load();
      expect(vm.pending.map((w) => w.id), ['w1']);
      expect(vm.pending.single.guestName, 'Asha Mohamed');
      expect(vm.pending.single.admittedCount, 2);
      expect(vm.needsReview.map((w) => w.id), ['w2']);
      expect(vm.needsReview.single.offline, isTrue);
      expect(vm.history.map((w) => w.id), ['w3']);
      vm.dispose();
    });

    test('approve moves the request to history with who decided', () async {
      final api = walkInApi();
      final vm = vmFor(api);
      await vm.load();
      final result = await vm.decide(vm.pending.single, domain.WalkInDecision.approve);
      expect(result, isA<WalkInDecided>());
      expect(api.decisions.single, ('w1', WalkInDecisionInputDecisionEnum.approve));
      expect(vm.pending, isEmpty);
      expect(vm.history.first.status, domain.WalkInStatus.approved);
      expect(vm.history.first.decidedBy, 'host@example.com');
      vm.dispose();
    });

    test('a 409 reports who answered first and shows their decision', () async {
      final api = walkInApi()
        ..decidedElsewhere['w1'] = fakeWalkIn(
          id: 'w1',
          admittedCount: 2,
          status: WalkInStatus.approved,
          decidedBy: 'mc@example.com',
        );
      final vm = vmFor(api);
      await vm.load();
      final result = await vm.decide(vm.pending.single, domain.WalkInDecision.refuse);
      expect(result, isA<WalkInDecidedElsewhere>());
      final w = (result as WalkInDecidedElsewhere).walkIn;
      expect(w.status, domain.WalkInStatus.approved);
      expect(w.decidedBy, 'mc@example.com');
      expect(vm.pending, isEmpty);
      vm.dispose();
    });

    test('a 403 turns the list read-only', () async {
      final api = walkInApi()..decideErrorCode = 403;
      final vm = vmFor(api);
      await vm.load();
      final result = await vm.decide(vm.pending.single, domain.WalkInDecision.approve);
      expect((result as WalkInDecisionFailed).failure, AppFailure.unauthorized);
      expect(vm.canDecide, isFalse);
      expect(vm.pending, hasLength(1));
      vm.dispose();
    });

    test('read-only view models never call the API to decide', () async {
      final api = walkInApi();
      final vm = vmFor(api, canDecide: false);
      await vm.load();
      await vm.decide(vm.pending.single, domain.WalkInDecision.approve);
      expect(api.decisions, isEmpty);
      vm.dispose();
    });

    test('refreshes when a walk-in push for its event arrives', () async {
      final api = walkInApi();
      final push = FakePushMessageSource();
      final vm = vmFor(api, alerts: WalkInAlertsRepository(push));
      await vm.load();
      expect(api.walkInListCalls, 1);
      push.foregroundController.add(walkInPush(eventId: 'other'));
      push.foregroundController.add({'type': 'contribution', 'eventId': 'e1'});
      await pumpEventQueue();
      expect(api.walkInListCalls, 1);
      api.walkIns = [...api.walkIns, fakeWalkIn(id: 'w9', description: 'Shangazi')];
      push.foregroundController.add(walkInPush());
      await pumpEventQueue();
      expect(api.walkInListCalls, 2);
      expect(vm.pending.map((w) => w.id), ['w1', 'w9']);
      vm.dispose();
    });
  });

  group('WalkInAlertsRepository.parse', () {
    test('reads walk-in pushes and ignores others', () {
      final a = WalkInAlertsRepository.parse(walkInPush(status: 'admitted_offline'), opened: true)!;
      expect(a.eventId, 'e1');
      expect(a.walkInId, 'w9');
      expect(a.status, domain.WalkInStatus.admittedOffline);
      expect(a.opened, isTrue);
      expect(WalkInAlertsRepository.parse({'type': 'lockout', 'eventId': 'e1'}, opened: false), isNull);
      expect(WalkInAlertsRepository.parse({'type': 'walk_in'}, opened: false), isNull);
    });
  });

  group('walk-ins screen', () {
    testWidgets('host approves a pending walk-in from the event screen', (tester) async {
      tallScreen(tester);
      final api = walkInApi();
      await pumpApp(tester, api: api);
      await openWalkInsFromEvent(tester);
      expect(find.text('Waiting for approval (1)'), findsOneWidget);
      expect(find.text('Mjomba wa bibi harusi'), findsOneWidget);
      expect(find.text('2 people'), findsOneWidget);
      expect(find.text('Card: Asha Mohamed'), findsOneWidget);
      expect(find.text('Gate: Lango kuu'), findsWidgets);
      expect(find.text('Requested by door@example.com'), findsWidgets);
      expect(find.textContaining('17:00'), findsWidgets);
      expect(find.text('Admitted offline – needs review (1)'), findsOneWidget);
      expect(find.text('Reason: Mwenyeji alikubali kwa simu'), findsOneWidget);
      expect(find.textContaining('Refused by mc@example.com'), findsOneWidget);

      await tester.tap(find.byKey(const Key('walkIn.approve.w1')));
      await tester.pumpAndSettle();
      expect(api.decisions.single, ('w1', WalkInDecisionInputDecisionEnum.approve));
      expect(find.text('Approved. Let them in.'), findsOneWidget);
      expect(find.text('Waiting for approval (0)'), findsOneWidget);
      expect(find.textContaining('Approved by host@example.com'), findsOneWidget);
    });

    testWidgets('refuses a pending walk-in', (tester) async {
      tallScreen(tester);
      final api = walkInApi();
      await pumpApp(tester, api: api);
      await openWalkInsFromEvent(tester);
      await tester.tap(find.byKey(const Key('walkIn.refuse.w1')));
      await tester.pumpAndSettle();
      expect(api.decisions.single, ('w1', WalkInDecisionInputDecisionEnum.refuse));
      expect(find.textContaining('Refused by host@example.com'), findsOneWidget);
    });

    testWidgets('shows who answered first when someone else already decided (Swahili)', (tester) async {
      tallScreen(tester);
      final api = walkInApi(access: EventAccessEnum.walkinApprover)
        ..decidedElsewhere['w1'] = fakeWalkIn(
          id: 'w1',
          admittedCount: 2,
          status: WalkInStatus.approved,
          decidedBy: 'mc@example.com',
        );
      await pumpApp(tester, api: api, locale: 'sw');
      await openWalkInsFromEvent(tester, label: 'Wageni bila kadi');
      await tester.tap(find.byKey(const Key('walkIn.refuse.w1')));
      await tester.pumpAndSettle();
      expect(find.text('Tayari ameruhusiwa na mc@example.com.'), findsOneWidget);
      expect(find.textContaining('Ameruhusiwa na mc@example.com'), findsOneWidget);
      expect(find.byKey(const Key('walkIn.approve.w1')), findsNothing);
    });

    testWidgets('accepts and flags offline walk-ins', (tester) async {
      tallScreen(tester);
      final api = walkInApi(
        walkIns: [
          fakeWalkIn(id: 'o1', description: 'Dada wa bibi harusi', offlineReason: 'Mwenyeji alikubali kwa simu'),
          fakeWalkIn(id: 'o2', description: 'Mgeni asiyejulikana', offlineReason: 'Mtandao ulikatika'),
        ],
      );
      await pumpApp(tester, api: api);
      await openWalkInsFromEvent(tester);
      expect(find.text('Admitted offline – needs review (2)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('walkIn.accept.o1')));
      await tester.pumpAndSettle();
      expect(find.text('Accepted.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('walkIn.flag.o2')));
      await tester.pumpAndSettle();
      expect(api.decisions, [
        ('o1', WalkInDecisionInputDecisionEnum.accept),
        ('o2', WalkInDecisionInputDecisionEnum.flag),
      ]);
      expect(find.textContaining('Admitted offline'), findsNothing);
      expect(find.textContaining('Accepted by host@example.com'), findsOneWidget);
      expect(find.textContaining('Flagged by host@example.com'), findsOneWidget);
    });

    testWidgets('committee sees the list read-only', (tester) async {
      tallScreen(tester);
      final api = walkInApi(access: EventAccessEnum.committee);
      await pumpApp(tester, api: api);
      await openWalkInsFromEvent(tester);
      expect(find.byKey(const Key('walkIns.readOnly')), findsOneWidget);
      expect(find.text('Mjomba wa bibi harusi'), findsOneWidget);
      expect(find.byKey(const Key('walkIn.approve.w1')), findsNothing);
      expect(find.byKey(const Key('walkIn.accept.w2')), findsNothing);
    });

    testWidgets('walk-in approvers see the walk-ins entry on their event', (tester) async {
      tallScreen(tester);
      await pumpApp(tester, api: walkInApi(access: EventAccessEnum.walkinApprover));
      await signIn(tester);
      await tester.tap(find.text('Harusi ya Asha'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('event.walkIns')), findsOneWidget);
    });

    testWidgets('treasurers do not see the walk-ins entry', (tester) async {
      tallScreen(tester);
      await pumpApp(tester, api: walkInApi(access: EventAccessEnum.treasurer));
      await signIn(tester);
      await tester.tap(find.text('Harusi ya Asha'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('event.walkIns')), findsNothing);
    });

    testWidgets('polls every 10 seconds while open and stops when closed', (tester) async {
      tallScreen(tester);
      final api = walkInApi();
      await pumpApp(tester, api: api);
      await openWalkInsFromEvent(tester);
      expect(api.walkInListCalls, 1);
      api.walkIns = [...api.walkIns, fakeWalkIn(id: 'w9', description: 'Shangazi')];
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(api.walkInListCalls, 2);
      expect(find.text('Shangazi'), findsOneWidget);
      expect(find.text('Waiting for approval (2)'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 30));
      expect(api.walkInListCalls, 2);
    });

    testWidgets('pull to refresh reloads the list', (tester) async {
      tallScreen(tester);
      final api = walkInApi();
      await pumpApp(tester, api: api);
      await openWalkInsFromEvent(tester);
      await tester.fling(find.byKey(const Key('walkIns.list')), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(api.walkInListCalls, 2);
    });
  });

  group('walk-in pushes', () {
    testWidgets('a foreground request shows a banner that opens the walk-ins screen', (tester) async {
      tallScreen(tester);
      final push = FakePushMessageSource();
      await pumpApp(tester, api: walkInApi(), push: push);
      await signIn(tester);
      push.foregroundController.add(walkInPush());
      await tester.pumpAndSettle();
      expect(find.text('New walk-in request at the door'), findsOneWidget);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Waiting for approval (1)'), findsOneWidget);
      expect(find.byKey(const Key('walkIn.approve.w1')), findsOneWidget);
    });

    testWidgets('an offline walk-in push shows the review banner in Swahili', (tester) async {
      tallScreen(tester);
      final push = FakePushMessageSource();
      await pumpApp(tester, api: walkInApi(), push: push, locale: 'sw');
      await signIn(tester);
      push.foregroundController.add(walkInPush(status: 'admitted_offline'));
      await tester.pumpAndSettle();
      expect(find.text('Mgeni aliyeingizwa bila mtandao anahitaji ukaguzi'), findsOneWidget);
      expect(find.text('Fungua'), findsOneWidget);
    });

    testWidgets('tapping a notification opens that event\'s walk-ins screen', (tester) async {
      tallScreen(tester);
      final push = FakePushMessageSource();
      await pumpApp(
        tester,
        api: walkInApi(access: EventAccessEnum.committee),
        push: push,
      );
      await signIn(tester);
      push.openedController.add(walkInPush());
      await tester.pumpAndSettle();
      expect(find.text('Waiting for approval (1)'), findsOneWidget);
      // Access comes from the event: committee stays read-only.
      expect(find.byKey(const Key('walkIns.readOnly')), findsOneWidget);
    });

    testWidgets('the notification that launched the app opens the walk-ins screen after sign-in', (tester) async {
      tallScreen(tester);
      final push = FakePushMessageSource()..initialMessage = walkInPush();
      await pumpApp(tester, api: walkInApi(), push: push);
      await signIn(tester);
      await tester.pumpAndSettle();
      expect(find.text('Waiting for approval (1)'), findsOneWidget);
    });

    testWidgets('an open walk-ins screen refreshes on push without a banner', (tester) async {
      tallScreen(tester);
      final push = FakePushMessageSource();
      final api = walkInApi();
      await pumpApp(tester, api: api, push: push);
      await openWalkInsFromEvent(tester);
      api.walkIns = [...api.walkIns, fakeWalkIn(id: 'w9', description: 'Shangazi')];
      push.foregroundController.add(walkInPush());
      await tester.pumpAndSettle();
      expect(find.text('Shangazi'), findsOneWidget);
      expect(find.byKey(const Key('walkIn.banner')), findsNothing);
      // A tapped notification for the same event does not stack another screen.
      push.openedController.add(walkInPush());
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('event.walkIns')), findsOneWidget);
    });
  });
}
