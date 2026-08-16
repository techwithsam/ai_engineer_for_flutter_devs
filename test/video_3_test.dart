import 'package:flutter_test/flutter_test.dart';
import 'package:smart_text_analyzer/video_3/agents/planning_agent.dart';
import 'package:smart_text_analyzer/video_3/video_3_app.dart';

void main() {
  test('PlanningAgent throws StateError when API key is missing', () async {
    final agent = PlanningAgent(apiKey: '');
    expect(
      () => agent.planFeature('Create a login screen'),
      throwsA(isA<StateError>()),
    );
  });

  testWidgets('Video 3 App smoke test renders studio UI', (WidgetTester tester) async {
    await tester.pumpWidget(const Video3App());
    expect(find.text('Smart Feature Builder (Video 3)'), findsOneWidget);
    expect(find.text('Run Multi-Agent Pipeline'), findsOneWidget);
  });
}
