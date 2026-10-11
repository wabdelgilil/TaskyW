import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/color_picker_dialog.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/emoji_picker_dialog.dart';
import '../../../../core/widgets/progress_bar_widget.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/widgets/kanban_board_view.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/widgets/tasks_table_view.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../collaboration/presentation/widgets/universal_share_dialog.dart';
import '../../data/models/area_model.dart';

/// صفحة تفاصيل وإدارة المجال المتكاملة
/// تدعم نمطين للمستخدم:
/// 1. مهام ومشاريع المجال: تظهر كل المشاريع وتحتها مهامها مباشرة تفاعلية وقابلة للطي.
/// 2. إدارة المشاريع: شاشة نظيفة لإدارة ومتابعة كروت ونسب مشاريع المجال دون زحمة.
class AreaDetailScreen extends StatefulWidget {
  final AreaModel area;
  final List<ProjectModel> areaProjects;
  final List<TaskModel> areaTasks;
  final Map<String, List<TagModel>> taskTags;
  final String viewMode;
  final Function(AreaModel updatedArea) onUpdateArea;
  final Function(String areaId) onDeleteArea;
  final Function(ProjectModel project)? onProjectTap;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleTaskCompleted;
  final Function(TaskModel task, String newStatus)? onTaskStatusChanged;
  final Function(TaskModel task, String newPriority)? onTaskPriorityChanged;
  final VoidCallback? onAddNewProject;
  final VoidCallback? onAddNewTask;
  final Function(String? projectId)? onAddNewTaskForProject;
  final Function(String taskId)? onDeleteTask;
  final Function(String taskId)? onRestoreTask;
  final Function(String taskId)? onArchiveTask;

  const AreaDetailScreen({
    super.key,
    required this.area,
    required this.areaProjects,
    required this.areaTasks,
    this.taskTags = const {},
    this.viewMode = 'list',
    required this.onUpdateArea,
    required this.onDeleteArea,
    this.onProjectTap,
    this.onTaskTap,
    this.onToggleTaskCompleted,
    this.onTaskStatusChanged,
    this.onTaskPriorityChanged,
    this.onAddNewProject,
    this.onAddNewTask,
    this.onAddNewTaskForProject,
    this.onDeleteTask,
    this.onRestoreTask,
    this.onArchiveTask,
  });

  @override
  State<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends State<AreaDetailScreen> {
  // 0: مهام ومشاريع المجال (Tasks & Projects View)، 1: إدارة المشاريع (Projects Hub)
  int _activeTabIndex = 0;

  // معرفات المشاريع المطوية
  final Set<String> _collapsedProjectIds = {};
  bool _unassignedTasksCollapsed = false;

  int get _completedTasksCount => widget.areaTasks.where((t) => t.status == 'completed').length;
  double get _overallProgress =>
      widget.areaTasks.isEmpty ? 0.0 : _completedTasksCount / widget.areaTasks.length;

  void _toggleProjectCollapsed(String projectId) {
    setState(() {
      if (_collapsedProjectIds.contains(projectId)) {
        _collapsedProjectIds.remove(projectId);
      } else {
        _collapsedProjectIds.add(projectId);
      }
    });
  }

  void _collapseAll() {
    setState(() {
      _collapsedProjectIds.addAll(widget.areaProjects.map((p) => p.id));
      _unassignedTasksCollapsed = true;
    });
  }

  void _expandAll() {
    setState(() {
      _collapsedProjectIds.clear();
      _unassignedTasksCollapsed = false;
    });
  }

  void _showEditAreaDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: widget.area.name);
    String emoji = widget.area.iconEmoji;
    String colorHex = widget.area.colorHex;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final aColor = AppColors.fromHex(colorHex);
          return AlertDialog(
            title: Text(
              context.l10n.editAreaData,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final selected = await EmojiPickerDialog.show(context, initialEmoji: emoji);
                          if (selected != null) setDialogState(() => emoji = selected);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: aColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: aColor),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          final selected = await ColorPickerDialog.show(context, initialColorHex: colorHex);
                          if (selected != null) setDialogState(() => colorHex = selected);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(color: aColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(context.l10n.colorLabel, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: context.l10n.areaName),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(context.l10n.commonCancel)),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final updated = widget.area.copyWith(
                      name: nameCtrl.text.trim(),
                      iconEmoji: emoji,
                      colorHex: colorHex,
                    );
                    widget.onUpdateArea(updated);
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(context.l10n.saveChanges),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawAreaColor = AppColors.fromHex(widget.area.colorHex);
    final areaColor = AppColors.adaptiveCustomColor(rawAreaColor, isDark);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── كارت رأس المجال ونظرة عامة ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border(context)),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: areaColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: areaColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(widget.area.iconEmoji, style: const TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.area.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.areaStats(widget.areaProjects.length, widget.areaTasks.length),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // زر مشاركة المجال
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      tooltip: l10n.shareAreaWithTeam,
                      onPressed: () {
                        UniversalShareDialog.show(
                          context,
                          entityType: 'area',
                          entityId: widget.area.id,
                          entityTitle: widget.area.name,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: l10n.editArea,
                      onPressed: () => _showEditAreaDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      tooltip: l10n.deleteArea,
                      onPressed: () async {
                        final confirmed = await ConfirmDeleteDialog.show(
                          context,
                          title: l10n.deleteArea,
                          message: context.l10n.deleteAreaConfirm(widget.area.name),
                          confirmLabel: l10n.deleteAreaFully,
                        );
                        if (confirmed) {
                          widget.onDeleteArea(widget.area.id);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // مؤشر إنجاز المجال الشامل
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.areaCompletionRate, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
                              Text(
                                '${(_overallProgress * 100).toInt()}%',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: areaColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ProgressBarWidget(
                            progress: _overallProgress,
                            color: areaColor,
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ─── محوّل التبويبين لاختيار طريقة العرض المفضلة ─────────────
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                // التبويب 1: مهام ومشاريع المجال (Projects & Tasks View)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 0),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 0
                            ? (isDark ? AppColors.surface(context) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _activeTabIndex == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.checklist_rounded,
                            size: 18,
                            color: _activeTabIndex == 0 ? areaColor : AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.areaTabTasksAndProjects,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: _activeTabIndex == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _activeTabIndex == 0 ? areaColor : AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: (_activeTabIndex == 0 ? areaColor : Colors.grey).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.areaTasks.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _activeTabIndex == 0 ? areaColor : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // التبويب 2: إدارة المشاريع (Projects Hub)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 1),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 1
                            ? (isDark ? AppColors.surface(context) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _activeTabIndex == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_special_outlined,
                            size: 18,
                            color: _activeTabIndex == 1 ? areaColor : AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.areaTabManageProjects,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: _activeTabIndex == 1 ? FontWeight.bold : FontWeight.w500,
                              color: _activeTabIndex == 1 ? areaColor : AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: (_activeTabIndex == 1 ? areaColor : Colors.grey).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.areaProjects.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _activeTabIndex == 1 ? areaColor : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─── محتوى التبويب المختار ──────────────────────────────────
          if (_activeTabIndex == 0)
            _buildTasksAndProjectsView(context, isDark, areaColor, l10n)
          else
            _buildProjectsHubView(context, isDark, areaColor, l10n),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // التبويب الأول: مهام ومشاريع المجال (عرض المهام مجمعة ومتاحة للتعامل الفوري)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTasksAndProjectsView(
    BuildContext context,
    bool isDark,
    Color areaColor,
    dynamic l10n,
  ) {
    if (widget.viewMode == 'kanban') {
      return KanbanBoardView(
        tasks: widget.areaTasks,
        projects: widget.areaProjects,
        taskTags: widget.taskTags,
        onTaskTap: widget.onTaskTap,
        onTaskStatusChanged: (task, status) => widget.onTaskStatusChanged?.call(task, status),
        onAddTaskInColumn: (_) => widget.onAddNewTask?.call(),
      );
    }

    if (widget.viewMode == 'table') {
      return TasksTableView(
        tasks: widget.areaTasks,
        projects: widget.areaProjects,
        areas: [widget.area],
        taskTags: widget.taskTags,
        onTaskTap: widget.onTaskTap,
        onToggleCompleted: widget.onToggleTaskCompleted,
        onTaskStatusChanged: (task, status) => widget.onTaskStatusChanged?.call(task, status),
        onTaskPriorityChanged: (task, priority) => widget.onTaskPriorityChanged?.call(task, priority),
        onArchiveTask: widget.onArchiveTask,
        onAddTask: widget.onAddNewTask,
      );
    }

    // نمط القائمة (List View) المتطور مع أقسام مشاريع قابلة للطي والتعامل
    final standaloneTasks = widget.areaTasks.where((t) => t.projectId == null).toList();
    final hasProjects = widget.areaProjects.isNotEmpty;
    final allCollapsed = _collapsedProjectIds.length >= widget.areaProjects.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // شريط أدوات القسم
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  l10n.areaTabTasksAndProjects,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: areaColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.areaTasks.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: areaColor),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (hasProjects)
                  TextButton.icon(
                    onPressed: allCollapsed ? _expandAll : _collapseAll,
                    icon: Icon(allCollapsed ? Icons.unfold_more_rounded : Icons.unfold_less_rounded, size: 16),
                    label: Text(allCollapsed ? l10n.expandAll : l10n.collapseAll, style: const TextStyle(fontSize: 12.5)),
                  ),
                const SizedBox(width: 4),
                OutlinedButton.icon(
                  onPressed: widget.onAddNewTask,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.createTask),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (widget.areaTasks.isEmpty && widget.areaProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment_outlined, size: 40, color: Colors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 8),
                Text(l10n.noTasksRegistered, style: const TextStyle(color: Colors.grey, fontSize: 13.5)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: widget.onAddNewTask,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.createTask),
                ),
              ],
            ),
          ),

        // 1. أقسام المشاريع التابعة للمجال (كل مشروع تحته مهامه مباشرة)
        for (final project in widget.areaProjects) ...[
          _buildProjectTasksAccordion(context, project, isDark, l10n),
          const SizedBox(height: 12),
        ],

        // 2. قسم المهام العامة التابعة للمجال مباشرة (بدون مشروع)
        if (standaloneTasks.isNotEmpty || !hasProjects)
          _buildStandaloneTasksAccordion(context, standaloneTasks, isDark, areaColor, l10n),
      ],
    );
  }

  /// أكورديون مشروع بمظهره الأنيق وقائمة مهامه المباشرة
  Widget _buildProjectTasksAccordion(
    BuildContext context,
    ProjectModel project,
    bool isDark,
    dynamic l10n,
  ) {
    final pTasks = widget.areaTasks.where((t) => t.projectId == project.id).toList();
    final pDone = pTasks.where((t) => t.status == 'completed').length;
    final pProg = pTasks.isEmpty ? 0.0 : pDone / pTasks.length;
    final pColor = AppColors.adaptiveCustomColor(AppColors.fromHex(project.colorHex), isDark);
    final isCollapsed = _collapsedProjectIds.contains(project.id);
    final activeTasks = pTasks.where((t) => t.status != 'completed').toList();
    final completedTasks = pTasks.where((t) => t.status == 'completed').toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pColor.withValues(alpha: isDark ? 0.35 : 0.25)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط رأس المشروع التفاعلي
          InkWell(
            onTap: () => _toggleProjectCollapsed(project.id),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(14),
              bottom: isCollapsed ? const Radius.circular(14) : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: pColor.withValues(alpha: isDark ? 0.10 : 0.06),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(14),
                  bottom: isCollapsed ? const Radius.circular(14) : Radius.zero,
                ),
              ),
              child: Row(
                children: [
                  Text(project.iconEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            project.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: pColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$pDone/${pTasks.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: pColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // مؤشر التقدم
                  SizedBox(
                    width: 70,
                    child: ProgressBarWidget(progress: pProg, color: pColor, height: 6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(pProg * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: pColor),
                  ),
                  const SizedBox(width: 8),
                  // زر إضافة مهمة في هذا المشروع تحديداً
                  IconButton(
                    icon: const Icon(Icons.add, size: 19),
                    tooltip: l10n.addProjectTask,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      if (widget.onAddNewTaskForProject != null) {
                        widget.onAddNewTaskForProject!(project.id);
                      } else {
                        widget.onAddNewTask?.call();
                      }
                    },
                  ),
                  // زر فتح صفحة المشروع المنفصلة
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 17),
                    tooltip: project.name,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => widget.onProjectTap?.call(project),
                  ),
                  // سهم الطي/التوسيع
                  Icon(
                    isCollapsed ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                    size: 22,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // قائمة مهام المشروع
          if (!isCollapsed) ...[
            if (pTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.noTasksInProject,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: pColor,
                      ),
                      onPressed: () {
                        if (widget.onAddNewTaskForProject != null) {
                          widget.onAddNewTaskForProject!(project.id);
                        } else {
                          widget.onAddNewTask?.call();
                        }
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: Text(l10n.addProjectTask, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (final task in activeTasks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: task,
                          onTap: () => widget.onTaskTap?.call(task),
                          onToggleCompleted: (done) =>
                              widget.onToggleTaskCompleted?.call(task, done ?? false),
                          onArchive: () => widget.onArchiveTask?.call(task.id),
                          projectName: project.name,
                          projectEmoji: project.iconEmoji,
                          projectColor: pColor,
                          tags: widget.taskTags[task.id] ?? const [],
                          isCompact: SettingsController.instance.isCompactCards,
                        ),
                      ),
                    if (completedTasks.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      for (final task in completedTasks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(
                            task: task,
                            onTap: () => widget.onTaskTap?.call(task),
                            onToggleCompleted: (done) =>
                                widget.onToggleTaskCompleted?.call(task, done ?? false),
                            onArchive: () => widget.onArchiveTask?.call(task.id),
                            projectName: project.name,
                            projectEmoji: project.iconEmoji,
                            projectColor: pColor,
                            tags: widget.taskTags[task.id] ?? const [],
                            isCompact: SettingsController.instance.isCompactCards,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// أكورديون المهام العامة التابعة للمجال مباشرة (خارج المشاريع)
  Widget _buildStandaloneTasksAccordion(
    BuildContext context,
    List<TaskModel> standaloneTasks,
    bool isDark,
    Color areaColor,
    dynamic l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _unassignedTasksCollapsed = !_unassignedTasksCollapsed),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(14),
              bottom: _unassignedTasksCollapsed ? const Radius.circular(14) : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(14),
                  bottom: _unassignedTasksCollapsed ? const Radius.circular(14) : Radius.zero,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inbox_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          l10n.unassignedAreaTasks,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${standaloneTasks.length}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 19),
                    tooltip: l10n.createTask,
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onAddNewTask,
                  ),
                  Icon(
                    _unassignedTasksCollapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 22,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (!_unassignedTasksCollapsed) ...[
            if (standaloneTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.areaNoGeneralTasks,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (final task in standaloneTasks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: task,
                          onTap: () => widget.onTaskTap?.call(task),
                          onToggleCompleted: (done) =>
                              widget.onToggleTaskCompleted?.call(task, done ?? false),
                          onArchive: () => widget.onArchiveTask?.call(task.id),
                          tags: widget.taskTags[task.id] ?? const [],
                          isCompact: SettingsController.instance.isCompactCards,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // التبويب الثاني: إدارة المشاريع (Projects Hub - كروت نظيفة بدون زحمة)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildProjectsHubView(
    BuildContext context,
    bool isDark,
    Color areaColor,
    dynamic l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(l10n.areaProjects, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: areaColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.areaProjects.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: areaColor),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: areaColor,
                foregroundColor: Colors.white,
              ),
              onPressed: widget.onAddNewProject,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.newProject),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (widget.areaProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              children: [
                Icon(Icons.folder_open_outlined, size: 44, color: Colors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 10),
                Text(l10n.areaNoProjects, style: const TextStyle(color: Colors.grey, fontSize: 13.5)),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: areaColor, foregroundColor: Colors.white),
                  onPressed: widget.onAddNewProject,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.newProject),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.areaProjects.map((p) {
              final pTasks = widget.areaTasks.where((t) => t.projectId == p.id).toList();
              final pDone = pTasks.where((t) => t.status == 'completed').length;
              final pProg = pTasks.isEmpty ? 0.0 : pDone / pTasks.length;
              final pColor = AppColors.adaptiveCustomColor(AppColors.fromHex(p.colorHex), isDark);

              return InkWell(
                onTap: () => widget.onProjectTap?.call(p),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 270,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: pColor.withValues(alpha: isDark ? 0.4 : 0.25)),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: pColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(p.iconEmoji, style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (p.description != null && p.description!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    p.description!,
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProgressBarWidget(progress: pProg, color: pColor, height: 6),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.taskCounter(pDone, pTasks.length),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${(pProg * 100).toInt()}%',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: pColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
