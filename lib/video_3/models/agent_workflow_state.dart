import 'feature_plan.dart';
import 'generated_feature_code.dart';
import 'validation_report.dart';

enum AgentStage {
  idle,
  planning,
  generating,
  validating,
  completed,
  failed,
}

class AgentLogEntry {
  final DateTime timestamp;
  final String agentName;
  final String message;
  final String? rawPayload;

  const AgentLogEntry({
    required this.timestamp,
    required this.agentName,
    required this.message,
    this.rawPayload,
  });
}

class AgentWorkflowState {
  final AgentStage stage;
  final String userPrompt;
  final FeaturePlan? plan;
  final GeneratedFeatureCode? generatedCode;
  final ValidationReport? validationReport;
  final Object? error;
  final List<AgentLogEntry> logs;
  final Duration elapsedDuration;

  const AgentWorkflowState({
    this.stage = AgentStage.idle,
    this.userPrompt = '',
    this.plan,
    this.generatedCode,
    this.validationReport,
    this.error,
    this.logs = const [],
    this.elapsedDuration = Duration.zero,
  });

  AgentWorkflowState copyWith({
    AgentStage? stage,
    String? userPrompt,
    FeaturePlan? plan,
    GeneratedFeatureCode? generatedCode,
    ValidationReport? validationReport,
    Object? error,
    bool clearError = false,
    List<AgentLogEntry>? logs,
    Duration? elapsedDuration,
  }) {
    return AgentWorkflowState(
      stage: stage ?? this.stage,
      userPrompt: userPrompt ?? this.userPrompt,
      plan: plan ?? this.plan,
      generatedCode: generatedCode ?? this.generatedCode,
      validationReport: validationReport ?? this.validationReport,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
    );
  }
}
