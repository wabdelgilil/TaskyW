import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../projects/data/models/project_model.dart';
import '../../data/models/task_model.dart';
import 'task_card.dart';

/// لوحة كانبان تفاعلية بـ 5 أعمدة مع دعم السحب والإفلات الكامل
class KanbanBoardView extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel task, String newStatus) onTaskStatusChanged;
  final Function(TaskModel task)? onTaskTap;
  final Function(String status)? onAddTaskInColumn;
  final Map<String, int> subtaskCounts; // taskId -> totalSubtasks
  final Map<String, int> completedSubtaskCounts; // taskId -> completedSubtasks
  final Map<String, List<TagModel>> taskTags;
  final List<ProjectModel> projects;
  final Function(String? projectId)? onProjectBadgeTap;

  const KanbanBoardView({
    super.key,
    required this.tasks,
    required this.onTaskStatusChanged,
    this.onTaskTap,
    this.onAddTaskInColumn,
    this.subtaskCounts = const {},
    this.completedSubtaskCounts = const {},
    this.taskTags = const {},
    this.projects = const [],
    this.onProjectBadgeTap,
  });

  static const List<String> columns = [
    'todo',
    'in_progress',
    'waiting',
    'review',
    'completed',
  ];

  @override
  State<KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends State<KanbanBoardView> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 100
            ? constraints.maxHeight - 24
            : 600.0;

        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 18),
            child: SizedBox(
              height: availableHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: KanbanBoardView.columns.map((status) {
                  final columnTasks = widget.tasks.where((t) => t.status == status).toList();
                  return Container(
                    width: 310,
                    margin: const EdgeInsets.only(left: 14),
                    child: _KanbanColumn(
                      status: status,
                      tasks: columnTasks,
                      subtaskCounts: widget.subtaskCounts,
                      completedSubtaskCounts: widget.completedSubtaskCounts,
                      taskTags: widget.taskTags,
                      projects: widget.projects,
                      onProjectBadgeTap: widget.onProjectBadgeTap,
                      onTaskDropped: (task) => widget.onTaskStatusChanged(task, status),
                      onTaskTap: widget.onTaskTap,
                      onAddTask: () => widget.onAddTaskInColumn?.call(status),
                    ),
                  );
                }).toList(),
              ),
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
  final Map<String, List<TagModel>> taskTags;
  final List<ProjectModel> projects;
  final Function(TaskModel task) onTaskDropped;
  final Function(TaskModel task)? onTaskTap;
  final Function(String? projectId)? onProjectBadgeTap;
  final VoidCallback? onAddTask;

  const _KanbanColumn({
    required this.status,
    required this.tasks,
    required this.subtaskCounts,
    required this.completedSubtaskCounts,
    required this.taskTags,
    this.projects = const [],
    required this.onTaskDropped,
    this.onTaskTap,
    this.onProjectBadgeTap,
    this.onAddTask,
  });

  ProjectModel? _projectOf(TaskModel task) {
    if (task.projectId == null) return null;
    for (final p in projects) {
      if (p.id == task.projectId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = StatusBadge.getStatusColor(status, isDark: isDark);
    final label = StatusBadge.getStatusLabel(status, context.l10n);

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onTaskDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: isHovered
                ? color.withValues(alpha: 0.12)
                : (AppColors.isOled(context)
                    ? AppColors.oledSurface
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurfaceSubtle)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovered
                  ? color
                  : AppColors.border(context),
              width: isHovered ? 2 : 1.2,
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
                        color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.06),
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
                      tooltip: context.l10n.kanbanAddInColumn,
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
                          context.l10n.kanbanDropHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted(context),
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
                                  tags: taskTags[task.id] ?? const [],
                                  projectName: _projectOf(task)?.name,
                                  projectEmoji: _projectOf(task)?.iconEmoji,
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: TaskCard(
                                task: task,
                                totalSubtasksCount: totalSubs,
                                completedSubtasksCount: doneSubs,
                                tags: taskTags[task.id] ?? const [],
                                projectName: _projectOf(task)?.name,
                                projectEmoji: _projectOf(task)?.iconEmoji,
                              ),
                            ),
                            child: TaskCard(
                              task: task,
                              totalSubtasksCount: totalSubs,
                              completedSubtasksCount: doneSubs,
                              tags: taskTags[task.id] ?? const [],
                              projectName: _projectOf(task)?.name,
                              projectEmoji: _projectOf(task)?.iconEmoji,
                              projectColor: _projectOf(task) != null
                                  ? AppColors.fromHex(_projectOf(task)!.colorHex)
                                  : null,
                              onProjectBadgeTap: _projectOf(task) != null
                                  ? () => onProjectBadgeTap?.call(_projectOf(task)!.id)
                                  : null,
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
