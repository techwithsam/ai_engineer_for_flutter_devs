import 'dart:convert';
import 'package:googleai_dart/googleai_dart.dart';
import '../models/feature_plan.dart';
import '../models/generated_feature_code.dart';
import '../models/validation_report.dart';

/// Stage 3: Validation Agent
/// Reviews generated code against the original user prompt and architectural plan via Gemini API.
class ValidationAgent {
  final String apiKey;
  final String modelName;

  ValidationAgent({
    required this.apiKey,
    this.modelName = 'gemini-3.1-flash-lite',
  });

  static const String _systemInstruction = '''
You are a Lead Code Auditor and Security Reviewer for Flutter applications.
Your job is to audit generated Flutter code against the user request and architectural plan.

You must evaluate code quality, completeness, error handling, accessibility, and performance.
You must respond ONLY with a valid JSON object matching this exact schema:
{
  "qualityScore": 92, // Integer between 0 and 100
  "isPassed": true, // Boolean - true if qualityScore >= 75
  "identifiedIssues": ["List of String - Specific flaws, missing validations, or anti-patterns"],
  "improvementSuggestions": ["List of String - Actionable code quality or performance recommendations"],
  "refinedCodeSnippet": "String or Null - Improved/corrected snippet fixing identified issues"
}
''';

  Future<ValidationReport> validateOutput({
    required String userPrompt,
    required FeaturePlan plan,
    required GeneratedFeatureCode generatedCode,
  }) async {
    if (apiKey.isEmpty) {
      throw StateError('Gemini API Key is missing. Please configure your API key before running the pipeline.');
    }

    final config = GoogleAIConfig(authProvider: ApiKeyProvider(apiKey));
    final client = GoogleAIClient(config: config);

    final promptInput = '''
Original Request:
$userPrompt

Architectural Plan:
${plan.toFormattedJson()}

Generated Code to Audit:
${generatedCode.toFormattedJson()}
''';

    final request = GenerateContentRequest(
      contents: [Content.text(promptInput)],
      systemInstruction: Content.text(_systemInstruction),
      generationConfig: const GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1,
      ),
    );

    final response = await client.models.generateContent(
      model: modelName,
      request: request,
    );

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Validation Agent returned empty response from Gemini API.');
    }

    final jsonMap = jsonDecode(text) as Map<String, dynamic>;
    return ValidationReport.fromJson(jsonMap);
  }
}
