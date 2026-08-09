import 'dart:convert';
import 'package:googleai_dart/googleai_dart.dart';
import '../models/text_analysis_models.dart';

/// GeminiService manages Cloud AI text summarization and insight extraction
/// using the community `googleai_dart` package.
///
/// Step 1: Service Layer Setup
/// 1. Initialize `GoogleAIClient` with `GoogleAIConfig` and `ApiKeyProvider`.
/// 2. Request structured JSON output for easy UI consumption.
/// 3. Safely parse and convert the response into a `GeminiInsight` model.
class GeminiService {
  final String apiKey;
  final String modelName;

  GeminiService({
    required this.apiKey,
    this.modelName = 'gemini-3.1-flash-lite',
  });

  /// Analyzes input text using Google Gemini AI via googleai_dart client.
  Future<GeminiInsight> analyzeText(String inputText) async {
    if (apiKey.trim().isEmpty) {
      throw Exception(
        'Gemini API Key is missing. Tap the key icon in the app bar to configure your key.',
      );
    }

    if (inputText.trim().isEmpty) {
      throw Exception('Input text cannot be empty.');
    }

    GoogleAIClient? client;
    try {
      // 1. Instantiate client using GoogleAIConfig and ApiKeyProvider from googleai_dart
      client = GoogleAIClient(
        config: GoogleAIConfig(
          authProvider: ApiKeyProvider(apiKey),
        ),
      );

      // 2. Format structured prompt for JSON output
      final prompt = '''
Analyze the following text and extract structured insights. Return ONLY a valid JSON object with:
- "summary": A concise 2-3 sentence summary of the key message.
- "keyInsights": A list of up to 4 main takeaways.
- "actionItems": A list of relevant action items or follow-ups suggested by the text (or empty list [] if none).
- "tone": The overall tone (e.g., Professional, Urgent, Enthusiastic, Frustrated, Informative).

Text to analyze:
"$inputText"
''';

      // 3. Send request to Gemini API via client.models.generateContent
      final response = await client.models.generateContent(
        model: modelName,
        request: GenerateContentRequest(
          contents: [
            Content(
              parts: [TextPart(prompt)],
              role: 'user',
            ),
          ],
        ),
      );

      // 4. Extract generated text from response candidate
      final candidate = response.candidates?.firstOrNull;
      final parts = candidate?.content?.parts ?? [];
      final rawText = parts
          .whereType<TextPart>()
          .map((p) => p.text)
          .join('\n');

      if (rawText.isEmpty) {
        throw Exception('Received an empty response from Gemini API.');
      }

      return _parseResponse(rawText);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gemini API Error: $e');
    } finally {
      client?.close();
    }
  }

  /// Helper method to safely parse JSON response from Gemini
  GeminiInsight _parseResponse(String rawText) {
    try {
      String cleanText = rawText.trim();

      // Clean markdown code blocks (e.g., ```json ... ```)
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.substring(7);
      } else if (cleanText.startsWith('```')) {
        cleanText = cleanText.substring(3);
      }
      if (cleanText.endsWith('```')) {
        cleanText = cleanText.substring(0, cleanText.length - 3);
      }
      cleanText = cleanText.trim();

      final decoded = jsonDecode(cleanText) as Map<String, dynamic>;

      return GeminiInsight(
        summary: decoded['summary'] as String? ?? 'Summary unavailable.',
        keyInsights: (decoded['keyInsights'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        actionItems: (decoded['actionItems'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        tone: decoded['tone'] as String? ?? 'Informative',
        rawResponse: rawText,
      );
    } catch (_) {
      // Fallback if model output wasn't strictly formatted JSON
      return GeminiInsight(
        summary: rawText,
        keyInsights: ['Extracted from freeform response'],
        actionItems: [],
        tone: 'Informative',
        rawResponse: rawText,
      );
    }
  }
}
