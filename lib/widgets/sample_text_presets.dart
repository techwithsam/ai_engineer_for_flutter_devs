import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SamplePreset {
  final String title;
  final IconData icon;
  final Color color;
  final String text;

  const SamplePreset({
    required this.title,
    required this.icon,
    required this.color,
    required this.text,
  });
}

/// SampleTextPresets renders 1-tap presets for fast testing.
///
/// Step 3: Helper UI Components
class SampleTextPresets extends StatelessWidget {
  final ValueChanged<String> onSelectPreset;

  const SampleTextPresets({
    super.key,
    required this.onSelectPreset,
  });

  static const List<SamplePreset> _presets = [
    SamplePreset(
      title: 'Positive Review',
      icon: Icons.star_rounded,
      color: AppTheme.xSuccessGreen,
      text:
          'I love this smart text analyzer! The UI design is super clean, smooth, and fast. '
          'It resolved all my workflow bottlenecks immediately. Highly recommend to everyone looking for great performance!',
    ),
    SamplePreset(
      title: 'Urgent Support',
      icon: Icons.warning_amber_rounded,
      color: AppTheme.xDangerRed,
      text:
          'URGENT: Our production database server crashed after the latest billing update. '
          'Users are getting broken login error screens and payments are failing immediately. Please fix this ASAP!',
    ),
    SamplePreset(
      title: 'Tech Integration',
      icon: Icons.code_rounded,
      color: AppTheme.xBlue,
      text:
          'How do we integrate the tflite_flutter SDK with custom Flutter API endpoints? '
          'We need to verify model inference latency and ensure background thread memory optimization on mobile devices.',
    ),
    SamplePreset(
      title: 'Product Feedback',
      icon: Icons.thumb_up_alt_outlined,
      color: AppTheme.xCloudPurple,
      text:
          'The overall app design is great, but the feature layout needs an updated dark mode toggle. '
          'Adding custom notification settings on the user profile screen would make the UX even more fantastic.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.touch_app_outlined, size: 16, color: Colors.grey),
            SizedBox(width: 6),
            Text(
              'Sample Presets (Tap to test):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _presets.map((preset) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: Icon(preset.icon, size: 16, color: preset.color),
                  label: Text(
                    preset.title,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: preset.color.withAlpha(15),
                  side: BorderSide(color: preset.color.withAlpha(40)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () => onSelectPreset(preset.text),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
