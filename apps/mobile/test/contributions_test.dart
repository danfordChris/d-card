import 'package:dcard_api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart' show pumpApp, signIn, tapBack;
import 'fakes/fakes.dart';

Future<void> openContributions(WidgetTester tester, String label) async {
  await signIn(tester);
  await tester.tap(find.text('Harusi ya Asha').first);
  await tester.pumpAndSettle();
  // The host's unpaid-event banner pushes the actions down.
  await tester.scrollUntilVisible(find.text(label), 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The Record payment button sits under the form: scroll to it first.
Future<void> tapRecord(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Record payment');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
}

FakeApi apiWith({EventAccessEnum? access}) => FakeApi(events: [fakeEvent(access: access)])
  ..pledges = [
    fakePledge(id: 'p1', name: 'Mzee Salum', phone: '255713500001', paid: 20000),
    fakePledge(id: 'p2', name: 'Rehema', phone: '255713500002'),
  ];

void main() {
  testWidgets('lists contributors with totals, filters and search in Swahili', (tester) async {
    await pumpApp(
      tester,
      locale: 'sw',
      api: apiWith(access: EventAccessEnum.treasurer),
    );
    await openContributions(tester, 'Michango');
    expect(find.text('TSh 100,000'), findsOneWidget);
    expect(find.text('TSh 20,000'), findsOneWidget);
    expect(find.textContaining('Amelipa TSh 20,000 kati ya TSh 50,000'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Hajalipa'));
    await tester.pumpAndSettle();
    expect(find.text('Mzee Salum'), findsNothing);
    expect(find.text('Rehema'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Wote'));
    await tester.enterText(find.byKey(const Key('contributions.search')), '0713 500 001');
    await tester.pumpAndSettle();
    expect(find.text('Mzee Salum'), findsOneWidget);
    expect(find.text('Rehema'), findsNothing);
  });

  testWidgets('validates the amount, records the final payment and shows the issued card', (tester) async {
    final api = apiWith(access: EventAccessEnum.treasurer);
    await pumpApp(tester, api: api);
    await openContributions(tester, 'Contributions');
    await tester.tap(find.text('Mzee Salum'));
    await tester.pumpAndSettle();
    await tapRecord(tester);
    await tester.pumpAndSettle();
    expect(find.text('Enter the amount.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('payment.amount')), '12.5');
    await tapRecord(tester);
    await tester.pumpAndSettle();
    expect(find.text('Enter a whole amount in TSh.'), findsOneWidget);
    expect(api.payments, isEmpty);

    await tester.enterText(find.byKey(const Key('payment.amount')), '30,000');
    await tester.tap(find.byKey(const Key('payment.method')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment.reference')), 'R-9');
    await tapRecord(tester);
    await tester.pumpAndSettle();
    expect(find.text('Fully paid. Card 007-1234 has been issued.'), findsOneWidget);
    expect(find.text('Balance TSh 0'), findsOneWidget);
    final sent = api.payments.single;
    expect([sent.amount, sent.method, sent.reference], [30000, PaymentMethod.cash, 'R-9']);

    await tapBack(tester);
    await tester.pumpAndSettle();
    expect(find.text('007-1234'), findsOneWidget);
    expect(find.textContaining('Paid TSh 50,000 of TSh 50,000'), findsOneWidget);
  });

  testWidgets('a part payment shows the new balance', (tester) async {
    final api = apiWith();
    await pumpApp(tester, api: api);
    await openContributions(tester, 'Contributions');
    await tester.tap(find.text('Rehema'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment.amount')), '10000');
    await tapRecord(tester);
    await tester.pumpAndSettle();
    expect(find.text('Payment saved.'), findsOneWidget);
    expect(find.text('Balance TSh 40,000'), findsOneWidget);
  });

  testWidgets('committee sees contributions but cannot record', (tester) async {
    await pumpApp(tester, api: apiWith(access: EventAccessEnum.committee));
    await openContributions(tester, 'Contributions');
    await tester.tap(find.text('Mzee Salum'));
    await tester.pumpAndSettle();
    expect(find.text('Record payment'), findsNothing);
  });

  testWidgets('door staff do not see contributions', (tester) async {
    await pumpApp(
      tester,
      api: FakeApi(events: [fakeEvent(access: EventAccessEnum.doorStaff)]),
    );
    await signIn(tester);
    await tester.tap(find.text('Harusi ya Asha').first);
    await tester.pumpAndSettle();
    expect(find.text('Contributions'), findsNothing);
  });
}
