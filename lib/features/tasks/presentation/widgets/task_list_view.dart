import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../projects/data/models/project_model.dart';
import '../../data/models/task_model.dart';
import 'task_card.dart';

/// عرض القائمة الذكية للمهام مع دعم التجميع والإجراءات السريعة.
///
/// يسحب المهام المكتملة تلقائياً إلى قسم سفلي منفصل قابل للطي/الفتح
/// (`Completed Tasks Section`) بتنسيق بصري هادئ ومميز، مع عداد المهام
/// المكتملة وخيار إظهارها أو إخفائها بسلاسة.
///
/// يدعم عرض (Group by Project) مع شارات مشاريع قابلة للنقر،
/// وإيماءات السحب للموبايل (يمين = إنجاز، يسار = حذف ناعم مع تراجع).
class TaskListView extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleCompleted;
  final VoidCallback? onAddTask;
  final Function(String taskId)? onDeleteTask;
  final Function(String taskId)? onRestoreTask;
  final Function(String projectId)? onSelectProjectId;
  final Map<String, int> subtaskCounts;
  final Map<String, int> completedSubtaskCounts;
  final Map<String, List<TagModel>> taskTags;
  final List<ProjectModel> projects;
  final String emptyMessage;
  final bool showCompletedSection;

  const TaskListView({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onToggleCompleted,
    this.onAddTask,
    this.onDeleteTask,
    this.onRestoreTask,
    this.onSelectProjectId,
    this.subtaskCounts = const {},
    this.completedSubtaskCounts = const {},
    this.taskTags = const {},
    this.projects = const [],
    this.emptyMessage = '',
    this.showCompletedSection = true,
  });

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  bool _completedExpanded = false;
  bool _groupByProject = false;

  ProjectModel? _projectOf(TaskModel task) {
    if (task.projectId == null) return null;
    for (final p in widget.projects) {
      if (p.id == task.projectId) return p;
    }
    return null;
  }

  bool get _canGroupByProject =>
      widget.projects.isNotEmpty &&
      widget.tasks.any((t) => t.projectId != null);

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
        children: [
          if (_canGroupByProject) _buildGroupByToggle(context),
          ...widget.tasks.map((task) => _buildTaskItem(context, task)),
        ],
      );
    }

    if (_groupByProject && _canGroupByProject) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildGroupByToggle(context),
          ..._buildGroupedSections(context, activeTasks),
          if (completedTasks.isNotEmpty) ...[
            _buildCompletedSectionHeader(context, completedTasks.length, isDark),
            if (_completedExpanded)
              ...completedTasks.map((task) => _buildTaskItem(context, task)),
          ],
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (_canGroupByProject) _buildGroupByToggle(context),
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
                  context.l10n.allDoneSection,
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

  Widget _buildGroupByToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _groupByProject = !_groupByProject),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Icon(
                  _groupByProject ? Icons.grid_view_rounded : Icons.view_headline,
                  size: 17,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.groupByProject,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _groupByProject,
                  onChanged: (val) => setState(() => _groupByProject = val),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء أقسام مفهرسة بحسب المشروع مع شريط تقدم لكل مشروع.
  List<Widget> _buildGroupedSections(BuildContext context, List<TaskModel> activeTasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordered = [...widget.projects];
    final unassigned = activeTasks.where((t) => t.projectId == null).toList();

    final sections = <Widget>[];

    for (final project in ordered) {
      final projectTasks =
          activeTasks.where((t) => t.projectId == project.id).toList();
      if (projectTasks.isEmpty) continue;

      sections.add(_buildProjectSectionHeader(context, project, projectTasks, isDark));
      sections.addAll(projectTasks.map((task) => _buildTaskItem(context, task)));
    }

    if (unassigned.isNotEmpty) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              Icon(Icons.inbox_outlined, size: 15, color: AppColors.textMuted(context)),
              const SizedBox(width: 6),
              Text(
                context.l10n.noProject,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${unassigned.length}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      sections.addAll(unassigned.map((task) => _buildTaskItem(context, task)));
    }

    return sections;
  }

  Widget _buildProjectSectionHeader(
    BuildContext context,
    ProjectModel project,
    List<TaskModel> projectTasks,
    bool isDark,
  ) {
    final color = AppColors.adaptiveCustomColor(AppColors.fromHex(project.colorHex), isDark);
    final totalActive = projectTasks.length;
    final doneInProject = projectTasks.where((t) => t.status == 'completed').length;
    final progress = totalActive == 0 ? 0.0 : doneInProject / totalActive;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: isDark ? 0.35 : 0.25)),
        ),
        child: Row(
          children: [
            Icon(
              project.notificationsEnabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(project.iconEmoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                project.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalActive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            SizedBox(width: 40, child: LinearProgressIndicator(value: progress, color: color)),
          ],
        ),
      ),
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
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
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
                widget.emptyMessage.isNotEmpty ? widget.emptyMessage : context.l10n.noTasksRegistered,
                style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.startAddingTasks,
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
                label: Text(context.l10n.addNewTaskTitle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task) {
    final isCompleted = task.status == 'completed';
    final project = _projectOf(task);
    final projectColorHex =
        project != null ? AppColors.fromHex(project.colorHex) : null;

    final card = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TaskCard(
        task: task,
        totalSubtasksCount: widget.subtaskCounts[task.id] ?? 0,
        completedSubtasksCount: widget.completedSubtaskCounts[task.id] ?? 0,
        tags: widget.taskTags[task.id] ?? const [],
        projectName: project?.name,
        projectEmoji: project?.iconEmoji,
        projectColor: projectColorHex,
        onProjectBadgeTap:
            project != null ? () => widget.onSelectProjectId?.call(project.id) : null,
        onTap: () => widget.onTaskTap?.call(task),
        onToggleCompleted: (val) => widget.onToggleCompleted?.call(task, val ?? false),
      ),
    );

    final base = !isCompleted ? card : Opacity(
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

    // إيماءات السحب للموبايل (يمين = إنجاز، يسار = حذف ناعم مع تراجع)
    if (widget.onDeleteTask != null) {
      final isLtr =
          Directionality.of(context) == TextDirection.ltr ? true : false;
      return Dismissible(
        key: ValueKey('swipe-task-${task.id}'),
        direction: DismissDirection.horizontal,
        background: _buildSwipeBackground(
          context,
          alignEnd: isLtr,
          icon: Icons.check_circle_outline,
          label: context.l10n.markDone,
          color: AppColors.statusCompleted,
        ),
        secondaryBackground: _buildSwipeBackground(
          context,
          alignEnd: !isLtr,
          icon: Icons.delete_outline,
          label: context.l10n.commonDelete,
          color: Colors.redAccent,
        ),
        confirmDismiss: (details) async {
          final swipedRight = isLtr
              ? details == DismissDirection.startToEnd
              : details == DismissDirection.endToStart;
          if (swipedRight) {
            widget.onToggleCompleted?.call(task, !isCompleted);
          } else {
            widget.onDeleteTask?.call(task.id);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.taskDeletedToast(task.title)),
                action: SnackBarAction(
                  label: context.l10n.undoAction,
                  onPressed: () => widget.onRestoreTask?.call(task.id),
                ),
              ),
            );
          }
          return false;
        },
        child: base,
      );
    }

    return base;
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required bool alignEnd,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
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
              color: completedColor.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: completedColor.withValues(alpha: isDark ? 0.35 : 0.25),
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
                    context.l10n.completedTasksSection,
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
                    color: completedColor.withValues(alpha: 0.18),
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