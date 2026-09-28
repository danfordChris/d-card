import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

Widget _app(Widget child, {bool dark = false}) => MaterialApp(
      theme: DcTheme.light(),
      darkTheme: DcTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: ListView(children: [child])),
    );

Color _fillOf(WidgetTester tester, Finder tile) {
  final box = tester.widget<DecoratedBox>(find.descendant(of: tile, matching: find.byType(DecoratedBox)).first);
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  group('DcStatusTile', () {
    testWidgets('uses the tone colours in light and dark and inverts them for the disc', (tester) async {
      for (final dark in [false, true]) {
        final c = dark ? DcColors.dark : DcColors.light;
        await tester.pumpWidget(_app(
          const DcStatusTile(
            key: Key('tile'),
            tone: DcTone.success,
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            title: 'Admit 2',
            message: 'Double card',
            titleKey: Key('title'),
          ),
          dark: dark,
        ));
        await tester.pumpAndSettle();
        expect(_fillOf(tester, find.byKey(const Key('tile'))), c.successBg);
        expect(tester.widget<Text>(find.byKey(const Key('title'))).style!.color, c.successFg);
        expect(tester.widget<Text>(find.byKey(const Key('title'))).style!.fontFamily, 'packages/dcard_ui/PlayfairDisplay');
        expect(find.text('Double card'), findsOneWidget);
      }
      expect(dcStatusColors(DcColors.light, DcTone.danger), (
        DcColors.light.dangerBg,
        DcColors.light.dangerFg,
        DcColors.light.dangerFg,
        DcColors.light.dangerBg,
      ));
    });

    testWidgets('busy shows a progress ring instead of the icon and is a live region', (tester) async {
      await tester.pumpWidget(_app(
        const DcStatusTile(tone: DcTone.warning, icon: HugeIcons.strokeRoundedClock01, title: 'Waiting', busy: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HugeIcon), findsNothing);
      final semantics = tester.getSemantics(find.text('Waiting'));
      expect(semantics, isNotNull);
      expect(
        find.byWidgetPredicate((w) => w is Semantics && (w.properties.liveRegion ?? false)),
        findsOneWidget,
      );
    });
  });

  group('DcNoticeTile', () {
    testWidgets('shows title, message and trailing on the tone background', (tester) async {
      await tester.pumpWidget(_app(
        const DcNoticeTile(
          tone: DcTone.warning,
          title: 'Locked',
          message: 'Try again soon',
          trailing: Text('4:59'),
        ),
        dark: true,
      ));
      expect(find.text('Locked'), findsOneWidget);
      expect(find.text('Try again soon'), findsOneWidget);
      expect(find.text('4:59'), findsOneWidget);
      final material = tester.widget<Material>(
        find.ancestor(of: find.text('Locked'), matching: find.byType(Material)).first,
      );
      expect(material.color, DcColors.dark.warningBg);
    });

    testWidgets('is tappable when onTap is set', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(DcNoticeTile(tone: DcTone.danger, message: 'Retry', onTap: () => taps++)));
      await tester.tap(find.text('Retry'));
      expect(taps, 1);
    });
  });
}
