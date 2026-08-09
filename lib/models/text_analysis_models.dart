class GeminiInsight {
  final String summary;
  final List<String> keyInsights;
  final List<String> actionItems;
  final String tone;
  final String rawResponse;

  GeminiInsight({
    required this.summary,
    required this.keyInsights,
    required this.actionItems,
    required this.tone,
    required this.rawResponse,
  });

  factory GeminiInsight.fromJson(Map<String, dynamic> json) {
    return GeminiInsight(
      summary: json['summary'] as String? ?? 'No summary available.',
      keyInsights: (json['keyInsights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tone: json['tone'] as String? ?? 'Informative',
      rawResponse: json['rawResponse'] as String? ?? '',
    );
  }
}

enum SentimentType { positive, neutral, negative }

class OnDeviceClassification {
  final String sentiment;
  final double sentimentScore;
  final String category;
  final double categoryConfidence;
  final List<String> keywordsDetected;
  final int inferenceTimeMs;
  final bool isFallback;

  OnDeviceClassification({
    required this.sentiment,
    required this.sentimentScore,
    required this.category,
    required this.categoryConfidence,
    required this.keywordsDetected,
    required this.inferenceTimeMs,
    this.isFallback = false,
  });

  SentimentType get sentimentType {
    final lower = sentiment.toLowerCase();
    if (lower.contains('pos')) return SentimentType.positive;
    if (lower.contains('neg')) return SentimentType.negative;
    return SentimentType.neutral;
  }
}

class TextAnalysisResult {
  final GeminiInsight? geminiInsight;
  final OnDeviceClassification? onDeviceClassification;
  final String? geminiError;
  final String? onDeviceError;
  final bool isGeminiLoading;
  final bool isOnDeviceLoading;

  TextAnalysisResult({
    this.geminiInsight,
    this.onDeviceClassification,
    this.geminiError,
    this.onDeviceError,
    this.isGeminiLoading = false,
    this.isOnDeviceLoading = false,
  });

  TextAnalysisResult copyWith({
    GeminiInsight? geminiInsight,
    OnDeviceClassification? onDeviceClassification,
    String? geminiError,
    String? onDeviceError,
    bool? isGeminiLoading,
    bool? isOnDeviceLoading,
    bool clearGeminiInsight = false,
    bool clearOnDeviceClassification = false,
    bool clearGeminiError = false,
    bool clearOnDeviceError = false,
  }) {
    return TextAnalysisResult(
      geminiInsight: clearGeminiInsight ? null : (geminiInsight ?? this.geminiInsight),
      onDeviceClassification: clearOnDeviceClassification
          ? null
          : (onDeviceClassification ?? this.onDeviceClassification),
      geminiError: clearGeminiError ? null : (geminiError ?? this.geminiError),
      onDeviceError: clearOnDeviceError ? null : (onDeviceError ?? this.onDeviceError),
      isGeminiLoading: isGeminiLoading ?? this.isGeminiLoading,
      isOnDeviceLoading: isOnDeviceLoading ?? this.isOnDeviceLoading,
    );
  }
}
