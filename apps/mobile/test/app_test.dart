import 'package:dcard_mobile/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the English home screen', (tester) async {
    await tester.pumpWidget(const DCardApp(locale: Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to D-Card'), findsOneWidget);
    expect(find.text('Your digital invitation cards'), findsOneWidget);
  });

  testWidgets('shows the Swahili home screen', (tester) async {
    await tester.pumpWidget(const DCardApp(locale: Locale('sw')));
    await tester.pumpAndSettle();
    expect(find.text('Karibu D-Card'), findsOneWidget);
    expect(find.text('Kadi zako za mwaliko za kidigitali'), findsOneWidget);
  });
}
