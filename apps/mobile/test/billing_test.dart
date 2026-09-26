import 'package:dcard_api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart' show pumpApp, signIn;
import 'fakes/fakes.dart';

/// Poll interval of the checkout (3 s).
const poll = Duration(seconds: 3);

/// The page's list (text fields have their own horizontal scrollables).
final _vertical = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down);

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  // ListView builds lazily: scroll until the target exists, then into view.
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _vertical.last);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

/// Signs in, opens the event and the checkout for an unpaid event.
Future<void> openBuy(WidgetTester tester) async {
  await signIn(tester);
  await tester.tap(find.text('Harusi ya Asha'));
  await tester.pumpAndSettle();
  await tapKey(tester, 'event.pay');
  await tester.pumpAndSettle();
  await tapKey(tester, 'billing.buy');
  await tester.pumpAndSettle();
}

Future<void> review(WidgetTester tester, {String phone = '0754 123 456'}) async {
  await tapKey(tester, 'checkout.continue');
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('checkout.phone')), phone);
}

/// Taps Pay and lets the checkout request finish (the waiting screen has a spinner, so no settle).
Future<void> pay(WidgetTester tester) async {
  await tapKey(tester, 'checkout.pay');
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

String totalText(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('checkout.total'))).data!;

void main() {
  testWidgets('shows the unpaid banner and a live quote with the minimum charge and launch offer', (tester) async {
    final api = FakeApi(events: [fakeEvent()])..billingGuestCount = 20;
    await pumpApp(tester, api: api);
    await signIn(tester);
    await tester.tap(find.text('Harusi ya Asha'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('event.payBanner')), findsOneWidget);
    await tapKey(tester, 'event.pay');
    await tester.pumpAndSettle();
    expect(find.text('Not paid'), findsOneWidget);
    expect(find.text('Launch offer: 20% off your first event.'), findsOneWidget);
    await tapKey(tester, 'billing.buy');
    await tester.pumpAndSettle();

    // 20 guests on Kawaida (TSh 1,500): the TSh 50,000 minimum makes it 34 cards.
    expect(api.quoteRequests.last.guestCards, 20);
    expect(find.byKey(const Key('checkout.minimum')), findsOneWidget);
    expect(find.textContaining('The minimum charge per event is TSh 50,000, so you get 34 cards.'), findsOneWidget);
    expect(find.text('34 cards × TSh 1,500'), findsOneWidget);
    expect(find.text('TSh 51,000'), findsNWidgets(2)); // line + subtotal
    expect(find.text('Launch offer (20% off)'), findsOneWidget);
    expect(find.text('− TSh 10,200'), findsOneWidget);
    expect(totalText(tester), 'TSh 40,800');

    // More cards: debounced re-quote.
    await tapKey(tester, 'checkout.increase');
    await tester.pump();
    expect(api.quoteRequests.last.guestCards, 20, reason: 'debounced');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(api.quoteRequests.last.guestCards, 30);

    // A higher plan re-quotes at its price.
    await tapKey(tester, 'checkout.plan.premium');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(api.quoteRequests.last.planKey, PlanKey.premium);
    expect(find.text('30 cards × TSh 2,000'), findsOneWidget); // above Premium's 25-card minimum
    expect(totalText(tester), 'TSh 48,000');
  });

  testWidgets('validates the phone, pays with expectedTotal, polls and shows the receipt', (tester) async {
    final api = FakeApi(events: [fakeEvent()])
      ..billingGuestCount = 20
      ..pollStatuses = ['pending', 'completed'];
    await pumpApp(tester, api: api);
    await openBuy(tester);
    await review(tester, phone: '12345');
    await pay(tester);
    await tester.pumpAndSettle();
    expect(find.text('Enter a Tanzanian number, for example 0754 123 456.'), findsOneWidget);
    expect(api.checkouts, isEmpty);

    await tester.enterText(find.byKey(const Key('checkout.phone')), '0754 123 456');
    await tester.pump();
    expect(find.text('Pay TSh 40,800'), findsOneWidget);
    await pay(tester);
    final body = api.checkouts.single;
    expect(body.expectedTotal, 40800);
    expect(body.phone, '255754123456');
    expect(body.method, HostPaymentMethod.mobile);
    expect(body.guestCards, 20);
    expect(body.planKey, PlanKey.kawaida);

    expect(find.text('Check your phone and enter your PIN'), findsOneWidget);
    expect(find.textContaining('TSh 40,800 to 0754 123 456'), findsOneWidget);
    await tester.pump(poll);
    await tester.pump();
    expect(api.pollCalls, 1);
    expect(find.text('Check your phone and enter your PIN'), findsOneWidget);
    await tester.pump(poll);
    await tester.pumpAndSettle();
    expect(api.pollCalls, 2);
    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('SNP-12345'), findsOneWidget);
    expect(find.text('34 cards'), findsOneWidget);
    expect(find.text('Oct 1, 2026 · 12:01 EAT'), findsOneWidget);

    // Polling stopped after completion.
    await tester.pump(poll * 2);
    expect(api.pollCalls, 2);
  });

  testWidgets('a failed payment can be retried', (tester) async {
    final api = FakeApi(events: [fakeEvent()])..pollStatuses = ['failed'];
    await pumpApp(tester, api: api);
    await openBuy(tester);
    await review(tester);
    await pay(tester);
    await tester.pump(poll);
    await tester.pumpAndSettle();
    expect(find.text('The payment did not go through'), findsOneWidget);
    expect(find.text('No money was taken. You can try again.'), findsOneWidget);

    await tapKey(tester, 'checkout.retry');
    await tester.pumpAndSettle();
    expect(find.text('Review and pay'), findsOneWidget);
    api.pollStatuses = ['completed'];
    await pay(tester);
    expect(api.checkouts, hasLength(2));
    await tester.pump(poll);
    await tester.pumpAndSettle();
    expect(find.text('Payment received'), findsOneWidget);
  });

  testWidgets('quote_changed shows the new total and asks to confirm again', (tester) async {
    final api = FakeApi(events: [fakeEvent()])..billingGuestCount = 20;
    await pumpApp(tester, api: api);
    await openBuy(tester);
    await review(tester);
    api.priceDrift = 1000; // the server price changes after the quote
    await pay(tester);
    await tester.pumpAndSettle();
    expect(api.checkouts.single.expectedTotal, 40800);
    expect(find.text('The price changed. Check the new total and confirm again.'), findsOneWidget);
    expect(find.text('Review and pay'), findsOneWidget);
    expect(totalText(tester), 'TSh 41,600');

    await pay(tester);
    expect(api.checkouts, hasLength(2));
    expect(api.checkouts.last.expectedTotal, 41600);
    expect(find.text('Check your phone and enter your PIN'), findsOneWidget);
  });

  testWidgets('payment_in_progress resumes the waiting payment from the summary', (tester) async {
    final api = FakeApi(events: [fakeEvent()])
      ..checkoutErrors.add('payment_in_progress')
      ..pollStatuses = ['pending'];
    await pumpApp(tester, api: api);
    await openBuy(tester);
    await review(tester);
    api.pendingAttempt = {
      'id': 'att0',
      'status': 'pending',
      'method': 'mobile',
      'amount': 40800,
      'planKey': 'kawaida',
      'guestCards': 34,
      'phone': '255713000111',
      'checkoutUrl': null,
      'reference': null,
      'failureReason': null,
      'createdAt': '2026-10-01T08:58:00.000Z',
      'completedAt': null,
    };
    await pay(tester);
    await tester.pump();
    expect(find.text('Another payment for this event is still waiting. Check its status first.'), findsOneWidget);
    expect(find.text('Check your phone and enter your PIN'), findsOneWidget);
    expect(find.textContaining('0713 000 111'), findsOneWidget);

    // Leaving does not cancel the payment: the billing screen shows it and can resume it.
    await tester.pump(poll);
    expect(api.pollCalls, 1, reason: 'still pending');
    await tester.ensureVisible(find.byKey(const Key('checkout.later')));
    await tester.tap(find.byKey(const Key('checkout.later')));
    await tester.pumpAndSettle();
    expect(find.text('A payment is waiting'), findsOneWidget);
    final polls = api.pollCalls;
    await tester.pump(poll * 2);
    expect(api.pollCalls, polls, reason: 'no polling after leaving');
    api.pollStatuses = ['completed'];
    await tapKey(tester, 'billing.resume');
    await tester.pump();
    await tester.pump();
    expect(find.text('Check your phone and enter your PIN'), findsOneWidget);
    await tester.pump(poll);
    await tester.pumpAndSettle();
    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('SNP-12345'), findsOneWidget);
  });

  testWidgets('paid event: add 10 more by card page, receipts in Swahili', (tester) async {
    final links = FakeLinkOpener();
    final api = FakeApi(events: [fakeEvent(planPaid: true)])
      ..billingGuestLimit = 100
      ..billingAmountPaid = 150000
      ..billingGuestCount = 100
      ..billingIssuedCards = 60
      ..launchOfferPercent = 0
      ..hostPayments = [
        {
          'id': 'hp1',
          'planKey': 'kawaida',
          'guestCards': 100,
          'amount': 150000,
          'discountAmount': 0,
          'method': 'mobile',
          'reference': 'SNP-00001',
          'paidAt': '2026-09-20T07:30:00.000Z',
        },
      ];
    await pumpApp(tester, api: api, locale: 'sw', links: links);
    await signIn(tester);
    await tester.tap(find.text('Harusi ya Asha'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('event.payBanner')), findsNothing);
    await tapKey(tester, 'event.payment');
    await tester.pumpAndSettle();
    expect(find.text('Malipo'), findsWidgets);
    expect(find.text('Imelipiwa'), findsOneWidget);
    expect(find.text('SNP-00001'), findsOneWidget);
    expect(find.text('TSh 150,000'), findsWidgets);

    await tapKey(tester, 'billing.addBlock');
    await tester.pumpAndSettle();
    expect(api.quoteRequests.last.guestCards, 110);
    expect(find.text('Kadi za ziada 10 × TSh 1,500'), findsOneWidget);
    expect(totalText(tester), 'TSh 15,000');
    expect(find.byKey(const Key('checkout.plan.msingi')), findsNothing, reason: 'upward plans only');

    await tapKey(tester, 'checkout.continue');
    await tester.pumpAndSettle();
    await tapKey(tester, 'checkout.method.session');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkout.phone')), findsNothing);
    await pay(tester);
    expect(api.checkouts.single.method, HostPaymentMethod.session);
    expect(api.checkouts.single.phone, isNull);
    expect(api.checkouts.single.expectedTotal, 15000);
    expect(links.opened.single.toString(), 'https://pay.example.com/s/att1');
    expect(find.text('Maliza kulipa kwenye kivinjari'), findsOneWidget);
  });

  testWidgets('upgrade defaults to the next plan and prices the difference', (tester) async {
    final api = FakeApi(events: [fakeEvent(planPaid: true)])
      ..billingGuestLimit = 100
      ..launchOfferPercent = 0;
    await pumpApp(tester, api: api);
    await signIn(tester);
    await tester.tap(find.text('Harusi ya Asha'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'event.payment');
    await tester.pumpAndSettle();
    await tapKey(tester, 'billing.upgrade');
    await tester.pumpAndSettle();
    expect(api.quoteRequests.last.planKey, PlanKey.premium);
    expect(api.quoteRequests.last.guestCards, 100);
    expect(find.text('Upgrade 100 cards (+TSh 500 each)'), findsOneWidget);
    expect(totalText(tester), 'TSh 50,000');

    // Back to the current plan with the same cards: nothing to pay.
    await tapKey(tester, 'checkout.plan.kawaida');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.textContaining('Nothing to pay'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('checkout.continue'))).onPressed, isNull);
  });
}
