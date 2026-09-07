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

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'low':
        return AppColors.priorityLow;
      case 'medium':
      default:
        return AppColors.priorityMedium;
    }
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
    final color = getPriorityColor(priority);
    final label = getPriorityLabel(priority);
    final icon = getPriorityIcon(priority);

    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
