import 'ai_exceptions.dart';

/// Strongly-typed Dart model representing a Structured Output JSON response from Gemini.
class ArticleBlueprint {
  final String title;
  final String overview;
  final String difficulty;
  final int estimatedReadingMinutes;
  final List<String> tags;
  final List<String> keyConcepts;
  final List<String> implementationSteps;
  final String? codeSnippet;

  const ArticleBlueprint({
    required this.title,
    required this.overview,
    required this.difficulty,
    required this.estimatedReadingMinutes,
    required this.tags,
    required this.keyConcepts,
    required this.implementationSteps,
    this.codeSnippet,
  });

  /// Safely deserializes JSON map into an [ArticleBlueprint].
  /// Throws [SchemaParsingAIException] if mandatory fields cannot be parsed.
  factory ArticleBlueprint.fromJson(Map<String, dynamic> json, String rawText) {
    try {
      final title = json['title'] as String?;
      final overview = json['overview'] as String?;

      if (title == null || title.trim().isEmpty) {
        throw SchemaParsingAIException(
          'Missing mandatory "title" field in Structured Output response.',
          rawOutput: rawText,
        );
      }

      return ArticleBlueprint(
        title: title,
        overview: overview ?? 'No overview provided.',
        difficulty: json['difficulty'] as String? ?? 'Intermediate',
        estimatedReadingMinutes: (json['estimatedReadingMinutes'] as num?)?.toInt() ?? 5,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        keyConcepts: (json['keyConcepts'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        implementationSteps: (json['implementationSteps'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        codeSnippet: json['codeSnippet'] as String?,
      );
    } catch (e) {
      if (e is SchemaParsingAIException) rethrow;
      throw SchemaParsingAIException(
        'Failed to parse Structured Output JSON: $e',
        rawOutput: rawText,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'overview': overview,
      'difficulty': difficulty,
      'estimatedReadingMinutes': estimatedReadingMinutes,
      'tags': tags,
      'keyConcepts': keyConcepts,
      'implementationSteps': implementationSteps,
      if (codeSnippet != null) 'codeSnippet': codeSnippet,
    };
  }
}
