import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BrandHeader shows title and subtitle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DCardTheme.light(),
        home: const Scaffold(body: BrandHeader(title: 'D-Card', subtitle: 'Karibu')),
      ),
    );
    expect(find.text('D-Card'), findsOneWidget);
    expect(find.text('Karibu'), findsOneWidget);
  });
}
