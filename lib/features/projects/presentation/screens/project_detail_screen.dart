import 'package:flutter/material.dart';
import '../../../../core/models/tag_model.dart';
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final pColor = AppColors.fromHex(colorHex);
          return AlertDialog(
            title: const Text('تعديل بيانات المشروع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              const Text('اللون', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم المشروع'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'وصف المشروع (اختياري)'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'حالة المشروع'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('نشط (Active)')),
                      DropdownMenuItem(value: 'on_hold', child: Text('معلّق مؤقتاً (On Hold)')),
                      DropdownMenuItem(value: 'completed', child: Text('مكتمل (Completed)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => status = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final updated = widget.project.copyWith(
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      iconEmoji: emoji,
                      colorHex: colorHex,
                      status: status,
                    );
                    widget.onUpdateProject(updated);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('حفظ التعديلات'),
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
                    // زر مشاركة المشروع
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      tooltip: 'مشاركة المشروع مع الفريق',
                      onPressed: () {
                        UniversalShareDialog.show(
                          context,
                          entityType: 'project',
                          entityId: widget.project.id,
                          entityTitle: widget.project.name,
                        );
                      },
                    ),

                    // أزرار التحكم
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'تعديل المشروع',
                      onPressed: _showEditProjectDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      tooltip: 'حذف المشروع',
                      onPressed: () async {
                        final confirmed = await ConfirmDeleteDialog.show(
                          context,
                          title: 'حذف المشروع',
                          message: 'هل أنت متأكد من رغبتك في حذف مشروع "${widget.project.name}" وجميع المهام التابعة له؟ لا يمكن التراجع عن هذا الإجراء.',
                          confirmLabel: 'حذف المشروع',
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
                              const Text('نسبة إنجاز المشروع:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                '${(_progress * 100).toInt()}% ($_completedTasksCount/${widget.projectTasks.length} مكتملة)',
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
                              '$_urgentTasksCount عاجلة',
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
                  label: const Text('إضافة مهمة في المشروع'),
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
                        emptyMessage: 'لا توجد مهام مضافة لهذا المشروع حتى الآن',
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
