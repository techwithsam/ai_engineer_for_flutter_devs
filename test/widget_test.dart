import 'package:flutter_test/flutter_test.dart';
import 'package:smart_text_analyzer/main.dart';

void main() {
  testWidgets('Smart Text Analyzer App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartTextAnalyzerApp());

    // Verify that the title bar is present.
    expect(find.text('Smart Text Analyzer'), findsOneWidget);
  });
}
