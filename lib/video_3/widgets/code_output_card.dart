import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../models/generated_feature_code.dart';

class CodeOutputCard extends StatelessWidget {
  final GeneratedFeatureCode generatedCode;

  const CodeOutputCard({super.key, required this.generatedCode});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: generatedCode.flutterCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.content_copy, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Flutter Code copied to clipboard!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.xBlue.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.code, color: AppTheme.xBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    generatedCode.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.xBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Code', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            generatedCode.explanation,
            style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
          ),

          const SizedBox(height: 14),

          // Required Pub Dependencies Chips
          if (generatedCode.dependencies.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 4),
                  child: Text('Dependencies:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ),
                ...generatedCode.dependencies.map((dep) => Chip(
                      label: Text(dep, style: const TextStyle(fontSize: 11, color: AppTheme.xBlue)),
                      backgroundColor: AppTheme.xBlue.withAlpha(15),
                      visualDensity: VisualDensity.compact,
                    )),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Code Container Block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark code IDE background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                generatedCode.flutterCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: Color(0xFFD4D4D4),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
