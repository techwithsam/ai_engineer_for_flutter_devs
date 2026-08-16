import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/feature_plan.dart';

class PlanSummaryCard extends StatelessWidget {
  final FeaturePlan plan;

  const PlanSummaryCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header Badge & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.xBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology, color: AppTheme.xBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target Platform: ${plan.targetPlatform}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.xBlue, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Overview text
          Text(
            plan.overview,
            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.grey),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Components list
          const Text(
            'COMPONENTS TO BUILD',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: plan.componentsToBuild.map((comp) {
              return Chip(
                avatar: const Icon(Icons.widgets_outlined, size: 14, color: AppTheme.xBlue),
                label: Text(comp, style: const TextStyle(fontSize: 12)),
                backgroundColor: isDark ? AppTheme.xBlack : Colors.grey.shade100,
                side: BorderSide(color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Implementation Steps
          const Text(
            'IMPLEMENTATION STEPS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...plan.implementationSteps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.xSuccessGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),

          if (plan.riskConsiderations.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.xWarningYellow.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.xWarningYellow.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.xWarningYellow),
                      SizedBox(width: 6),
                      Text(
                        'Architectural Edge Cases & Risks',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.xWarningYellow),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...plan.riskConsiderations.map(
                    (risk) => Text('• $risk', style: const TextStyle(fontSize: 12, height: 1.3)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
