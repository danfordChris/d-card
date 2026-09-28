import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart' show openEvent, pumpApp;

/// The door follows the system theme (T08-03): check-in and result screens render with the
/// dark D-Card roles.
void main() {
  Future<void> useDark(WidgetTester tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  }

  Color fillOf(WidgetTester tester, Finder finder) {
    final box = tester.widget<DecoratedBox>(find.descendant(of: finder, matching: find.byType(DecoratedBox)).first);
    return (box.decoration as BoxDecoration).color!;
  }

  testWidgets('check-in screen renders in dark mode', (tester) async {
    await useDark(tester);
    await pumpApp(tester);
    await openEvent(tester);

    final context = tester.element(find.byKey(const Key('checkIn.modes')));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.dc, DcColors.dark);
    expect(tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        DcColors.dark.bg);
    expect(find.text('Harusi ya Asha'), findsOneWidget);
    expect(find.byKey(const Key('checkIn.walkIn')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('result screen renders its status tile in dark tones', (tester) async {
    await useDark(tester);
    await pumpApp(tester);
    await openEvent(tester);

    await tester.tap(find.byKey(const Key('scan.qr-inv-1')));
    await tester.pumpAndSettle();
    expect(find.text('Valid card'), findsOneWidget);
    expect(fillOf(tester, find.byKey(const Key('result.panel'))), DcColors.dark.successBg);
    expect(tester.widget<Text>(find.byKey(const Key('result.headline'))).style!.color, DcColors.dark.successFg);

    await tester.tap(find.byKey(const Key('result.next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scan.qr-used')));
    await tester.pumpAndSettle();
    expect(find.text('Card fully used'), findsOneWidget);
    expect(fillOf(tester, find.byKey(const Key('result.panel'))), DcColors.dark.dangerBg);
    expect(tester.takeException(), isNull);
  });
}
