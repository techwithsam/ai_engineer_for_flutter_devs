import 'dart:convert';

/// Structured schema for Stage 3: Validation Agent
class ValidationReport {
  final int qualityScore;
  final bool isPassed;
  final List<String> identifiedIssues;
  final List<String> improvementSuggestions;
  final String? refinedCodeSnippet;

  const ValidationReport({
    required this.qualityScore,
    required this.isPassed,
    required this.identifiedIssues,
    required this.improvementSuggestions,
    this.refinedCodeSnippet,
  });

  factory ValidationReport.fromJson(Map<String, dynamic> json) {
    return ValidationReport(
      qualityScore: (json['qualityScore'] as num?)?.toInt() ?? 80,
      isPassed: json['isPassed'] as bool? ?? true,
      identifiedIssues: (json['identifiedIssues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      improvementSuggestions: (json['improvementSuggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      refinedCodeSnippet: json['refinedCodeSnippet'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'qualityScore': qualityScore,
        'isPassed': isPassed,
        'identifiedIssues': identifiedIssues,
        'improvementSuggestions': improvementSuggestions,
        if (refinedCodeSnippet != null) 'refinedCodeSnippet': refinedCodeSnippet,
      };

  String toFormattedJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
