import 'package:flutter/material.dart';
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
    final customColor = task.colorHex != null ? AppColors.fromHex(task.colorHex) : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: customColor != null
          ? (isDark ? customColor.withOpacity(0.12) : customColor.withOpacity(0.06))
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: customColor != null
              ? customColor.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
                                      ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                                  color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$completedSubtasksCount/$totalSubtasksCount',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: completedSubtasksCount == totalSubtasksCount
                                          ? AppColors.statusCompleted
                                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
                                      ? AppColors.priorityUrgent.withOpacity(0.15)
                                      : (isDueToday
                                          ? AppColors.statusInProgress.withOpacity(0.15)
                                          : (isDark ? Colors.black26 : Colors.black.withOpacity(0.04))),
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

                            // اسم المشروع التابع له
                            if (projectName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(6),
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
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
