import 'package:flutter/material.dart';
import '../../../../core/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';
import 'task_card.dart';

/// عرض القائمة الذكية للمهام مع دعم التجميع والإجراءات السريعة.
///
/// يسحب المهام المكتملة تلقائياً إلى قسم سفلي منفصل قابل للطي/الفتح
/// (`Completed Tasks Section`) بتنسيق بصري هادئ ومميز، مع عداد المهام
/// المكتملة وخيار إظهارها أو إخفائها بسلاسة.
class TaskListView extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleCompleted;
  final VoidCallback? onAddTask;
  final Map<String, int> subtaskCounts;
  final Map<String, int> completedSubtaskCounts;
  final Map<String, List<TagModel>> taskTags;
  final String emptyMessage;
  final bool showCompletedSection;

  const TaskListView({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onToggleCompleted,
    this.onAddTask,
    this.subtaskCounts = const {},
    this.completedSubtaskCounts = const {},
    this.taskTags = const {},
    this.emptyMessage = 'لا توجد مهام مسجلة حالياً',
    this.showCompletedSection = true,
  });

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  bool _completedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // عزل المهام المكتملة في قسم منفصل
    final activeTasks = widget.tasks
        .where((t) => t.status != 'completed')
        .toList();
    final completedTasks = widget.tasks
        .where((t) => t.status == 'completed')
        .toList();

    final hasAnyTask = widget.tasks.isNotEmpty;

    if (!hasAnyTask) {
      return _buildEmptyState(context);
    }

    // عند تعطيل قسم المكتملة تُعرض كل المهام كقائمة مسطّحة بدون تجميع
    if (!widget.showCompletedSection) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: widget.tasks.map((task) => _buildTaskItem(context, task)).toList(),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // المهام النشطة (غير المكتملة)
        ...activeTasks.map((task) => _buildTaskItem(context, task)),

        if (completedTasks.isNotEmpty) ...[
          // قسم المهام المكتملة القابل للطي
          _buildCompletedSectionHeader(context, completedTasks.length, isDark),
          if (_completedExpanded)
            ...completedTasks.map((task) => _buildTaskItem(context, task)),
        ],

        // حالة كل المهام مكتملة
        if (activeTasks.isEmpty && completedTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 16,
                  color: AppColors.statusCompleted,
                ),
                const SizedBox(width: 6),
                Text(
                  'تم إنجاز كل المهام في هذا القسم 🎉',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              widget.emptyMessage,
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
            if (widget.onAddTask != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: widget.onAddTask,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مهمة جديدة'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task) {
    final isCompleted = task.status == 'completed';

    final card = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TaskCard(
        task: task,
        totalSubtasksCount: widget.subtaskCounts[task.id] ?? 0,
        completedSubtasksCount: widget.completedSubtaskCounts[task.id] ?? 0,
        tags: widget.taskTags[task.id] ?? const [],
        onTap: () => widget.onTaskTap?.call(task),
        onToggleCompleted: (val) => widget.onToggleCompleted?.call(task, val ?? false),
      ),
    );

    if (!isCompleted) return card;

    // تنسيق هادئ ومميز للمهام المكتملة (شفافية + شريط نجاح أخضر + شارة إكمال)
    return Opacity(
      opacity: 0.6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            right: BorderSide(
              color: AppColors.statusCompleted,
              width: 3,
            ),
          ),
        ),
        child: card,
      ),
    );
  }

  Widget _buildCompletedSectionHeader(
    BuildContext context,
    int count,
    bool isDark,
  ) {
    final completedColor = AppColors.statusCompleted;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _completedExpanded = !_completedExpanded),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: completedColor.withOpacity(isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: completedColor.withOpacity(isDark ? 0.35 : 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: completedColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'المهام المكتملة (Completed Tasks)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                // عداد المهام المكتملة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: completedColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: completedColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: _completedExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}