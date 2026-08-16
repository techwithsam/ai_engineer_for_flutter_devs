import 'dart:convert';

/// Structured schema for Stage 2: Generation Agent
class GeneratedFeatureCode {
  final String title;
  final String explanation;
  final String flutterCode;
  final List<String> dependencies;

  const GeneratedFeatureCode({
    required this.title,
    required this.explanation,
    required this.flutterCode,
    required this.dependencies,
  });

  factory GeneratedFeatureCode.fromJson(Map<String, dynamic> json) {
    return GeneratedFeatureCode(
      title: json['title'] as String? ?? 'Generated Feature Output',
      explanation: json['explanation'] as String? ?? '',
      flutterCode: json['flutterCode'] as String? ?? '// No code generated',
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'explanation': explanation,
        'flutterCode': flutterCode,
        'dependencies': dependencies,
      };

  String toFormattedJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
