import 'package:dcard_mobile/data/repositories/theme_repository.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_test.dart' show pumpApp, signIn;
import 'fakes/fakes.dart';

/// The spotlight bar's tabs as screen readers see them, in order.
List<String> navLabels(WidgetTester tester) {
  final bar = find.byType(DcSpotlightNavBar);
  return [
    for (final e in find.descendant(of: bar, matching: find.byType(Semantics)).evaluate())
      if ((e.widget as Semantics).properties.button == true) (e.widget as Semantics).properties.label!,
  ];
}

bool isSelected(WidgetTester tester, String label) {
  final bar = find.byType(DcSpotlightNavBar);
  final tab = find
      .descendant(of: bar, matching: find.byType(Semantics))
      .evaluate()
      .map((e) => e.widget as Semantics)
      .firstWhere((s) => s.properties.label == label);
  return tab.properties.selected ?? false;
}

void main() {
  group('spotlight navigation', () {
    testWidgets('has five labelled tabs and opens each one', (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      expect(find.byType(DcSpotlightNavBar), findsOneWidget);
      expect(navLabels(tester), ['Home', 'My cards', 'New event', 'Notifications', 'Account']);
      expect(isSelected(tester, 'Home'), isTrue);
      expect(find.text('My events'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav.newEvent')));
      await tester.pumpAndSettle();
      expect(isSelected(tester, 'New event'), isTrue);
      expect(find.text('Create your event on the website'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav.notifications')));
      await tester.pumpAndSettle();
      expect(find.text('No notifications yet'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav.myCards')));
      await tester.pumpAndSettle();
      expect(isSelected(tester, 'My cards'), isTrue);

      await tester.tap(find.byKey(const Key('nav.account')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('account.signOut')), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav.home')));
      await tester.pumpAndSettle();
      expect(isSelected(tester, 'Home'), isTrue);
    });

    testWidgets('labels are Swahili and the dashboard New event tile opens the tab', (tester) async {
      await pumpApp(tester, locale: 'sw');
      await signIn(tester);
      expect(navLabels(tester), ['Nyumbani', 'Kadi zangu', 'Tukio jipya', 'Arifa', 'Akaunti']);
      final tile = find.byKey(const Key('dashboard.newEvent'));
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(isSelected(tester, 'Tukio jipya'), isTrue);
    });
  });

  group('theme setting', () {
    testWidgets('follows the system by default; Dark and Light are saved and applied', (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app().themeMode, ThemeMode.system);

      await tester.tap(find.byKey(const Key('nav.account')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(app().themeMode, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ThemeRepository.key), 'dark');
      expect(Theme.of(tester.element(find.text('Dark'))).extension<DcColors>()!.bg, DcColors.dark.bg);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(app().themeMode, ThemeMode.light);
      expect(prefs.getString(ThemeRepository.key), 'light');

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(app().themeMode, ThemeMode.system);
    });

    testWidgets('a saved choice is restored at start-up', (tester) async {
      await pumpApp(tester, prefsValues: {ThemeRepository.key: 'dark'});
      expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    });
  });

  testWidgets('dashboard renders in dark mode with the bento and event rows', (tester) async {
    await pumpApp(
      tester,
      prefsValues: {ThemeRepository.key: 'dark'},
      api: FakeApi(events: [fakeEvent(), fakeEvent(id: 'e2', title: 'Send-off')]),
    );
    await signIn(tester);
    expect(Theme.of(tester.element(find.text('My events'))).scaffoldBackgroundColor, DcColors.dark.bg);
    expect(find.byKey(const Key('dashboard.next')), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('You host'), findsOneWidget);
    expect(find.text('Cards paid'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('events.row.e2')));
    expect(find.byKey(const Key('events.row.e2')), findsOneWidget);
    final hero = tester.widget<Material>(
      find.descendant(of: find.byKey(const Key('dashboard.next')), matching: find.byType(Material)).first,
    );
    expect(hero.color, DcColors.dark.hero);
    final title = tester.widget<Text>(find.text('My events'));
    expect(title.style!.color, DcColors.dark.ink);
    expect(tester.takeException(), isNull);
  });
}
