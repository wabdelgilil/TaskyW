import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import '../../l10n/app_localizations.dart';
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

  static Color getStatusColor(String status, {bool isDark = false}) {
    return AppColors.adaptiveStatusColor(status, isDark);
  }

  static String getStatusLabel(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return l10n.statusInProgress;
      case 'waiting':
        return l10n.statusOnHold;
      case 'review':
        return l10n.statusReview;
      case 'completed':
        return l10n.statusCompleted;
      case 'todo':
      default:
        return l10n.statusWaiting;
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getStatusColor(status, isDark: isDark);
    final label = getStatusLabel(status, l10n);
    final icon = getStatusIcon(status);

    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
