import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/agent_workflow_state.dart';

class AgentTelemetrySheet extends StatelessWidget {
  final List<AgentLogEntry> logs;

  const AgentTelemetrySheet({super.key, required this.logs});

  static void show(BuildContext context, List<AgentLogEntry> logs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: AgentTelemetrySheet(logs: logs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.terminal, color: AppTheme.xBlue, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Inter-Agent Telemetry Logs',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No telemetry logs recorded yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final timeStr =
                          '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.xBlack : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.xBlue.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    log.agentName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.xBlue,
                                    ),
                                  ),
                                ),
                                Text(
                                  timeStr,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              log.message,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            if (log.rawPayload != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    log.rawPayload!,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Color(0xFFCE9178),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
