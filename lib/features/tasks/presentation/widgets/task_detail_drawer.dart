import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../services/attachment_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/color_picker_dialog.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/subtask_model.dart';
import '../../data/models/task_model.dart';
import '../../../areas/data/models/area_model.dart';
import '../../../collaboration/presentation/widgets/universal_share_dialog.dart';
import '../../../projects/data/models/project_model.dart';
import 'task_attachments_section.dart';
import 'task_drawer/task_properties_section.dart';
import 'task_drawer/task_subtasks_section.dart';
import 'task_drawer/task_tags_section.dart';

/// درج وصفحة تفاصيل وإدارة المهمة الكاملة
class TaskDetailDrawer extends StatefulWidget {
  final TaskModel task;
  final List<SubtaskModel> subtasks;
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final List<TagModel> availableTags;
  final List<TagModel> taskTags;
  final Function(TagModel tag)? onAssignTag;
  final Function(TagModel tag)? onRemoveTag;
  final Function(String name, String colorHex)? onCreateTag;
  final Function(TaskModel updatedTask) onSaveTask;
  final Function(String taskId)? onDeleteTask;
  final Function(String title) onAddSubtask;
  final Function(SubtaskModel subtask, bool isCompleted) onToggleSubtask;
  final Function(String subtaskId) onDeleteSubtask;
  final VoidCallback? onClose;
  final AttachmentService? attachmentService;
  final double width;

  const TaskDetailDrawer({
    super.key,
    required this.task,
    this.subtasks = const [],
    this.areas = const [],
    this.projects = const [],
    this.availableTags = const [],
    this.taskTags = const [],
    this.onAssignTag,
    this.onRemoveTag,
    this.onCreateTag,
    required this.onSaveTask,
    this.onDeleteTask,
    required this.onAddSubtask,
    required this.onToggleSubtask,
    required this.onDeleteSubtask,
    this.onClose,
    this.attachmentService,
    this.width = 420,
  });

  @override
  State<TaskDetailDrawer> createState() => _TaskDetailDrawerState();
}

class _TaskDetailDrawerState extends State<TaskDetailDrawer> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late String _status;
  late String _priority;
  late String? _colorHex;
  late String _areaId;
  late String? _projectId;
  late DateTime? _dueDate;
  late DateTime? _reminderTime;
  late bool _isRecurring;
  late String _recurrencePattern;
  late int _recurrenceInterval;
  late DateTime? _recurrenceEndDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');

    _status = widget.task.status;
    _priority = widget.task.priority;
    _colorHex = widget.task.colorHex;
    _areaId = widget.task.areaId;
    _projectId = widget.task.projectId;
    _dueDate = widget.task.dueDate;
    _reminderTime = widget.task.reminderTime;
    _isRecurring = widget.task.isRecurring;
    _recurrencePattern = widget.task.recurrencePattern ?? 'daily';
    _recurrenceInterval = widget.task.recurrenceInterval;
    _recurrenceEndDate = widget.task.recurrenceEndDate;
  }

  @override
  void didUpdateWidget(covariant TaskDetailDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _titleController.text = widget.task.title;
      _descController.text = widget.task.description ?? '';
      _status = widget.task.status;
      _priority = widget.task.priority;
      _colorHex = widget.task.colorHex;
      _areaId = widget.task.areaId;
      _projectId = widget.task.projectId;
      _dueDate = widget.task.dueDate;
      _reminderTime = widget.task.reminderTime;
      _isRecurring = widget.task.isRecurring;
      _recurrencePattern = widget.task.recurrencePattern ?? 'daily';
      _recurrenceInterval = widget.task.recurrenceInterval;
      _recurrenceEndDate = widget.task.recurrenceEndDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _triggerSave() {
    final updated = widget.task.copyWith(
      title: _titleController.text.trim().isEmpty ? widget.task.title : _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      status: _status,
      priority: _priority,
      colorHex: _colorHex,
      areaId: _areaId,
      projectId: _projectId,
      dueDate: _dueDate,
      reminderTime: _reminderTime,
      isRecurring: _isRecurring,
      recurrencePattern: _isRecurring ? _recurrencePattern : null,
      recurrenceInterval: _isRecurring ? _recurrenceInterval : 1,
      recurrenceEndDate: _isRecurring ? _recurrenceEndDate : null,
    );
    if (_reminderTime != null && _status != 'completed') {
      ProjectModel? project;
      if (_projectId != null) {
        project = widget.projects.cast<ProjectModel?>().firstWhere(
          (p) => p?.id == _projectId,
          orElse: () => null,
        );
      }
      NotificationService.instance.scheduleTaskReminder(
        taskId: updated.id,
        title: updated.title,
        scheduledDate: _reminderTime!,
        project: project,
      );
    } else {
      NotificationService.instance.cancelTaskReminder(updated.id);
    }
    widget.onSaveTask(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawColor = _colorHex != null ? AppColors.fromHex(_colorHex) : null;
    final customColor = rawColor != null ? AppColors.adaptiveCustomColor(rawColor, isDark) : null;

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: BorderDirectional(
          start: BorderSide(
            color: AppColors.border(context),
            width: 1.2,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط الرأس العلوي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border(context),
                ),
              ),
            ),
            child: Row(
              children: [
                if (customColor != null)
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(color: customColor, shape: BoxShape.circle),
                  ),
                Text(
                  context.l10n.taskDetails,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // زر مشاركة المهمة
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  tooltip: context.l10n.shareTaskWithTeam,
                  onPressed: () {
                    UniversalShareDialog.show(
                      context,
                      entityType: 'task',
                      entityId: widget.task.id,
                      entityTitle: widget.task.title,
                      existingShareToken: widget.task.shareToken,
                      parentEntityIds: [
                        if (widget.task.projectId != null) widget.task.projectId!,
                        widget.task.areaId,
                      ],
                      onShareTokenChanged: (newToken) {
                        final updated = widget.task.copyWith(shareToken: newToken);
                        widget.onSaveTask(updated);
                      },
                    );
                  },
                ),

                // زر منتقي لون المهمة
                IconButton(
                  icon: Icon(Icons.palette_outlined, size: 20, color: customColor ?? Colors.grey),
                  tooltip: context.l10n.customizeTaskColor,
                  onPressed: () async {
                    final selected = await ColorPickerDialog.show(
                      context,
                      initialColorHex: _colorHex ?? '#3B82F6',
                      title: context.l10n.customTaskColor,
                    );
                    if (selected != null) {
                      setState(() => _colorHex = selected);
                      _triggerSave();
                    }
                  },
                ),
                // زر حذف المهمة
                if (widget.onDeleteTask != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    tooltip: context.l10n.deleteTask,
                    onPressed: () async {
                      final confirmed = await ConfirmDeleteDialog.show(
                        context,
                        title: context.l10n.deleteTask,
                        message: context.l10n.deleteTaskConfirm(widget.task.title),
                        confirmLabel: context.l10n.deleteTask,
                      );
                      if (confirmed && mounted) {
                        widget.onDeleteTask?.call(widget.task.id);
                        widget.onClose?.call();
                      }
                    },
                  ),
                // زر إغلاق الدرج
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: context.l10n.commonClose,
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),

          // المحتوى القابل للتمرير
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // عنوان المهمة (Inline Edit)
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: context.l10n.taskTitleEditHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => _triggerSave(),
                ),

                const SizedBox(height: 16),

                // بطاقة الخصائص السريعة
                TaskPropertiesSection(
                  status: _status,
                  priority: _priority,
                  areaId: _areaId,
                  projectId: _projectId,
                  dueDate: _dueDate,
                  reminderTime: _reminderTime,
                  isRecurring: _isRecurring,
                  recurrencePattern: _recurrencePattern,
                  recurrenceEndDate: _recurrenceEndDate,
                  areas: widget.areas,
                  projects: widget.projects,
                  onStatusChanged: (val) {
                    setState(() => _status = val);
                    _triggerSave();
                  },
                  onPriorityChanged: (val) {
                    setState(() => _priority = val);
                    _triggerSave();
                  },
                  onAreaChanged: (val) {
                    setState(() {
                      _areaId = val;
                      _projectId = null;
                    });
                    _triggerSave();
                  },
                  onProjectChanged: (val) {
                    setState(() => _projectId = val);
                    _triggerSave();
                  },
                  onDueDateChanged: (val) {
                    setState(() => _dueDate = val);
                    _triggerSave();
                  },
                  onReminderTimeChanged: (val) {
                    setState(() => _reminderTime = val);
                    _triggerSave();
                  },
                  onIsRecurringChanged: (val) {
                    setState(() => _isRecurring = val);
                    _triggerSave();
                  },
                  onRecurrencePatternChanged: (val) {
                    setState(() => _recurrencePattern = val);
                    _triggerSave();
                  },
                  onRecurrenceEndDateChanged: (val) {
                    setState(() => _recurrenceEndDate = val);
                    _triggerSave();
                  },
                ),

                const SizedBox(height: 18),

                // قسم الوسوم
                TaskTagsSection(
                  taskTags: widget.taskTags,
                  availableTags: widget.availableTags,
                  onAssignTag: widget.onAssignTag,
                  onRemoveTag: widget.onRemoveTag,
                  onCreateTag: widget.onCreateTag,
                ),

                const SizedBox(height: 20),

                // الوصف والملاحظات الفنية
                Text(
                  context.l10n.descriptionNotesLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: context.l10n.descriptionNotesHint,
                  ),
                  onChanged: (_) => _triggerSave(),
                ),

                const SizedBox(height: 24),

                // قسم المهام الفرعية (Subtasks Checklist)
                TaskSubtasksSection(
                  subtasks: widget.subtasks,
                  customColor: customColor,
                  onAddSubtask: widget.onAddSubtask,
                  onToggleSubtask: widget.onToggleSubtask,
                  onDeleteSubtask: widget.onDeleteSubtask,
                ),

                const SizedBox(height: 24),

                // قسم المرفقات (File Attachments)
                TaskAttachmentsSection(
                  taskId: widget.task.id,
                  service: widget.attachmentService,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
