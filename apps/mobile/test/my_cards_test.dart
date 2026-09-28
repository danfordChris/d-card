import 'package:dcard_api/api.dart';
import 'package:dcard_mobile/data/repositories/my_cards_repository.dart';
import 'package:dcard_mobile/data/services/auth_service.dart';
import 'package:dcard_mobile/domain/models/app_failure.dart';
import 'package:dcard_mobile/domain/models/guest_card.dart';
import 'package:dcard_mobile/ui/features/my_cards/view_models/my_cards_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart' show pumpApp;
import 'fakes/fakes.dart';

const tokenA = 'tokAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
const tokenB = 'tokBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

Future<void> googleSignIn(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('login.google')));
  await tester.pumpAndSettle();
}

Future<void> openLinkSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('myCards.link')));
  await tester.pumpAndSettle();
}

Future<void> submitLink(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('link.input')), text);
  await tester.tap(find.byKey(const Key('link.submit')));
  await tester.pumpAndSettle();
}

void main() {
  group('parseCardToken', () {
    test('accepts a card link or a bare token', () {
      expect(parseCardToken('https://dcard.co.tz/c/$tokenA'), tokenA);
      expect(parseCardToken('  dcard.co.tz/c/$tokenA?utm=sms '), tokenA);
      expect(parseCardToken('https://dcard.co.tz/sw/c/$tokenA/'), tokenA);
      expect(parseCardToken(tokenA), tokenA);
    });

    test('rejects other text', () {
      expect(parseCardToken(''), isNull);
      expect(parseCardToken('hello'), isNull);
      expect(parseCardToken('https://dcard.co.tz/events/123'), isNull);
      expect(parseCardToken('https://dcard.co.tz/c/short'), isNull);
    });
  });

  group('MyCardsViewModel', () {
    test('lists cards newest first', () async {
      final api = FakeApi()
        ..myCards = [
          fakeMyCard(token: tokenA, title: 'Older', startsAt: '2026-10-01T12:00:00.000Z'),
          fakeMyCard(token: tokenB, title: 'Newer', startsAt: '2026-12-12T12:00:00.000Z', venue: null),
        ];
      final vm = MyCardsViewModel(MyCardsRepository(api));
      await vm.load();
      expect(vm.failure, isNull);
      expect(vm.cards.map((c) => c.eventTitle), ['Newer', 'Older']);
      expect(vm.cards.first.venueName, isNull);
      expect(vm.cards.first.status, CardStatus.issued);
    });

    test('empty list', () async {
      final vm = MyCardsViewModel(MyCardsRepository(FakeApi()));
      await vm.load();
      expect(vm.loaded, isTrue);
      expect(vm.cards, isEmpty);
    });

    test('links a pasted card link and reloads', () async {
      final api = FakeApi()..linkable = {tokenA: fakeMyCard(token: tokenA)};
      final vm = MyCardsViewModel(MyCardsRepository(api));
      await vm.load();
      expect(await vm.link('https://dcard.co.tz/c/$tokenA'), isTrue);
      expect(api.linkRequests, [tokenA]);
      expect(vm.cards, hasLength(1));
      expect(vm.linkRefusal, isNull);
    });

    test('refuses text that is not a card link without calling the API', () async {
      final api = FakeApi();
      final vm = MyCardsViewModel(MyCardsRepository(api));
      expect(await vm.link('not a link'), isFalse);
      expect(vm.linkRefusal, LinkRefusal.invalidLink);
      expect(api.linkRequests, isEmpty);
    });

    for (final (status, code, refusal) in [
      (404, 'not_found', LinkRefusal.notFound),
      (409, 'person_linked', LinkRefusal.personLinked),
      (409, 'account_linked', LinkRefusal.accountLinked),
    ]) {
      test('maps $status $code', () async {
        final api = FakeApi()..linkError = (status, code);
        final vm = MyCardsViewModel(MyCardsRepository(api));
        expect(await vm.link(tokenA), isFalse);
        expect(vm.linkRefusal, refusal);
        expect(vm.linkFailure, isNull);
      });
    }

    test('other errors are generic failures', () async {
      final api = FakeApi()..linkError = (500, 'internal');
      final vm = MyCardsViewModel(MyCardsRepository(api));
      expect(await vm.link(tokenA), isFalse);
      expect(vm.linkRefusal, isNull);
      expect(vm.linkFailure, AppFailure.unknown);
    });
  });

  group('guest mode', () {
    testWidgets('Apple shows only when enabled (iOS); cancelling Google shows no error', (tester) async {
      final auth = FakeAuthService()..socialFailure = AppFailure.cancelled;
      final (_, api) = await pumpApp(tester, auth: auth);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsNothing, reason: 'tests run as Android');
      await googleSignIn(tester);
      expect(auth.socialSignIns, [SocialProvider.google]);
      expect(api.provisionCalls, 0);
      expect(find.text('Something went wrong. Please try again.'), findsNothing);
      expect(find.text('Welcome to D-Card'), findsOneWidget);
    });

    testWidgets('Google sign-in provisions and opens My cards with the empty state in Swahili', (tester) async {
      final (_, api) = await pumpApp(tester, locale: 'sw', api: FakeApi());
      expect(find.text('Endelea na Google'), findsOneWidget);
      await googleSignIn(tester);
      expect(api.provisionCalls, 1);
      expect(api.myCardsCalls, 1);
      expect(api.listCalls, 0, reason: 'the Events tab loads only when opened');
      expect(find.text('Bado huna kadi'), findsOneWidget);
      expect(find.textContaining('bandika kiungo hicho'), findsOneWidget);
    });

    testWidgets('links a card from the sheet and shows 409 messages', (tester) async {
      final api = FakeApi()..linkError = (409, 'person_linked');
      await pumpApp(tester, api: api);
      await googleSignIn(tester);
      await openLinkSheet(tester);
      await submitLink(tester, 'nonsense');
      expect(find.text('This is not a D-Card card link. Check it and try again.'), findsOneWidget);

      await submitLink(tester, 'https://dcard.co.tz/c/$tokenA');
      expect(find.textContaining("This card's guest already uses another D-Card account"), findsOneWidget);

      api.linkError = (409, 'account_linked');
      await submitLink(tester, 'https://dcard.co.tz/c/$tokenA');
      expect(find.textContaining('This account already belongs to another guest'), findsOneWidget);

      api
        ..linkError = null
        ..linkable = {tokenA: fakeMyCard(token: tokenA, rsvp: 'yes')};
      await submitLink(tester, 'https://dcard.co.tz/c/$tokenA');
      expect(find.byKey(const Key('link.input')), findsNothing, reason: 'sheet closes');
      expect(find.text('Card linked.'), findsOneWidget);
      expect(find.text('Harusi ya Asha'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Attending'), findsOneWidget);
    });

    testWidgets('opens a card with QR and answers RSVP', (tester) async {
      final api = FakeApi()
        ..myCards = [fakeMyCard(token: tokenA)]
        ..publicCards = {tokenA: fakePublicCard()};
      await pumpApp(tester, api: api);
      await googleSignIn(tester);
      expect(find.text('No reply yet'), findsOneWidget);
      await tester.tap(find.byKey(const Key('myCards.card.007-1234')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('card.qr')), findsOneWidget);
      expect(find.text('007-1234'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Diamond Jubilee, Upanga, Dar es Salaam'), 200);

      await tester.scrollUntilVisible(find.byKey(const Key('rsvp.yes')), 200);
      await tester.tap(find.byKey(const Key('rsvp.yes')));
      await tester.pumpAndSettle();
      expect(api.rsvps.single, (tokenA, RsvpInputAnswerEnum.yes));
      expect(find.text('Thank you, your answer is saved.'), findsOneWidget);

      api.myCards = [fakeMyCard(token: tokenA, rsvp: 'yes')];
      final calls = api.myCardsCalls;
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(api.myCardsCalls, calls + 1, reason: 'list refreshes after an RSVP change');
      expect(find.text('Attending'), findsOneWidget);
    });

    testWidgets('closed RSVP and cancelled card', (tester) async {
      final api = FakeApi()
        ..myCards = [fakeMyCard(token: tokenA), fakeMyCard(token: tokenB, cardNumber: '007-9999', status: 'cancelled')]
        ..publicCards = {
          tokenA: fakePublicCard(open: false),
          tokenB: fakePublicCard(status: 'cancelled', cardNumber: '007-9999'),
        };
      await pumpApp(tester, api: api);
      await googleSignIn(tester);
      await tester.tap(find.byKey(const Key('myCards.card.007-1234')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byKey(const Key('rsvp.closed')), 200);
      expect(find.text('Replies are closed for this event.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('rsvp.no')), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(api.rsvps, isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('myCards.card.007-9999')));
      await tester.pumpAndSettle();
      expect(find.text('This card has been cancelled.'), findsOneWidget);
      expect(find.byKey(const Key('card.qr')), findsNothing);
      expect(find.byKey(const Key('rsvp.yes')), findsNothing);
    });
  });

  group('account', () {
    Future<void> openAccount(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('nav.account')));
      await tester.pumpAndSettle();
    }

    testWidgets('downloads my data to a file', (tester) async {
      final files = FakeFileSaver();
      final (_, api) = await pumpApp(tester, api: FakeApi(), files: files);
      await googleSignIn(tester);
      await openAccount(tester);
      expect(find.text('Signed in with Google'), findsOneWidget);
      await tester.tap(find.byKey(const Key('account.export')));
      await tester.pumpAndSettle();
      expect(api.exportCalls, 1);
      expect(files.saved.keys, ['dcard-my-data-2026-10-01.json']);
      expect(find.text('Saved to /docs/dcard-my-data-2026-10-01.json'), findsOneWidget);
    });

    testWidgets('delete is refused while hosting events, then succeeds and signs out', (tester) async {
      final api = FakeApi()..deleteMeStatus = 409;
      final (auth, _) = await pumpApp(tester, api: api);
      await googleSignIn(tester);
      await openAccount(tester);

      await tester.tap(find.byKey(const Key('account.delete')));
      await tester.pumpAndSettle();
      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(api.deleteMeCalls, 0);

      await tester.tap(find.byKey(const Key('account.delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account.deleteConfirm')));
      await tester.pumpAndSettle();
      expect(api.deleteMeCalls, 1);
      expect(find.text('You still host events. Delete your events before deleting your account.'), findsOneWidget);
      expect(auth.currentUser, isNotNull);

      api.deleteMeStatus = null;
      await tester.tap(find.byKey(const Key('account.delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account.deleteConfirm')));
      await tester.pumpAndSettle();
      expect(api.deleteMeCalls, 2);
      expect(auth.currentUser, isNull);
      expect(find.text('Welcome to D-Card'), findsOneWidget);

      await googleSignIn(tester);
      expect(api.provisionCalls, 2, reason: 'a deleted account is provisioned again on the next sign-in');
    });
  });
}
