import 'package:flutter/material.dart';
import '../models/ai_exceptions.dart';
import '../theme/app_theme.dart';

/// Error Resilience Banner displaying categorized exception details and retry controls.
///
/// Core UI Component (Pillar 3: Error Handling & Resilience)
class ErrorResilienceBanner extends StatelessWidget {
  final Object error;
  final int currentAttempt;
  final VoidCallback? onRetry;
  final VoidCallback? onConfigureKey;

  const ErrorResilienceBanner({
    super.key,
    required this.error,
    this.currentAttempt = 1,
    this.onRetry,
    this.onConfigureKey,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'AI Engineering Fault Detected';
    String description = error.toString();
    IconData icon = Icons.error_outline;
    Color color = AppTheme.xDangerRed;
    bool isKeyError = false;

    if (error is NetworkAIException) {
      title = 'Network Connection Issue';
      icon = Icons.wifi_off_rounded;
      color = Colors.orangeAccent;
    } else if (error is RateLimitAIException) {
      title = 'Rate Limit Exceeded (HTTP 429)';
      icon = Icons.speed_rounded;
      color = AppTheme.xWarningYellow;
    } else if (error is SchemaParsingAIException) {
      title = 'Structured Output Parsing Failure';
      icon = Icons.data_object_rounded;
      color = Colors.purpleAccent;
      description = (error as SchemaParsingAIException).message;
    } else if (error is SafetyRefusalAIException) {
      title = 'Content Policy Refusal';
      icon = Icons.shield_outlined;
      color = Colors.redAccent;
    } else if (error is InvalidApiKeyAIException) {
      title = 'Invalid / Missing Gemini API Key';
      icon = Icons.key_off_outlined;
      color = AppTheme.xWarningYellow;
      isKeyError = true;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Exception Type: ${error.runtimeType}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (currentAttempt > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Retry Attempt $currentAttempt/3',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Error Description
          Text(
            description,
            style: const TextStyle(fontSize: 13, height: 1.3),
          ),

          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              if (isKeyError && onConfigureKey != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.xBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onConfigureKey,
                  icon: const Icon(Icons.key, size: 16),
                  label: const Text('Configure Gemini Key'),
                )
              else if (onRetry != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry Request'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
