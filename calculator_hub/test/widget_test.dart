import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_hub/app.dart';

void main() {
  testWidgets('Calculator screen renders primary controls', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Calculator Hub'), findsOneWidget);
    expect(find.text('AC'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });
}
