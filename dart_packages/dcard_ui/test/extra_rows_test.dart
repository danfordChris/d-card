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

void main() {
  testWidgets('DcListRow shows title, subtitle and trailing and is tappable', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(DcListRow(
      title: 'Asha',
      subtitle: '0754 123 456',
      leading: const DcDateBlock(day: '12', month: 'Dec'),
      trailing: const DcBadge(label: 'Paid', tone: DcTone.success),
      onTap: () => taps++,
    )));
    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('0754 123 456'), findsOneWidget);
    expect(find.text('DEC'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    await tester.tap(find.text('Asha'));
    expect(taps, 1);
  });

  testWidgets('DcActionTile and DcSectionHeader render in dark mode', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(
      Column(children: [
        const DcSectionHeader(title: 'Your events'),
        DcActionTile(icon: HugeIcons.strokeRoundedUserGroup, label: 'Guests', onTap: () => taps++),
      ]),
      dark: true,
    ));
    expect(find.text('Your events'), findsOneWidget);
    await tester.tap(find.text('Guests'));
    expect(taps, 1);
    final material = tester.widget<Material>(find.ancestor(of: find.text('Guests'), matching: find.byType(Material)).first);
    expect(material.color, DcColors.dark.tile);
  });

  testWidgets('DcChoice marks the selected option for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(Column(children: [
      DcChoice(label: 'Kawaida', description: 'TSh 1,500', selected: true, onTap: () {}),
      DcChoice(label: 'Premium', selected: false, onTap: () {}),
    ])));
    expect(tester.getSemantics(find.text('Kawaida')), isSemantics(isSelected: true, isButton: true, isInMutuallyExclusiveGroup: true));
    final chosen = tester.widget<Material>(find.ancestor(of: find.text('Kawaida'), matching: find.byType(Material)).first);
    expect(chosen.color, DcColors.light.primary);
    handle.dispose();
  });

  testWidgets('DcField submits and shows a suffix', (tester) async {
    String? submitted;
    await tester.pumpWidget(_app(DcField(
      key: const Key('f'),
      label: 'Card link',
      onSubmitted: (v) => submitted = v,
      suffix: const SizedBox(key: Key('suffix'), width: 10),
    )));
    await tester.enterText(find.byKey(const Key('f')), 'abc');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submitted, 'abc');
    expect(find.byKey(const Key('suffix')), findsOneWidget);
  });
}
