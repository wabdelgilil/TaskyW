import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/color_picker_dialog.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/emoji_picker_dialog.dart';
import '../../../../core/widgets/progress_bar_widget.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/widgets/kanban_board_view.dart';
import '../../../tasks/presentation/widgets/task_list_view.dart';
import '../../../tasks/presentation/widgets/tasks_table_view.dart';
import '../../../collaboration/presentation/widgets/universal_share_dialog.dart';
import '../../data/models/project_model.dart';



/// صفحة تفاصيل وإدارة المشروع المتكاملة
class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;
  final List<TaskModel> projectTasks;
  final Map<String, List<TagModel>> taskTags;
  final String viewMode;
  final Function(ProjectModel updatedProject) onUpdateProject;
  final Function(String projectId) onDeleteProject;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleTaskCompleted;
  final Function(TaskModel task, String newStatus)? onTaskStatusChanged;
  final Function(TaskModel task, String newPriority)? onTaskPriorityChanged;
  final VoidCallback? onAddNewTask;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectTasks,
    this.taskTags = const {},
    this.viewMode = 'list',
    required this.onUpdateProject,
    required this.onDeleteProject,
    this.onTaskTap,
    this.onToggleTaskCompleted,
    this.onTaskStatusChanged,
    this.onTaskPriorityChanged,
    this.onAddNewTask,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {

  int get _completedTasksCount => widget.projectTasks.where((t) => t.status == 'completed').length;
  int get _urgentTasksCount => widget.projectTasks.where((t) => t.priority == 'urgent' && t.status != 'completed').length;
  double get _progress => widget.projectTasks.isEmpty ? 0.0 : _completedTasksCount / widget.projectTasks.length;

  void _showEditProjectDialog() {
    final nameCtrl = TextEditingController(text: widget.project.name);
    final descCtrl = TextEditingController(text: widget.project.description ?? '');
    String emoji = widget.project.iconEmoji;
    String colorHex = widget.project.colorHex;
    String status = widget.project.status;
    bool notificationsEnabled = widget.project.notificationsEnabled;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final pColor = AppColors.fromHex(colorHex);
          return AlertDialog(
            title: Text(context.l10n.editProjectData, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // زر اختيار الإيموجي
                      InkWell(
                        onTap: () async {
                          final selected = await EmojiPickerDialog.show(context, initialEmoji: emoji);
                          if (selected != null) setDialogState(() => emoji = selected);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: pColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: pColor),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // زر اختيار اللون
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
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(width: 16, height: 16, decoration: BoxDecoration(color: pColor, shape: BoxShape.circle)),
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
                    decoration: InputDecoration(labelText: context.l10n.projectName),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: context.l10n.projectDescription),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(labelText: context.l10n.projectStatus),
                    items: [
                      DropdownMenuItem(value: 'active', child: Text(context.l10n.projectStatusActive)),
                      DropdownMenuItem(value: 'on_hold', child: Text(context.l10n.projectStatusOnHold)),
                      DropdownMenuItem(value: 'completed', child: Text(context.l10n.projectStatusCompleted)),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => status = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.projectNotifications),
                    value: notificationsEnabled,
                    onChanged: (val) => setDialogState(() => notificationsEnabled = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(context.l10n.commonCancel)),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final updated = widget.project.copyWith(
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      iconEmoji: emoji,
                      colorHex: colorHex,
                      status: status,
                      notificationsEnabled: notificationsEnabled,
                    );
                    widget.onUpdateProject(updated);
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
    final rawProjectColor = AppColors.fromHex(widget.project.colorHex);
    final projectColor = AppColors.adaptiveCustomColor(rawProjectColor, isDark);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس صفحة المشروع (Project Header & Overview Card)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              border: Border(
                bottom: BorderSide(color: AppColors.border(context)),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: projectColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: projectColor.withOpacity(0.5)),
                      ),
                      child: Text(widget.project.iconEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.project.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: projectColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.project.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: projectColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.project.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.project.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // زر كتم/تفعيل إشعارات المشروع
                    IconButton(
                      icon: Icon(
                        widget.project.notificationsEnabled
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        size: 20,
                        color: widget.project.notificationsEnabled
                            ? AppColors.statusInProgress
                            : AppColors.textMuted(context),
                      ),
                      tooltip: widget.project.notificationsEnabled
                          ? l10n.muteProjectNotifications
                          : l10n.enableProjectNotifications,
                      onPressed: () {
                        final newEnabled = !widget.project.notificationsEnabled;
                        final updated = widget.project.copyWith(
                          notificationsEnabled: newEnabled,
                          updatedAt: DateTime.now().toUtc(),
                        );
                        widget.onUpdateProject(updated);
                        if (!newEnabled) {
                          final taskIds = widget.projectTasks
                              .where((t) => t.reminderTime != null && t.status != 'completed')
                              .map((t) => t.id);
                          NotificationService.instance.cancelRemindersForTasks(taskIds);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newEnabled ? l10n.projectNotifEnabledToast : l10n.projectNotifMutedToast,
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    // زر مشاركة المشروع
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      tooltip: l10n.shareProjectWithTeam,
                      onPressed: () {
                        UniversalShareDialog.show(
                          context,
                          entityType: 'project',
                          entityId: widget.project.id,
                          entityTitle: widget.project.name,
                          parentEntityIds: [widget.project.areaId],
                        );
                      },
                    ),

                    // أزرار التحكم
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: l10n.editProject,
                      onPressed: _showEditProjectDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      tooltip: l10n.deleteProject,
                      onPressed: () async {
                        final confirmed = await ConfirmDeleteDialog.show(
                          context,
                          title: l10n.deleteProject,
                          message: context.l10n.deleteProjectConfirm(widget.project.name),
                          confirmLabel: context.l10n.deleteProject,
                        );
                        if (confirmed && mounted) {
                          widget.onDeleteProject(widget.project.id);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // شريط التقدم ومؤشرات الأداء (KPIs)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.projectCompletionRate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                context.l10n.projectProgress((_progress * 100).toInt(), _completedTasksCount, widget.projectTasks.length),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: projectColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ProgressBarWidget(
                            progress: _progress,
                            color: projectColor,
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                    if (_urgentTasksCount > 0) ...[
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.priorityUrgent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.priorityUrgent.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.priorityUrgent),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.urgentCount(_urgentTasksCount),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.priorityUrgent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // شريط أدوات المهام (زر إضافة مهمة)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: projectColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.onAddNewTask,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addTaskInProject),
                ),
              ],
            ),
          ),

          // محتوى المهام (List أو Kanban أو Table حسب اختيار الهيدر)
          Expanded(
            child: widget.viewMode == 'kanban'
                ? KanbanBoardView(
                    tasks: widget.projectTasks,
                    taskTags: widget.taskTags,
                    onTaskTap: widget.onTaskTap,
                    onTaskStatusChanged: (task, status) => widget.onTaskStatusChanged?.call(task, status),
                    onAddTaskInColumn: (_) => widget.onAddNewTask?.call(),
                  )
                : widget.viewMode == 'table'
                    ? TasksTableView(
                        tasks: widget.projectTasks,
                        projects: [widget.project],
                        taskTags: widget.taskTags,
                        onTaskTap: widget.onTaskTap,
                        onToggleCompleted: widget.onToggleTaskCompleted,
                        onTaskStatusChanged: (task, status) => widget.onTaskStatusChanged?.call(task, status),
                        onTaskPriorityChanged: (task, priority) => widget.onTaskPriorityChanged?.call(task, priority),
                        onAddTask: widget.onAddNewTask,
                      )
                    : TaskListView(
                        tasks: widget.projectTasks,
                        taskTags: widget.taskTags,
                        emptyMessage: l10n.projectNoTasks,
                        onTaskTap: widget.onTaskTap,
                        onToggleCompleted: widget.onToggleTaskCompleted,
                        onAddTask: widget.onAddNewTask,
                      ),
          ),
        ],
      ),
    );
  }
}
