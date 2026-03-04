import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_hub/main.dart';

void main() {
  testWidgets('Productivity Hub renders', (tester) async {
    await tester.pumpWidget(const ProductivityHubApp());

    expect(find.text('Productivity Hub'), findsOneWidget);
    expect(find.text('Tasks'), findsAtLeastNWidgets(1));
    expect(find.text('Notes'), findsAtLeastNWidgets(1));
  });
}
