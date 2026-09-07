import 'package:flutter/material.dart';

/// شريط تقدم متحرك بنسبة مئوية ولون مخصص
class ProgressBarWidget extends StatelessWidget {
  final double progress; // من 0.0 إلى 1.0
  final Color? color;
  final double height;
  final bool showPercentage;

  const ProgressBarWidget({
    super.key,
    required this.progress,
    this.color,
    this.height = 6.0,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).toInt();

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(
            height: height,
            width: double.infinity,
            color: effectiveColor.withOpacity(0.15),
          ),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            widthFactor: clampedProgress,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ),
    );

    if (!showPercentage) return bar;

    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
      ],
    );
  }
}
