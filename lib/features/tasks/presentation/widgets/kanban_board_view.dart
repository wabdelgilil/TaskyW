import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/task_model.dart';
import 'task_card.dart';

/// لوحة كانبان تفاعلية بـ 5 أعمدة مع دعم السحب والإفلات الكامل
class KanbanBoardView extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel task, String newStatus) onTaskStatusChanged;
  final Function(TaskModel task)? onTaskTap;
  final Function(String status)? onAddTaskInColumn;
  final Map<String, int> subtaskCounts; // taskId -> totalSubtasks
  final Map<String, int> completedSubtaskCounts; // taskId -> completedSubtasks

  const KanbanBoardView({
    super.key,
    required this.tasks,
    required this.onTaskStatusChanged,
    this.onTaskTap,
    this.onAddTaskInColumn,
    this.subtaskCounts = const {},
    this.completedSubtaskCounts = const {},
  });

  static const List<String> columns = [
    'todo',
    'in_progress',
    'waiting',
    'review',
    'completed',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 100
            ? constraints.maxHeight - 24
            : 600.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: availableHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: columns.map((status) {
                final columnTasks = tasks.where((t) => t.status == status).toList();
                return Container(
                  width: 310,
                  margin: const EdgeInsets.only(left: 14),
                  child: _KanbanColumn(
                    status: status,
                    tasks: columnTasks,
                    subtaskCounts: subtaskCounts,
                    completedSubtaskCounts: completedSubtaskCounts,
                    onTaskDropped: (task) => onTaskStatusChanged(task, status),
                    onTaskTap: onTaskTap,
                    onAddTask: () => onAddTaskInColumn?.call(status),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String status;
  final List<TaskModel> tasks;
  final Map<String, int> subtaskCounts;
  final Map<String, int> completedSubtaskCounts;
  final Function(TaskModel task) onTaskDropped;
  final Function(TaskModel task)? onTaskTap;
  final VoidCallback? onAddTask;

  const _KanbanColumn({
    required this.status,
    required this.tasks,
    required this.subtaskCounts,
    required this.completedSubtaskCounts,
    required this.onTaskDropped,
    this.onTaskTap,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = StatusBadge.getStatusColor(status);
    final label = StatusBadge.getStatusLabel(status);

    return DragTarget<TaskModel>(
      onWillAccept: (data) => data != null && data.status != status,
      onAccept: (data) => onTaskDropped(data),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: isHovered
                ? color.withOpacity(0.12)
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovered
                  ? color
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // رأس العمود (Column Header)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black38 : Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                           fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: 'إضافة مهمة في هذا العمود',
                      splashRadius: 18,
                      onPressed: onAddTask,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // قائمة الكروت القابلة للسحب
              Expanded(
                child: tasks.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Text(
                          'اسحب المهام إلى هنا أو أضف مهمة جديدة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final totalSubs = subtaskCounts[task.id] ?? 0;
                          final doneSubs = completedSubtaskCounts[task.id] ?? 0;

                          return LongPressDraggable<TaskModel>(
                            data: task,
                            feedback: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                              child: SizedBox(
                                width: 290,
                                child: TaskCard(
                                  task: task,
                                  totalSubtasksCount: totalSubs,
                                  completedSubtasksCount: doneSubs,
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: TaskCard(
                                task: task,
                                totalSubtasksCount: totalSubs,
                                completedSubtasksCount: doneSubs,
                              ),
                            ),
                            child: TaskCard(
                              task: task,
                              totalSubtasksCount: totalSubs,
                              completedSubtasksCount: doneSubs,
                              onTap: () => onTaskTap?.call(task),
                              onToggleCompleted: (val) {
                                final newStatus = (val == true) ? 'completed' : 'todo';
                                onTaskDropped(task.copyWith(status: newStatus));
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
