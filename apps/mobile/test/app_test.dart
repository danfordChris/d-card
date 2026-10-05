import 'dart:io';

import 'package:dcard_api/api.dart';
import 'package:dcard_mobile/app.dart';
import 'package:dcard_mobile/data/repositories/account_repository.dart';
import 'package:dcard_mobile/data/repositories/billing_repository.dart';
import 'package:dcard_mobile/data/repositories/contributions_repository.dart';
import 'package:dcard_mobile/data/repositories/events_repository.dart';
import 'package:dcard_mobile/data/repositories/guests_repository.dart';
import 'package:dcard_mobile/data/repositories/messages_repository.dart';
import 'package:dcard_mobile/data/repositories/my_cards_repository.dart';
import 'package:dcard_mobile/data/repositories/team_repository.dart';
import 'package:dcard_mobile/data/repositories/session_repository.dart';
import 'package:dcard_mobile/data/repositories/theme_repository.dart';
import 'package:dcard_mobile/data/repositories/walk_in_alerts_repository.dart';
import 'package:dcard_mobile/data/repositories/walk_ins_repository.dart';
import 'package:dcard_mobile/domain/models/app_failure.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fakes.dart';

Future<(FakeAuthService, FakeApi)> pumpApp(
  WidgetTester tester, {
  String locale = 'en',
  FakeAuthService? auth,
  FakeApi? api,
  FakeContactsSource? contacts,
  FakePushMessageSource? push,
  FakeLinkOpener? links,
  FakeFileSaver? files,
  Map<String, Object> prefsValues = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final a = auth ?? FakeAuthService();
  final p = api ?? FakeApi(events: [fakeEvent()]);
  await tester.pumpWidget(
    DCardApp(
      session: SessionRepository(auth: a, api: p, prefs: prefs),
      events: EventsRepository(p),
      guests: GuestsRepository(p),
      contacts: contacts ?? FakeContactsSource(),
      contributions: ContributionsRepository(p),
      messages: MessagesRepository(p),
      team: TeamRepository(p),
      walkIns: WalkInsRepository(p),
      walkInAlerts: WalkInAlertsRepository(push ?? FakePushMessageSource()),
      billing: BillingRepository(p),
      myCards: MyCardsRepository(p),
      account: AccountRepository(p, files ?? FakeFileSaver()),
      theme: ThemeRepository(prefs),
      links: links ?? FakeLinkOpener(),
      locale: Locale(locale),
    ),
  );
  await tester.pumpAndSettle();
  return (a, p);
}

Future<void> signIn(WidgetTester tester, {String email = 'host@example.com', String password = 'secret1'}) async {
  await tester.enterText(find.byKey(const Key('login.email')), email);
  await tester.enterText(find.byKey(const Key('login.password')), password);
  await tapSignIn(tester);
}

/// Taps the email sign-in button (below the Google/Apple buttons, so scroll first).
Future<void> tapSignIn(WidgetTester tester) async {
  final button = find.byKey(const Key('login.submit'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// Taps the top bar's round back button (labelled for screen readers).
Future<void> tapBack(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(DcTopBar), matching: find.byType(DcCircleButton)).last);
}

/// Signs out from the Account tab.
Future<void> signOut(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav.account')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('account.signOut')));
  await tester.pumpAndSettle();
}

void main() {
  group('login', () {
    testWidgets('validates input in Swahili without calling AuthService', (tester) async {
      final (auth, _) = await pumpApp(tester, locale: 'sw');
      expect(find.text('Karibu D-Card'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Ingia'), findsOneWidget);
      await tapSignIn(tester);
      expect(find.text('Weka barua pepe yako.'), findsOneWidget);
      expect(find.text('Weka nenosiri lako.'), findsOneWidget);
      await signIn(tester, email: 'not-an-email');
      expect(find.text('Weka barua pepe sahihi.'), findsOneWidget);
      expect(auth.signIns, isEmpty);
    });

    testWidgets('shows a localised error when sign-in fails', (tester) async {
      final (auth, api) = await pumpApp(tester, auth: FakeAuthService(failure: AppFailure.invalidCredentials));
      await signIn(tester);
      expect(find.text('Wrong email or password.'), findsOneWidget);
      expect(auth.signIns, ['host@example.com']);
      expect(api.provisionCalls, 0);
      expect(find.text('My events'), findsNothing);
    });

    testWidgets('signs in, provisions once, lists events, and signs out', (tester) async {
      final (_, api) = await pumpApp(
        tester,
        api: FakeApi(
          events: [
            fakeEvent(),
            fakeEvent(id: 'e2', title: 'Send-off', status: EventStatusEnum.draft),
          ],
        ),
      );
      await signIn(tester);
      expect(api.provisionCalls, 1);
      expect(api.listCalls, 1);
      expect(find.text('My events'), findsOneWidget);
      // The next event is the hero tile and also a row in the list.
      expect(find.byKey(const Key('dashboard.next')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('events.row.e1')), matching: find.text('Harusi ya Asha')), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);

      await signOut(tester);
      expect(find.text('Welcome to D-Card'), findsOneWidget);
      await signIn(tester);
      expect(api.provisionCalls, 1, reason: 'same user is provisioned only once');
    });
  });

  group('events', () {
    testWidgets('shows an empty state', (tester) async {
      await pumpApp(tester, api: FakeApi());
      await signIn(tester);
      expect(find.textContaining('No events yet'), findsOneWidget);
    });

    testWidgets('shows a network error with retry', (tester) async {
      final api = FakeApi(
        listError: ApiException.withInner(400, 'Socket operation failed', const SocketException('down'), null),
      );
      await pumpApp(tester, api: api);
      await signIn(tester);
      expect(find.text('No connection. Check your internet and try again.'), findsOneWidget);
      api
        ..listError = null
        ..events = [fakeEvent()];
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('events.row.e1')), findsOneWidget);
    });

    testWidgets('opens the event summary in Swahili', (tester) async {
      await pumpApp(tester, locale: 'sw');
      await signIn(tester);
      await tester.tap(find.text('Harusi ya Asha').first);
      await tester.pumpAndSettle();
      expect(find.text('Limechapishwa'), findsOneWidget);
      expect(find.textContaining('15:00'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Asha · 0754 123 456'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('Aina ya tukio'), findsOneWidget);
      expect(find.text('Harusi'), findsOneWidget);
      expect(find.text('Diamond Jubilee, Upanga, Dar es Salaam'), findsOneWidget);
      expect(find.text('Asha · 0754 123 456'), findsOneWidget);
    });
  });
}
