import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// شارة أولوية المهمة بألوان ورموز واضحة
class PriorityBadge extends StatelessWidget {
  final String priority;
  final VoidCallback? onTap;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.onTap,
  });

  static Color getPriorityColor(String priority, {bool isDark = false}) {
    return AppColors.adaptivePriorityColor(priority, isDark);
  }

  static String getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'عاجل جداً';
      case 'high':
        return 'عالية';
      case 'low':
        return 'منخفضة';
      case 'medium':
      default:
        return 'متوسطة';
    }
  }

  static IconData getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Icons.local_fire_department_rounded;
      case 'high':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'low':
        return Icons.keyboard_arrow_down_rounded;
      case 'medium':
      default:
        return Icons.drag_handle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getPriorityColor(priority, isDark: isDark);
    final label = getPriorityLabel(priority);
    final icon = getPriorityIcon(priority);

    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.20) : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? color.withOpacity(0.55) : color.withOpacity(0.40),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: widget,
      );
    }
    return widget;
  }
}
