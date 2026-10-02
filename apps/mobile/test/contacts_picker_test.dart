import 'package:dcard_api/api.dart';
import 'package:dcard_mobile/data/services/contacts_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart' show pumpApp, signIn;
import 'fakes/fakes.dart';

const _contacts = [
  PhoneContact(id: 'c1', name: 'Bahati', phones: ['+255 713 100 001', '0713 100 011']),
  PhoneContact(id: 'c2', name: 'Chausiku', phones: ['0713-100-002']),
  PhoneContact(id: 'c3', name: 'Mjomba Kenya', phones: ['+254 712 000 000']),
];

Future<void> openPicker(WidgetTester tester) async {
  await signIn(tester);
  await tester.tap(find.text('Harusi ya Asha').first);
  await tester.pumpAndSettle();
  // The host's unpaid-event banner pushes the actions down.
  await tester.scrollUntilVisible(find.text('Add from contacts'), 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add from contacts'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('asks for permission only when the picker opens; denial explains and links to settings', (tester) async {
    final contacts = FakeContactsSource(permission: ContactsPermission.permanentlyDenied);
    await pumpApp(tester, contacts: contacts);
    await signIn(tester);
    await tester.tap(find.text('Harusi ya Asha').first);
    await tester.pumpAndSettle();
    expect(contacts.permissionRequests, 0);

    // The host's unpaid-event banner pushes the actions down.
    await tester.scrollUntilVisible(find.text('Add from contacts'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add from contacts'));
    await tester.pumpAndSettle();
    expect(contacts.permissionRequests, 1);
    expect(find.text('Allow access to contacts'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    expect(contacts.settingsOpened, 1);
  });

  testWidgets('hides the button when the user cannot manage guests', (tester) async {
    await pumpApp(
      tester,
      api: FakeApi(events: [fakeEvent(status: EventStatusEnum.cancelled)]),
    );
    await signIn(tester);
    await tester.tap(find.text('Harusi ya Asha').first);
    await tester.pumpAndSettle();
    expect(find.text('Add from contacts'), findsNothing);
  });

  testWidgets('marks invalid numbers, requires consent, and adds the selection', (tester) async {
    final api = FakeApi(events: [fakeEvent()])..invitedPhones = {'255713100002'};
    await pumpApp(
      tester,
      api: api,
      contacts: FakeContactsSource(contacts: _contacts),
    );
    await openPicker(tester);

    expect(find.text('0713 100 001'), findsOneWidget);
    expect(find.text('0713 100 011'), findsOneWidget);
    expect(find.text('Not a valid Tanzanian number'), findsOneWidget);
    final invalid = tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, '+254 712 000 000'));
    expect(invalid.onChanged, isNull);

    // One number per contact: picking the second replaces the first.
    await tester.tap(find.text('0713 100 001'));
    await tester.pump();
    await tester.tap(find.text('0713 100 011'));
    await tester.pump();
    await tester.tap(find.text('0713 100 002'));
    await tester.pump();
    expect(find.text('Add 2 guests'), findsOneWidget);

    await tester.tap(find.text('Add 2 guests'));
    await tester.pump();
    expect(find.text('Confirm consent to continue.'), findsOneWidget);
    expect(api.lastBulk, isNull);

    await tester.tap(find.byKey(const Key('contacts.consent')));
    await tester.pump();
    await tester.tap(find.text('Add 2 guests'));
    await tester.pumpAndSettle();
    expect(api.lastBulkEventId, 'e1');
    expect(api.lastBulk!.consent, isTrue);
    expect(
      [for (final g in api.lastBulk!.guests) '${g.name}:${g.phone}'],
      ['Bahati:255713100011', 'Chausiku:255713100002'],
    );
    expect(find.text('1 guest added'), findsOneWidget);
    expect(find.text('1 was already invited'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Add from contacts'), findsOneWidget);
  });

  testWidgets('filters contacts by name in Swahili', (tester) async {
    await pumpApp(
      tester,
      locale: 'sw',
      contacts: FakeContactsSource(contacts: _contacts),
    );
    await signIn(tester);
    await tester.tap(find.text('Harusi ya Asha').first);
    await tester.pumpAndSettle();
    // The host's unpaid-event banner pushes the actions down.
    await tester.scrollUntilVisible(find.text('Ongeza kutoka simu'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ongeza kutoka simu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('contacts.search')), 'chau');
    await tester.pump();
    expect(find.text('Chausiku'), findsOneWidget);
    expect(find.text('Bahati'), findsNothing);
    expect(find.text('Si namba sahihi ya Tanzania'), findsNothing);
  });
}
