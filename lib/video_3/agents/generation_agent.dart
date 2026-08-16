import 'dart:convert';
import 'package:googleai_dart/googleai_dart.dart';
import '../models/feature_plan.dart';
import '../models/generated_feature_code.dart';

/// Stage 2: Generation Agent
/// Takes the architectural FeaturePlan and user request, then generates complete, production-ready Flutter code via Gemini API.
class GenerationAgent {
  final String apiKey;
  final String modelName;

  GenerationAgent({
    required this.apiKey,
    this.modelName = 'gemini-3.1-flash-lite',
  });

  static const String _systemInstruction = '''
You are an expert Lead Flutter Engineer.
Your task is to take an Architectural Feature Plan and write production-ready, clean, well-formatted Flutter Dart code.

You must respond ONLY with a valid JSON object matching this exact schema:
{
  "title": "String - Title of the generated feature code",
  "explanation": "String - Clear explanation of key implementation patterns and Dart features used",
  "flutterCode": "String - Complete, fully functioning, syntactically correct Flutter Widget Dart code",
  "dependencies": ["List of String - Required packages in pubspec.yaml (e.g. google_fonts, flutter_animate)"]
}
''';

  Future<GeneratedFeatureCode> generateCode({
    required String userPrompt,
    required FeaturePlan plan,
  }) async {
    if (apiKey.isEmpty) {
      throw StateError('Gemini API Key is missing. Please configure your API key before running the pipeline.');
    }

    final config = GoogleAIConfig(authProvider: ApiKeyProvider(apiKey));
    final client = GoogleAIClient(config: config);

    final promptInput = '''
User Feature Request:
$userPrompt

Architectural Plan:
${plan.toFormattedJson()}
''';

    final request = GenerateContentRequest(
      contents: [Content.text(promptInput)],
      systemInstruction: Content.text(_systemInstruction),
      generationConfig: const GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3,
      ),
    );

    final response = await client.models.generateContent(
      model: modelName,
      request: request,
    );

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Generation Agent returned empty response from Gemini API.');
    }

    final jsonMap = jsonDecode(text) as Map<String, dynamic>;
    return GeneratedFeatureCode.fromJson(jsonMap);
  }
}
