import 'dart:convert';
import 'package:googleai_dart/googleai_dart.dart';
import '../models/feature_plan.dart';

/// Stage 1: Planning Agent
/// Takes raw user feature requests and converts them into a structured architectural plan via Gemini API.
class PlanningAgent {
  final String apiKey;
  final String modelName;

  PlanningAgent({
    required this.apiKey,
    this.modelName = 'gemini-3.1-flash-lite',
  });

  static const String _systemInstruction = '''
You are a Senior Flutter Software Architect.
Your role is to take a high-level mobile/web feature request and generate a clean, structured architectural plan.

You must respond ONLY with a valid JSON object matching this exact schema:
{
  "title": "String - Concise title of the feature plan",
  "overview": "String - Executive summary of the architectural strategy",
  "targetPlatform": "String - Target platforms (e.g. Flutter Web, iOS & Android)",
  "componentsToBuild": ["List of String - Individual UI components, widgets, or services to build"],
  "implementationSteps": ["List of String - Sequential step-by-step engineering tasks"],
  "riskConsiderations": ["List of String - Potential state management, security, performance or edge case risks"]
}
''';

  Future<FeaturePlan> planFeature(String prompt) async {
    if (apiKey.isEmpty) {
      throw StateError('Gemini API Key is missing. Please configure your API key before running the pipeline.');
    }

    final config = GoogleAIConfig(authProvider: ApiKeyProvider(apiKey));
    final client = GoogleAIClient(config: config);

    final request = GenerateContentRequest(
      contents: [Content.text('Feature Request:\n$prompt')],
      systemInstruction: Content.text(_systemInstruction),
      generationConfig: const GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2,
      ),
    );

    final response = await client.models.generateContent(
      model: modelName,
      request: request,
    );

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Planning Agent returned empty response from Gemini API.');
    }

    final jsonMap = jsonDecode(text) as Map<String, dynamic>;
    return FeaturePlan.fromJson(jsonMap);
  }
}
