import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/api_key_dialog.dart';
import 'models/agent_workflow_state.dart';
import 'services/agent_orchestrator.dart';
import 'widgets/agent_telemetry_sheet.dart';
import 'widgets/agent_workflow_stepper.dart';
import 'widgets/code_output_card.dart';
import 'widgets/plan_summary_card.dart';
import 'widgets/validation_report_card.dart';

/// Video 3 App Entry Point - AI Agents & Workflows in Flutter
class Video3App extends StatelessWidget {
  const Video3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Engineering Video 3 - AI Agents & Workflows',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      home: const Video3StudioScreen(),
    );
  }
}

class Video3StudioScreen extends StatefulWidget {
  const Video3StudioScreen({super.key});

  @override
  State<Video3StudioScreen> createState() => _Video3StudioScreenState();
}

class _Video3StudioScreenState extends State<Video3StudioScreen> {
  final TextEditingController _promptController = TextEditingController(
    text: 'Create a clean Flutter login screen with email and password validation',
  );

  String _geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  final AgentOrchestrationService _orchestrator = AgentOrchestrationService();

  final List<String> _samplePresets = const [
    'Create a clean Flutter login screen with email and password validation',
    'Build an animated counter widget with smooth scale easing',
    'Design an e-commerce product card with dark mode & badge highlights',
    'Build a settings page with dark theme toggle and profile info',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _orchestrator.dispose();
    super.dispose();
  }

  Future<void> _configureApiKey() async {
    final newKey = await showDialog<String>(
      context: context,
      builder: (context) => ApiKeyDialog(currentApiKey: _geminiApiKey),
    );

    if (newKey != null) {
      setState(() {
        _geminiApiKey = newKey.trim();
      });
    }
  }

  void _runPipeline() async {
    FocusScope.of(context).unfocus();
    if (_geminiApiKey.isEmpty) {
      final newKey = await showDialog<String>(
        context: context,
        builder: (context) => ApiKeyDialog(currentApiKey: _geminiApiKey),
      );
      if (newKey == null || newKey.trim().isEmpty) return;
      setState(() {
        _geminiApiKey = newKey.trim();
      });
    }
    _orchestrator.runWorkflow(
      _promptController.text,
      apiKey: _geminiApiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<AgentWorkflowState>(
      valueListenable: _orchestrator,
      builder: (context, state, _) {
        final isRunning = state.stage == AgentStage.planning ||
            state.stage == AgentStage.generating ||
            state.stage == AgentStage.validating;

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.hub_outlined, color: AppTheme.xBlue, size: 24),
                SizedBox(width: 10),
                Text(
                  'Smart Feature Builder (Video 3)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'View Inter-Agent Telemetry Logs',
                icon: Badge(
                  label: Text('${state.logs.length}'),
                  isLabelVisible: state.logs.isNotEmpty,
                  child: const Icon(Icons.terminal_rounded),
                ),
                onPressed: () => AgentTelemetrySheet.show(context, state.logs),
              ),
              IconButton(
                tooltip: _geminiApiKey.isEmpty ? 'Set Gemini API Key' : 'API Key Configured',
                icon: Icon(
                  _geminiApiKey.isEmpty ? Icons.vpn_key_outlined : Icons.vpn_key_rounded,
                  color: _geminiApiKey.isEmpty ? AppTheme.xWarningYellow : AppTheme.xSuccessGreen,
                ),
                onPressed: _configureApiKey,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Banner
                    _buildHeaderBanner(isDark),

                    const SizedBox(height: 16),

                    // Prompt Input Section
                    _buildInputSection(isDark, isRunning),

                    const SizedBox(height: 16),

                    // Live Stepper Timeline
                    AgentWorkflowStepper(
                      stage: state.stage,
                      elapsedDuration: state.elapsedDuration,
                    ),

                    const SizedBox(height: 20),

                    // Error Alert Banner if pipeline failed
                    if (state.error != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.xDangerRed.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.xDangerRed.withAlpha(50)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.xDangerRed),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pipeline Error: ${state.error}',
                                style: const TextStyle(color: AppTheme.xDangerRed, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Results Dashboard (Tabbed or Column)
                    if (state.plan != null || state.generatedCode != null || state.validationReport != null)
                      DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
                                ),
                              ),
                              child: const TabBar(
                                indicatorColor: AppTheme.xBlue,
                                labelColor: AppTheme.xBlue,
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  Tab(icon: Icon(Icons.psychology_outlined), text: '1. Architecture Plan'),
                                  Tab(icon: Icon(Icons.code_rounded), text: '2. Flutter Code'),
                                  Tab(icon: Icon(Icons.verified_user_outlined), text: '3. Audit Report'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 580,
                              child: TabBarView(
                                children: [
                                  // Tab 1: Architecture Plan
                                  state.plan != null
                                      ? SingleChildScrollView(child: PlanSummaryCard(plan: state.plan!))
                                      : _buildPendingState('Planning Agent working...'),

                                  // Tab 2: Flutter Code
                                  state.generatedCode != null
                                      ? SingleChildScrollView(child: CodeOutputCard(generatedCode: state.generatedCode!))
                                      : _buildPendingState('Generation Agent waiting for plan...'),

                                  // Tab 3: Audit Report
                                  state.validationReport != null
                                      ? SingleChildScrollView(child: ValidationReportCard(report: state.validationReport!))
                                      : _buildPendingState('Validation Agent waiting for generated code...'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (state.stage == AgentStage.idle)
                      _buildEmptyState(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.xBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_mosaic, color: AppTheme.xBlue, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-Agent Workflow Pattern',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Planning Agent → Generation Agent → Validation Agent. Multi-step reasoning pipeline for reliable Flutter feature generation.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(bool isDark, bool isRunning) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FEATURE REQUEST PROMPT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _promptController,
            maxLines: 2,
            minLines: 1,
            enabled: !isRunning,
            decoration: InputDecoration(
              hintText: 'Enter feature request (e.g. Create a clean login screen)...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.xBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),

          // Preset Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _samplePresets.map((preset) {
              return ActionChip(
                label: Text(preset, style: const TextStyle(fontSize: 11)),
                backgroundColor: isDark ? AppTheme.xBlack : Colors.grey.shade100,
                onPressed: isRunning
                    ? null
                    : () {
                        _promptController.text = preset;
                        setState(() {});
                      },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.xBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: isRunning ? null : _runPipeline,
            icon: isRunning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(
              isRunning ? 'Executing Multi-Agent Pipeline...' : 'Run Multi-Agent Pipeline',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.hub_outlined, size: 48, color: Colors.grey.withAlpha(100)),
          const SizedBox(height: 12),
          const Text(
            'Enter a feature request prompt and click "Run Multi-Agent Pipeline"',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState(String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.xBlue),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
