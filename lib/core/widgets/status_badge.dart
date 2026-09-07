import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// شارة أنيقة لعرض حالة المهمة مع لونها وأيقونتها
class StatusBadge extends StatelessWidget {
  final String status;
  final VoidCallback? onTap;

  const StatusBadge({
    super.key,
    required this.status,
    this.onTap,
  });

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'waiting':
        return AppColors.statusWaiting;
      case 'review':
        return AppColors.statusReview;
      case 'completed':
        return AppColors.statusCompleted;
      case 'todo':
      default:
        return AppColors.statusTodo;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'waiting':
        return 'معلّقة';
      case 'review':
        return 'مراجعة';
      case 'completed':
        return 'مكتملة';
      case 'todo':
      default:
        return 'قيد الانتظار';
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Icons.play_arrow_rounded;
      case 'waiting':
        return Icons.pause_circle_outline_rounded;
      case 'review':
        return Icons.rate_review_outlined;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'todo':
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    final label = getStatusLabel(status);
    final icon = getStatusIcon(status);

    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
