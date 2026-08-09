import 'package:flutter/material.dart';
import '../models/article_blueprint.dart';
import '../theme/app_theme.dart';

/// Renders strongly-typed Structured Output parsed from Gemini JSON payload.
///
/// Core UI Component (Pillar 1: Structured Output)
class StructuredBlueprintCard extends StatelessWidget {
  final ArticleBlueprint blueprint;

  const StructuredBlueprintCard({
    super.key,
    required this.blueprint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.xDarkCard : AppTheme.xLightCard;
    final borderColor = isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder;

    Color diffColor;
    switch (blueprint.difficulty.toLowerCase()) {
      case 'beginner':
        diffColor = AppTheme.xSuccessGreen;
        break;
      case 'advanced':
        diffColor = AppTheme.xDangerRed;
        break;
      default:
        diffColor = AppTheme.xWarningYellow;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header & Difficulty Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: diffColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: diffColor.withAlpha(50)),
                          ),
                          child: Text(
                            blueprint.difficulty.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: diffColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${blueprint.estimatedReadingMinutes} min read',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blueprint.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Overview Text Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.xCloudPurple.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.xCloudPurple.withAlpha(30)),
            ),
            child: Text(
              blueprint.overview,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),

          const SizedBox(height: 16),

          // Tags Row
          if (blueprint.tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: blueprint.tags.map((tag) {
                return Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppTheme.xBlue.withAlpha(15),
                  side: BorderSide(color: AppTheme.xBlue.withAlpha(40)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  label: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.xBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Key Concepts Checklist
          if (blueprint.keyConcepts.isNotEmpty) ...[
            const Text(
              'KEY CONCEPTS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppTheme.xBlue,
              ),
            ),
            const SizedBox(height: 8),
            ...blueprint.keyConcepts.map(
              (concept) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppTheme.xBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        concept,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Implementation Steps
          if (blueprint.implementationSteps.isNotEmpty) ...[
            const Text(
              'IMPLEMENTATION STEPS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppTheme.xCloudPurple,
              ),
            ),
            const SizedBox(height: 8),
            ...blueprint.implementationSteps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppTheme.xCloudPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$idx',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Code Snippet Box
          if (blueprint.codeSnippet != null && blueprint.codeSnippet!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'CODE EXCERPT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.grey.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                blueprint.codeSnippet!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.lightGreenAccent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
