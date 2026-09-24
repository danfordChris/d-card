import 'package:dcard_door/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the English home screen', (tester) async {
    await tester.pumpWidget(const DCardApp(locale: Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Door check-in'), findsOneWidget);
    expect(find.text('Scan cards to admit guests'), findsOneWidget);
  });

  testWidgets('shows the Swahili home screen', (tester) async {
    await tester.pumpWidget(const DCardApp(locale: Locale('sw')));
    await tester.pumpAndSettle();
    expect(find.text('Ukaguzi mlangoni'), findsOneWidget);
    expect(find.text('Scan kadi kuwaruhusu wageni kuingia'), findsOneWidget);
  });
}
