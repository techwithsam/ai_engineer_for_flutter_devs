import 'package:flutter_test/flutter_test.dart';
import 'package:smart_text_analyzer/part_two_app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build Video 2 app and trigger a frame.
    await tester.pumpWidget(const PartTwoApp());

    // Verify that the title is present in the App Bar.
    expect(find.text('Reliable AI Studio'), findsOneWidget);
  });
}
