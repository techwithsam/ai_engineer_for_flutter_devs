import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/agent_workflow_state.dart';

class AgentWorkflowStepper extends StatelessWidget {
  final AgentStage stage;
  final Duration elapsedDuration;

  const AgentWorkflowStepper({
    super.key,
    required this.stage,
    required this.elapsedDuration,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_tree_outlined, color: AppTheme.xBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'MULTI-AGENT PIPELINE TIMELINE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.xBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(elapsedDuration.inMilliseconds / 1000).toStringAsFixed(1)}s',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.xBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStepItem(
                  context,
                  title: '1. Planning',
                  subtitle: 'Architect Agent',
                  icon: Icons.psychology_outlined,
                  isCurrent: stage == AgentStage.planning,
                  isDone: stage.index > AgentStage.planning.index && stage != AgentStage.failed,
                  isFailed: stage == AgentStage.failed && stage == AgentStage.planning,
                ),
              ),
              _buildConnector(stage.index > AgentStage.planning.index),
              Expanded(
                child: _buildStepItem(
                  context,
                  title: '2. Generation',
                  subtitle: 'Flutter Code Agent',
                  icon: Icons.code_rounded,
                  isCurrent: stage == AgentStage.generating,
                  isDone: stage.index > AgentStage.generating.index && stage != AgentStage.failed,
                  isFailed: stage == AgentStage.failed && stage == AgentStage.generating,
                ),
              ),
              _buildConnector(stage.index > AgentStage.generating.index),
              Expanded(
                child: _buildStepItem(
                  context,
                  title: '3. Validation',
                  subtitle: 'Audit Agent',
                  icon: Icons.verified_user_outlined,
                  isCurrent: stage == AgentStage.validating,
                  isDone: stage == AgentStage.completed,
                  isFailed: stage == AgentStage.failed && stage == AgentStage.validating,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCurrent,
    required bool isDone,
    required bool isFailed,
  }) {
    Color badgeColor;
    Widget iconWidget;

    if (isFailed) {
      badgeColor = AppTheme.xDangerRed;
      iconWidget = const Icon(Icons.close_rounded, color: Colors.white, size: 16);
    } else if (isDone) {
      badgeColor = AppTheme.xSuccessGreen;
      iconWidget = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
    } else if (isCurrent) {
      badgeColor = AppTheme.xBlue;
      iconWidget = const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    } else {
      badgeColor = Colors.grey.withAlpha(50);
      iconWidget = Icon(icon, color: Colors.grey, size: 16);
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.xBlue.withAlpha(80),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppTheme.xBlue : (isDone ? AppTheme.xSuccessGreen : Colors.grey),
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isDone) {
    return Container(
      width: 28,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isDone ? AppTheme.xSuccessGreen : Colors.grey.withAlpha(60),
    );
  }
}
