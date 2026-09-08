import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';
import 'task_card.dart';

/// عرض القائمة الذكية للمهام مع دعم التجميع والإجراءات السريعة
class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleCompleted;
  final VoidCallback? onAddTask;
  final Map<String, int> subtaskCounts;
  final Map<String, int> completedSubtaskCounts;
  final String emptyMessage;

  const TaskListView({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onToggleCompleted,
    this.onAddTask,
    this.subtaskCounts = const {},
    this.completedSubtaskCounts = const {},
    this.emptyMessage = 'لا توجد مهام مسجلة حالياً',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  size: 36,
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ابدأ بإضافة مهمة جديدة لمتابعة إنجازك اليومي',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted(context),
                ),
              ),
              if (onAddTask != null) ...[
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة مهمة جديدة'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final totalSubs = subtaskCounts[task.id] ?? 0;
        final doneSubs = completedSubtaskCounts[task.id] ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: TaskCard(
            task: task,
            totalSubtasksCount: totalSubs,
            completedSubtasksCount: doneSubs,
            onTap: () => onTaskTap?.call(task),
            onToggleCompleted: (val) => onToggleCompleted?.call(task, val ?? false),
          ),
        );
      },
    );
  }
}
