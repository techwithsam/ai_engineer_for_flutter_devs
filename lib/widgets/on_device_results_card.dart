import 'package:flutter/material.dart';
import '../models/text_analysis_models.dart';
import '../theme/app_theme.dart';

/// OnDeviceResultsCard displays fast, local machine learning classification results.
///
/// Step 3: On-Device TFLite Results Visualization
/// - Visualizes Sentiment Score with progress bar and color-coded indicator.
/// - Shows Category & Intent classification with confidence metrics.
/// - Highlights latency metric in milliseconds (e.g. ⚡ 12ms).
class OnDeviceResultsCard extends StatelessWidget {
  final OnDeviceClassification? classification;
  final bool isLoading;
  final String? error;

  const OnDeviceResultsCard({
    super.key,
    required this.classification,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.xDarkCard : AppTheme.xLightCard;
    final borderColor = isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.xBlue.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppTheme.xBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'On-Device Classifier',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        classification?.isFallback == false
                            ? 'TFLite Model (tflite_flutter)'
                            : 'On-Device Token Engine',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (classification != null && !isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.xBlue.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.xBlue.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppTheme.xBlue),
                        const SizedBox(width: 4),
                        Text(
                          '${classification!.inferenceTimeMs} ms',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.xBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const Divider(height: 24),

            // Body
            if (isLoading)
              _buildLoadingState()
            else if (error != null)
              _buildErrorState()
            else if (classification != null)
              _buildSuccessState(context)
            else
              _buildIdleState(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.xBlue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Running On-Device Classifier...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.xBlue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Instant local inference on device',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.xDangerRed.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.xDangerRed.withAlpha(50)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.xDangerRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error!,
                style: const TextStyle(fontSize: 13, color: AppTheme.xDangerRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.speed_rounded, size: 36, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Press "Analyze Text" to evaluate real-time on-device classification.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final sentimentType = classification!.sentimentType;
    Color sentimentColor;
    IconData sentimentIcon;

    switch (sentimentType) {
      case SentimentType.positive:
        sentimentColor = AppTheme.xSuccessGreen;
        sentimentIcon = Icons.sentiment_very_satisfied_rounded;
        break;
      case SentimentType.negative:
        sentimentColor = AppTheme.xDangerRed;
        sentimentIcon = Icons.sentiment_very_dissatisfied_rounded;
        break;
      case SentimentType.neutral:
        sentimentColor = Colors.blueGrey;
        sentimentIcon = Icons.sentiment_neutral_rounded;
        break;
    }

    final int sentimentPct = (classification!.sentimentScore * 100).round();
    final int categoryPct = (classification!.categoryConfidence * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sentiment Card
        const Text(
          'SENTIMENT ANALYSIS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: AppTheme.xBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sentimentColor.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sentimentColor.withAlpha(50)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(sentimentIcon, color: sentimentColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classification!.sentiment,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: sentimentColor,
                          ),
                        ),
                        Text(
                          'Confidence: $sentimentPct%',
                          style: TextStyle(
                            fontSize: 12,
                            color: sentimentColor.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: classification!.sentimentScore,
                  minHeight: 6,
                  backgroundColor: sentimentColor.withAlpha(30),
                  color: sentimentColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Category Classification
        const Text(
          'TEXT CATEGORY & INTENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: AppTheme.xBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.xBlue.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.xBlue.withAlpha(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 18, color: AppTheme.xBlue),
                      const SizedBox(width: 8),
                      Text(
                        classification!.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.xBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$categoryPct% match',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: classification!.categoryConfidence,
                  minHeight: 5,
                  backgroundColor: AppTheme.xBlue.withAlpha(30),
                  color: AppTheme.xBlue,
                ),
              ),
            ],
          ),
        ),

        // Key Terms
        if (classification!.keywordsDetected.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'KEY TERMS DETECTED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: classification!.keywordsDetected
                .map(
                  (kw) => Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppTheme.xBlue.withAlpha(15),
                    side: BorderSide(color: AppTheme.xBlue.withAlpha(40)),
                    label: Text(
                      '#$kw',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.xBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
