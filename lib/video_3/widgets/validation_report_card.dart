import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/validation_report.dart';

class ValidationReportCard extends StatelessWidget {
  final ValidationReport report;

  const ValidationReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = report.qualityScore >= 80
        ? AppTheme.xSuccessGreen
        : (report.qualityScore >= 60 ? AppTheme.xWarningYellow : AppTheme.xDangerRed);

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
          // Header with Gauge Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scoreColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.verified_user, color: scoreColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit & Validation Report',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Stage 3 Quality & Security Review',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              // Quality Score Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor),
                ),
                child: Row(
                  children: [
                    Text(
                      '${report.qualityScore}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Identified Issues Checklist
          const Text(
            'IDENTIFIED ISSUES & RISKS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (report.identifiedIssues.isEmpty)
            const Text('✓ No major issues or vulnerabilities detected.', style: TextStyle(color: AppTheme.xSuccessGreen, fontSize: 13))
          else
            ...report.identifiedIssues.map((issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 16, color: AppTheme.xDangerRed),
                      const SizedBox(width: 8),
                      Expanded(child: Text(issue, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),

          const SizedBox(height: 16),

          // Improvement Suggestions
          const Text(
            'RECOMMENDED IMPROVEMENTS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...report.improvementSuggestions.map((sug) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.xBlue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(sug, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),

          // Refined Code Snippet Patch
          if (report.refinedCodeSnippet != null && report.refinedCodeSnippet!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'RECOMMENDED CODE REFINEMENT PATCH',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppTheme.xBlue),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                report.refinedCodeSnippet!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF9CDCFE),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
