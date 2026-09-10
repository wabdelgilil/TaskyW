import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/task_model.dart';

/// كارت عرض المهمة بتصميم عصري وأنيق مع دعم التخصيص اللوني والشارات التفاعلية
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onToggleCompleted;
  final int completedSubtasksCount;
  final int totalSubtasksCount;
  final String? projectName;
  final String? projectEmoji;
  final String? areaName;
  final List<TagModel> tags;
  final VoidCallback? onProjectBadgeTap;
  final Color? projectColor;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleCompleted,
    this.completedSubtasksCount = 0,
    this.totalSubtasksCount = 0,
    this.projectName,
    this.projectEmoji,
    this.areaName,
    this.tags = const [],
    this.onProjectBadgeTap,
    this.projectColor,
  });

  bool get isCompleted => task.status == 'completed';

  bool get isOverdue {
    if (task.dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    return due.isBefore(today);
  }

  bool get isDueToday {
    if (task.dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawColor = task.colorHex != null ? AppColors.fromHex(task.colorHex) : null;
    final customColor = rawColor != null ? AppColors.adaptiveCustomColor(rawColor, isDark) : null;
    final badgeColor = projectColor != null
        ? AppColors.adaptiveCustomColor(projectColor!, isDark)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: customColor != null
          ? (isDark ? customColor.withValues(alpha: 0.14) : customColor.withValues(alpha: 0.08))
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: customColor != null
              ? (isDark ? customColor.withValues(alpha: 0.65) : customColor.withValues(alpha: 0.50))
              : AppColors.border(context),
          width: customColor != null ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // شريط اللون المخصص الجانبي
              if (customColor != null)
                Container(
                  width: 5,
                  color: customColor,
                ),

              // المحتوى الرئيسي
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صف العنوان وصندوق الاختيار
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: isCompleted,
                              activeColor: customColor ?? AppColors.statusCompleted,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: onToggleCompleted,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted
                                      ? AppColors.textMuted(context)
                                      : AppColors.textPrimary(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // وصف مقتضب إن وجد
                      if (task.description != null && task.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // صف الشارات والمعلومات السفلية
                      Padding(
                        padding: const EdgeInsets.only(right: 36),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // شارة الحالة
                            StatusBadge(status: task.status),

                            // شارة الأولوية
                            PriorityBadge(priority: task.priority),

                            // مؤشر المهام الفرعية
                            if (totalSubtasksCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.border(context),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.checklist_rounded,
                                      size: 12,
                                      color: completedSubtasksCount == totalSubtasksCount
                                          ? AppColors.statusCompleted
                                          : AppColors.textSecondary(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$completedSubtasksCount/$totalSubtasksCount',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: completedSubtasksCount == totalSubtasksCount
                                          ? AppColors.statusCompleted
                                          : AppColors.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // تاريخ الديدلاين
                            if (task.dueDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? AppColors.priorityUrgent.withValues(alpha: 0.15)
                                      : (isDueToday
                                          ? AppColors.statusInProgress.withValues(alpha: 0.15)
                                          : (isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04))),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 11,
                                      color: isOverdue
                                          ? AppColors.priorityUrgent
                                          : (isDueToday ? AppColors.statusInProgress : Colors.grey),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${task.dueDate!.day}/${task.dueDate!.month}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isOverdue
                                            ? AppColors.priorityUrgent
                                            : (isDueToday ? AppColors.statusInProgress : Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // اسم المشروع التابع له (شارة قابلة للنقر تفتح صفحة المشروع)
                            if (projectName != null)
                              InkWell(
                                onTap: onProjectBadgeTap,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: badgeColor != null
                                        ? badgeColor.withValues(alpha: isDark ? 0.22 : 0.12)
                                        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                                    borderRadius: BorderRadius.circular(6),
                                    border: badgeColor != null
                                        ? Border.all(color: badgeColor.withValues(alpha: isDark ? 0.6 : 0.45), width: 0.9)
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (projectEmoji != null) ...[
                                        Text(projectEmoji!, style: const TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        projectName!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: badgeColor != null
                                              ? AppColors.adaptiveCustomColor(badgeColor, isDark)
                                              : AppColors.textSecondary(context),
                                        ),
                                      ),
                                      if (onProjectBadgeTap != null) ...[
                                        const SizedBox(width: 3),
                                        Icon(
                                          Icons.open_in_new,
                                          size: 10,
                                          color: badgeColor != null
                                              ? AppColors.adaptiveCustomColor(badgeColor, isDark)
                                              : AppColors.textMuted(context),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              // شارة المهمة المتكررة
                              if (task.isRecurring)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF8B5CF6).withValues(alpha: 0.2) : const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFFA78BFA).withValues(alpha: 0.4) : const Color(0xFF7C3AED).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.repeat_rounded, size: 11, color: Color(0xFF8B5CF6)),
                                      const SizedBox(width: 3),
                                      Text(
                                        task.recurrencePattern == 'daily'
                                            ? context.l10n.recurrenceDaily
                                            : (task.recurrencePattern == 'weekly'
                                                ? context.l10n.recurrenceWeekly
                                                : (task.recurrencePattern == 'monthly' ? context.l10n.recurrenceMonthly : context.l10n.recurrenceRecurring)),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // شارات الوسوم
                              for (final tag in tags)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.fromHex(tag.colorHex).withValues(alpha: isDark ? 0.22 : 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.fromHex(tag.colorHex).withValues(alpha: isDark ? 0.6 : 0.4),
                                      width: 0.9,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppColors.fromHex(tag.colorHex),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        tag.name,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.adaptiveCustomColor(AppColors.fromHex(tag.colorHex), isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
