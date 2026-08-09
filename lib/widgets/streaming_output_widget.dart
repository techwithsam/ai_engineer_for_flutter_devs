import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Real-Time Streaming Output Widget demonstrating Pillar 2: Token Streaming.
///
/// Features:
/// - Real-time token append buffer
/// - Typewriter cursor indicator
/// - Stream Cancellation ("Stop Stream") button calling [streamSubscription.cancel()]
/// - Streaming metrics (chunks received, elapsed duration)
class StreamingOutputWidget extends StatelessWidget {
  final String textBuffer;
  final bool isStreaming;
  final int chunkCount;
  final Duration elapsedDuration;
  final VoidCallback onCancelStream;

  const StreamingOutputWidget({
    super.key,
    required this.textBuffer,
    required this.isStreaming,
    required this.chunkCount,
    required this.elapsedDuration,
    required this.onCancelStream,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.xDarkCard : AppTheme.xLightCard;
    final borderColor = isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder;

    final seconds = (elapsedDuration.inMilliseconds / 1000).toStringAsFixed(1);

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
          // Header Row with Live Stream Metrics & Cancel Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.xBlue.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.stream_rounded,
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
                      'Real-Time Token Stream',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isStreaming
                          ? 'Receiving tokens live via generateContentStream()'
                          : 'Stream complete',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isStreaming) ...[
                // Stream Cancellation Button (Pillar 2 Core Requirement)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.xDangerRed,
                    side: const BorderSide(color: AppTheme.xDangerRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: onCancelStream,
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: const Text('Cancel Stream'),
                ),
              ],
            ],
          ),

          const Divider(height: 24),

          // Live Metrics Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.xBlue.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.xBlue.withAlpha(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 14, color: AppTheme.xBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Chunks Received: $chunkCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.xBlue,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppTheme.xBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Duration: ${seconds}s',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.xBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Streaming Text View with Typewriter Cursor
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
              ),
            ),
            child: textBuffer.isEmpty
                ? const Center(
                    child: Text(
                      'Press "Start Live Stream" to watch real-time token rendering...',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : SelectableText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: textBuffer,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (isStreaming)
                          const TextSpan(
                            text: ' █',
                            style: TextStyle(
                              color: AppTheme.xBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
