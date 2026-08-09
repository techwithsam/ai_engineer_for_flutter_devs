import 'dart:convert';
import 'package:googleai_dart/googleai_dart.dart';

import '../models/ai_exceptions.dart';
import '../models/article_blueprint.dart';
import 'retry_helper.dart';

/// Resilient AI Service demonstrating Structured Output, Streaming, & Error Resilience.
///
/// Core Service Layer
class ResilientAIService {
  final String apiKey;
  final String modelName;

  ResilientAIService({
    required this.apiKey,
    this.modelName = 'gemini-3.1-flash-lite',
  });

  /// PILLAR 1 & 3: Structured Output with Exponential Backoff Retries.
  ///
  /// Forces Gemini to return structured JSON adhering to the [ArticleBlueprint] schema,
  /// with automatic retries on transient network/rate-limit failures.
  Future<ArticleBlueprint> generateStructuredBlueprint(
    String topicPrompt, {
    void Function(int attempt, Duration delay, Exception error)? onRetry,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const InvalidApiKeyAIException(
        'Gemini API Key is missing. Please configure your key in the app settings.',
      );
    }

    if (topicPrompt.trim().isEmpty) {
      throw const UnknownAIException('Prompt cannot be empty.');
    }

    return RetryHelper.retryWithBackoff<ArticleBlueprint>(
      onRetry: onRetry,
      maxAttempts: 3,
      action: () async {
        GoogleAIClient? client;
        try {
          // 1. Initialize client using googleai_dart
          client = GoogleAIClient(
            config: GoogleAIConfig(
              authProvider: ApiKeyProvider(apiKey),
            ),
          );

          // 2. Build Structured JSON prompt enforcing strict schema
          final systemPrompt = '''
You are a technical content architect. Generate a structured JSON blueprint for a technical article or feature guide.

STRICT JSON SCHEMA REQUIREMENT:
Return ONLY a valid JSON object with the following fields:
- "title": String (compelling article title)
- "overview": String (concise 2-3 sentence overview)
- "difficulty": String ("Beginner", "Intermediate", or "Advanced")
- "estimatedReadingMinutes": Integer
- "tags": Array of Strings
- "keyConcepts": Array of Strings (up to 4 bullet points)
- "implementationSteps": Array of Strings (step-by-step implementation guide)
- "codeSnippet": String (short code example)

Topic to generate blueprint for:
"$topicPrompt"
''';

          // 3. Make API request using client.models.generateContent
          final response = await client.models.generateContent(
            model: modelName,
            request: GenerateContentRequest(
              contents: [
                Content(
                  parts: [TextPart(systemPrompt)],
                  role: 'user',
                ),
              ],
            ),
          );

          // 4. Extract generated text payload
          final candidate = response.candidates?.firstOrNull;
          if (candidate?.finishReason == FinishReason.safety ||
              candidate?.finishReason?.name.toLowerCase() == 'safety') {
            throw const SafetyRefusalAIException(
              'The requested topic was flagged by Gemini safety filters.',
            );
          }

          final parts = candidate?.content?.parts ?? [];
          final rawText = parts
              .whereType<TextPart>()
              .map((p) => p.text)
              .join('\n');

          if (rawText.isEmpty) {
            throw const SchemaParsingAIException(
              'Received empty output from Gemini model.',
              rawOutput: '',
            );
          }

          // 5. Clean markdown code blocks & parse JSON
          final cleanJsonText = _cleanMarkdownJson(rawText);
          final jsonMap = jsonDecode(cleanJsonText) as Map<String, dynamic>;

          // 6. Deserialize into strongly-typed Dart model
          return ArticleBlueprint.fromJson(jsonMap, rawText);
        } catch (e) {
          throw _translateException(e);
        } finally {
          client?.close();
        }
      },
    );
  }

  /// PILLAR 2: Token Streaming (`streamGenerateContent`).
  ///
  /// Yields incremental text tokens as they arrive from Gemini in real-time.
  Stream<String> streamTextContent(String prompt) async* {
    if (apiKey.trim().isEmpty) {
      throw const InvalidApiKeyAIException(
        'Gemini API Key is missing. Please configure your key in settings.',
      );
    }

    GoogleAIClient? client;
    try {
      client = GoogleAIClient(
        config: GoogleAIConfig(
          authProvider: ApiKeyProvider(apiKey),
        ),
      );

      final stream = client.models.streamGenerateContent(
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

      await for (final response in stream) {
        final candidate = response.candidates?.firstOrNull;
        final parts = candidate?.content?.parts ?? [];
        final token = parts
            .whereType<TextPart>()
            .map((p) => p.text)
            .join();

        if (token.isNotEmpty) {
          yield token;
        }
      }
    } catch (e) {
      throw _translateException(e);
    } finally {
      client?.close();
    }
  }

  /// PILLAR 3 DEMO HELPER: Simulates intentional fault cases.
  Future<ArticleBlueprint> simulateFault(String faultType) async {
    await Future.delayed(const Duration(milliseconds: 600));

    switch (faultType) {
      case '429_rate_limit':
        throw const RateLimitAIException(
          'HTTP 429: Too Many Requests. Gemini rate limit reached.',
          retryAfter: Duration(seconds: 5),
        );
      case 'network_timeout':
        throw const NetworkAIException(
          'SocketException: Connection timed out while reaching api.generativeai.google',
        );
      case 'schema_invalid':
        throw const SchemaParsingAIException(
          'FormatException: Missing mandatory "title" key in JSON payload.',
          rawOutput: '{"overview": "Broken JSON example without title"}',
        );
      case 'safety_refusal':
        throw const SafetyRefusalAIException(
          'Prompt blocked by Gemini Safety Classifier Policy.',
        );
      default:
        throw const UnknownAIException('Simulated unknown exception.');
    }
  }

  /// Helper to remove markdown ```json code wrappers
  String _cleanMarkdownJson(String raw) {
    String clean = raw.trim();
    if (clean.startsWith('```json')) {
      clean = clean.substring(7);
    } else if (clean.startsWith('```')) {
      clean = clean.substring(3);
    }
    if (clean.endsWith('```')) {
      clean = clean.substring(0, clean.length - 3);
    }
    return clean.trim();
  }

  /// Converts raw exceptions into categorized [AIException] instances.
  Exception _translateException(Object e) {
    if (e is AIException) return e;

    final errStr = e.toString().toLowerCase();
    if (errStr.contains('429') || errStr.contains('quota') || errStr.contains('rate')) {
      return RateLimitAIException('Rate limit exceeded: $e');
    }
    if (errStr.contains('socket') || errStr.contains('network') || errStr.contains('timeout')) {
      return NetworkAIException('Network connection failed: $e');
    }
    if (errStr.contains('401') || errStr.contains('unauthorized') || errStr.contains('key')) {
      return InvalidApiKeyAIException('API Key rejected or invalid: $e');
    }
    if (e is FormatException) {
      return SchemaParsingAIException('JSON parsing error: $e', rawOutput: e.toString());
    }

    return UnknownAIException(e.toString());
  }
}
