import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

Widget _app(Widget child, {bool dark = false}) => MaterialApp(
      theme: DcTheme.light(),
      darkTheme: DcTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    );

void main() {
  group('tokens and theme', () {
    test('light and dark carry the colour roles from the design doc', () {
      expect(DcTheme.light().extension<DcColors>()!.primary, const Color(0xFF5A2D82));
      expect(DcTheme.dark().extension<DcColors>()!.bg, const Color(0xFF110D16));
      expect(DcTheme.light().scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    });

    test('text styles use the bundled fonts with an explicit weight axis', () {
      final h = DcType.heading(30);
      expect(h.fontFamily, 'packages/dcard_ui/PlayfairDisplay');
      expect(h.fontVariations!.single.value, 700);
      expect(DcType.ui(14).fontFamily, 'packages/dcard_ui/PlusJakartaSans');
      expect(DcTheme.light().textTheme.labelLarge!.fontFamily, 'packages/dcard_ui/PlusJakartaSans');
    });

    test('status tones map to their colours', () {
      final c = DcColors.light;
      expect(c.tone(DcTone.success), (c.successBg, c.successFg));
      expect(c.tone(DcTone.danger), (c.dangerBg, c.dangerFg));
    });

    test('lerp between themes stays within the roles', () {
      final mid = DcColors.light.lerp(DcColors.dark, 0.5);
      expect(mid.primary, Color.lerp(DcColors.light.primary, DcColors.dark.primary, 0.5));
    });
  });

  group('components', () {
    for (final dark in [false, true]) {
      testWidgets('tiles, stats, badge and progress render (${dark ? 'dark' : 'light'})', (tester) async {
        await tester.pumpWidget(_app(
          ListView(children: const [
            DcBento(items: [
              DcBentoItem(DcStatTile(label: 'Collected', value: '6.4M', note: 'of TSh 9M', progress: 0.71, variant: DcTileVariant.hero), span: 2),
              DcBentoItem(DcStatTile(label: 'Confirmed', value: '118', variant: DcTileVariant.soft)),
              DcBentoItem(DcStatTile(label: 'Cards', value: '312')),
              DcBentoItem(DcTile(child: Text('Alone'))),
            ]),
            DcBadge(label: 'Issued', tone: DcTone.success),
          ]),
          dark: dark,
        ));
        expect(find.text('6.4M'), findsOneWidget);
        expect(find.text('Issued'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tappable tile is one button', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(DcTile(onTap: () => taps++, semanticLabel: 'Open event', child: const Text('Asha & Juma'))));
      await tester.tap(find.text('Asha & Juma'));
      expect(taps, 1);
      expect(find.bySemanticsLabel(RegExp('Open event')), findsOneWidget);
    });

    testWidgets('button shows a spinner while loading and ignores taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(Column(children: [
        DcButton(label: 'Pay', onPressed: () => taps++, icon: HugeIcons.strokeRoundedMoney03),
        DcButton(label: 'Saving', onPressed: () => taps++, loading: true),
      ])));
      await tester.tap(find.text('Pay'));
      expect(taps, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(CircularProgressIndicator));
      expect(taps, 1);
    });

    testWidgets('field shows its label above the input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_app(DcField(label: 'Phone', hint: '0754 123 456', controller: controller)));
      expect(find.text('Phone'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '0713000001');
      expect(controller.text, '0713000001');
    });

    testWidgets('segmented control switches', (tester) async {
      var value = 'scan';
      await tester.pumpWidget(_app(StatefulBuilder(
        builder: (context, setState) => DcSegmented<String>(
          segments: const [DcSegment(value: 'scan', label: 'Scan'), DcSegment(value: 'number', label: 'Number'), DcSegment(value: 'name', label: 'Name')],
          selected: value,
          onChanged: (v) => setState(() => value = v),
        ),
      )));
      await tester.tap(find.text('Number'));
      await tester.pump();
      expect(value, 'number');
    });

    for (final dark in [false, true]) {
      testWidgets('spotlight nav bar: labelled tabs, active tab has strip and glow (${dark ? 'dark' : 'light'})', (tester) async {
        var index = 0;
        await tester.pumpWidget(_app(
          StatefulBuilder(
            builder: (context, setState) => Align(
              alignment: Alignment.bottomCenter,
              child: DcSpotlightNavBar(
                items: const [
                  DcNavItem(icon: HugeIcons.strokeRoundedHome01, label: 'Home'),
                  DcNavItem(icon: HugeIcons.strokeRoundedTicket01, label: 'My cards'),
                  DcNavItem(icon: HugeIcons.strokeRoundedAddCircle, label: 'New event'),
                  DcNavItem(icon: HugeIcons.strokeRoundedNotification01, label: 'Notifications'),
                  DcNavItem(icon: HugeIcons.strokeRoundedUser, label: 'Account'),
                ],
                currentIndex: index,
                onTap: (i) => setState(() => index = i),
              ),
            ),
          ),
          dark: dark,
        ));
        expect(find.bySemanticsLabel('Home'), findsOneWidget);
        expect(find.byType(ImageFiltered), findsOneWidget); // glow only on the active tab
        await tester.tap(find.bySemanticsLabel('Account'));
        await tester.pump();
        expect(index, 4);
        expect(find.byType(ImageFiltered), findsOneWidget);
      });
    }

    testWidgets('state view offers retry on error', (tester) async {
      var retried = false;
      await tester.pumpWidget(_app(DcStateView(kind: DcStateKind.error, title: 'Could not load', message: 'Check your connection.', actionLabel: 'Try again', onAction: () => retried = true)));
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('top bar shows back only when it can go back', (tester) async {
      await tester.pumpWidget(_app(const DcTopBar(title: 'Guests')));
      expect(find.text('Guests'), findsOneWidget);
      expect(find.bySemanticsLabel('Back'), findsNothing);
      await tester.pumpWidget(_app(DcTopBar(title: 'Guests', onBack: () {})));
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
    });
  });
}
