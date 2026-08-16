import 'dart:convert';

/// Structured schema for Stage 1: Planning Agent
class FeaturePlan {
  final String title;
  final String overview;
  final String targetPlatform;
  final List<String> componentsToBuild;
  final List<String> implementationSteps;
  final List<String> riskConsiderations;

  const FeaturePlan({
    required this.title,
    required this.overview,
    required this.targetPlatform,
    required this.componentsToBuild,
    required this.implementationSteps,
    required this.riskConsiderations,
  });

  factory FeaturePlan.fromJson(Map<String, dynamic> json) {
    return FeaturePlan(
      title: json['title'] as String? ?? 'Untitled Feature Plan',
      overview: json['overview'] as String? ?? '',
      targetPlatform: json['targetPlatform'] as String? ?? 'Flutter Cross-Platform',
      componentsToBuild: (json['componentsToBuild'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      implementationSteps: (json['implementationSteps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      riskConsiderations: (json['riskConsiderations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'overview': overview,
        'targetPlatform': targetPlatform,
        'componentsToBuild': componentsToBuild,
        'implementationSteps': implementationSteps,
        'riskConsiderations': riskConsiderations,
      };

  String toFormattedJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
