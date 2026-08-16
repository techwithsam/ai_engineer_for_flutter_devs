import 'dart:async';
import 'package:flutter/foundation.dart';

import '../agents/generation_agent.dart';
import '../agents/planning_agent.dart';
import '../agents/validation_agent.dart';
import '../models/agent_workflow_state.dart';

/// Orchestrator Service
/// Coordinates the multi-agent pipeline: Planning -> Generation -> Validation
class AgentOrchestrationService extends ValueNotifier<AgentWorkflowState> {
  Timer? _tickerTimer;
  DateTime? _startTime;

  AgentOrchestrationService() : super(const AgentWorkflowState());

  void reset() {
    _tickerTimer?.cancel();
    value = const AgentWorkflowState();
  }

  void _addLog(String agentName, String message, {String? payload}) {
    final newEntry = AgentLogEntry(
      timestamp: DateTime.now(),
      agentName: agentName,
      message: message,
      rawPayload: payload,
    );
    value = value.copyWith(
      logs: [...value.logs, newEntry],
    );
  }

  Future<void> runWorkflow(String prompt, {required String apiKey}) async {
    if (prompt.trim().isEmpty) return;

    if (apiKey.trim().isEmpty) {
      value = value.copyWith(
        stage: AgentStage.failed,
        error: 'Gemini API Key is missing. Please tap the key icon to configure your API key.',
      );
      return;
    }

    _tickerTimer?.cancel();
    _startTime = DateTime.now();

    value = AgentWorkflowState(
      stage: AgentStage.planning,
      userPrompt: prompt,
      elapsedDuration: Duration.zero,
    );

    _tickerTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_startTime != null) {
        value = value.copyWith(
          elapsedDuration: DateTime.now().difference(_startTime!),
        );
      }
    });

    _addLog('Orchestrator', 'Workflow started for prompt: "$prompt"');

    try {
      // -----------------------------------------------------------------------
      // STAGE 1: Planning Agent
      // -----------------------------------------------------------------------
      _addLog('Planning Agent', 'Analyzing request & composing architectural plan...');
      final planningAgent = PlanningAgent(apiKey: apiKey);
      final plan = await planningAgent.planFeature(prompt);

      value = value.copyWith(
        stage: AgentStage.generating,
        plan: plan,
      );
      _addLog('Planning Agent', 'Plan generated successfully: "${plan.title}"', payload: plan.toFormattedJson());

      // -----------------------------------------------------------------------
      // STAGE 2: Generation Agent
      // -----------------------------------------------------------------------
      _addLog('Generation Agent', 'Writing Flutter code & module dependencies...');
      final generationAgent = GenerationAgent(apiKey: apiKey);
      final generatedCode = await generationAgent.generateCode(
        userPrompt: prompt,
        plan: plan,
      );

      value = value.copyWith(
        stage: AgentStage.validating,
        generatedCode: generatedCode,
      );
      _addLog('Generation Agent', 'Code generated successfully (${generatedCode.flutterCode.length} chars)', payload: generatedCode.toFormattedJson());

      // -----------------------------------------------------------------------
      // STAGE 3: Validation Agent
      // -----------------------------------------------------------------------
      _addLog('Validation Agent', 'Auditing code quality, security & accessibility...');
      final validationAgent = ValidationAgent(apiKey: apiKey);
      final validationReport = await validationAgent.validateOutput(
        userPrompt: prompt,
        plan: plan,
        generatedCode: generatedCode,
      );

      _tickerTimer?.cancel();

      value = value.copyWith(
        stage: AgentStage.completed,
        validationReport: validationReport,
      );
      _addLog('Validation Agent', 'Audit complete. Quality Score: ${validationReport.qualityScore}/100 (Passed: ${validationReport.isPassed})', payload: validationReport.toFormattedJson());
      _addLog('Orchestrator', 'Multi-Agent pipeline executed successfully!');
    } catch (e) {
      _tickerTimer?.cancel();
      _addLog('Orchestrator', 'Pipeline failed: $e');
      value = value.copyWith(
        stage: AgentStage.failed,
        error: e,
      );
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
