import 'package:flutter/material.dart';
import '../../../../core/models/tag_model.dart';
import '../../../../core/services/attachment_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/color_picker_dialog.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/progress_bar_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/subtask_model.dart';
import '../../data/models/task_model.dart';
import '../../../areas/data/models/area_model.dart';
import '../../../collaboration/presentation/widgets/universal_share_dialog.dart';
import '../../../projects/data/models/project_model.dart';
import 'task_attachments_section.dart';


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
  });

  @override
  State<TaskDetailDrawer> createState() => _TaskDetailDrawerState();
}

class _TaskDetailDrawerState extends State<TaskDetailDrawer> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _newSubtaskController;

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
    _newSubtaskController = TextEditingController();

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
    _newSubtaskController.dispose();
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
      NotificationService.instance.scheduleTaskReminder(
        taskId: updated.id,
        title: updated.title,
        scheduledDate: _reminderTime!,
      );
    } else {
      NotificationService.instance.cancelTaskReminder(updated.id);
    }
    widget.onSaveTask(updated);
  }

  double get _subtaskProgress {
    if (widget.subtasks.isEmpty) return 0.0;
    final completed = widget.subtasks.where((s) => s.isCompleted).length;
    return completed / widget.subtasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawColor = _colorHex != null ? AppColors.fromHex(_colorHex) : null;
    final customColor = rawColor != null ? AppColors.adaptiveCustomColor(rawColor, isDark) : null;

    final areaProjects = widget.projects.where((p) => p.areaId == _areaId).toList();

    return Container(
      width: 420,
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
                const Text(
                  'تفاصيل المهمة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // زر مشاركة المهمة
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  tooltip: 'مشاركة المهمة مع الفريق برابط أو حساب',
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
                  tooltip: 'تخصيص لون للمهمة',
                  onPressed: () async {
                    final selected = await ColorPickerDialog.show(
                      context,
                      initialColorHex: _colorHex ?? '#3B82F6',
                      title: 'لون مخصص للمهمة',
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
                    tooltip: 'حذف المهمة',
                    onPressed: () async {
                      final confirmed = await ConfirmDeleteDialog.show(
                        context,
                        title: 'حذف المهمة',
                        message: 'هل أنت متأكد من رغبتك في حذف المهمة "${widget.task.title}"؟',
                        confirmLabel: 'حذف المهمة',
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
                    tooltip: 'إغلاق',
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
                  decoration: const InputDecoration(
                    hintText: 'عنوان المهمة...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => _triggerSave(),
                ),

                const SizedBox(height: 16),

                // بطاقات الخصائص السريعة
                _buildPropertiesCard(isDark, areaProjects),

                const SizedBox(height: 18),

                // قسم الوسوم
                _buildTagsSection(isDark),

                const SizedBox(height: 20),

                // الوصف والملاحظات الفنية
                const Text(
                  'الوصف والملاحظات:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'أدخل تفاصيل وملاحظات أو أرقام قطع الغيار...',
                  ),
                  onChanged: (_) => _triggerSave(),
                ),

                const SizedBox(height: 24),

                // قسم المهام الفرعية (Subtasks Checklist)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المهام الفرعية (Checklist)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    if (widget.subtasks.isNotEmpty)
                      Text(
                        '${widget.subtasks.where((s) => s.isCompleted).length}/${widget.subtasks.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // مؤشر التقدم
                if (widget.subtasks.isNotEmpty) ...[
                  ProgressBarWidget(
                    progress: _subtaskProgress,
                    color: customColor ?? AppColors.statusCompleted,
                    showPercentage: true,
                  ),
                  const SizedBox(height: 12),
                ],

                // قائمة المهام الفرعية
                ...widget.subtasks.map((subtask) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 0.85,
                          child: Checkbox(
                            value: subtask.isCompleted,
                            activeColor: customColor ?? AppColors.statusCompleted,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              widget.onToggleSubtask(subtask, val ?? false);
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subtask.title,
                            style: TextStyle(
                              fontSize: 13,
                              decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                              color: subtask.isCompleted ? Colors.grey : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                          splashRadius: 14,
                          onPressed: () async {
                            final confirmed = await ConfirmDeleteDialog.show(
                              context,
                              title: 'حذف المهمة الفرعية',
                              message: 'هل أنت متأكد من حذف الخطوة "${subtask.title}"؟',
                              confirmLabel: 'حذف الخطوة',
                            );
                            if (confirmed && mounted) {
                              widget.onDeleteSubtask(subtask.id);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),

                // حقل إضافة مهمة فرعية جديدة
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSubtaskController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'إضافة خطوة فرعية جديدة...',
                          isDense: true,
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            widget.onAddSubtask(val.trim());
                            _newSubtaskController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onPressed: () {
                        final text = _newSubtaskController.text.trim();
                        if (text.isNotEmpty) {
                          widget.onAddSubtask(text);
                          _newSubtaskController.clear();
                        }
                      },
                      child: const Text('إضافة'),
                    ),
                  ],
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

  Widget _buildPropertiesCard(bool isDark, List<ProjectModel> areaProjects) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          // الحالة والأولوية
          Row(
            children: [
              const SizedBox(width: 70, child: Text('الحالة:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: DropdownButton<String>(
                  value: _status,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'todo', child: StatusBadge(status: 'todo')),
                    DropdownMenuItem(value: 'in_progress', child: StatusBadge(status: 'in_progress')),
                    DropdownMenuItem(value: 'waiting', child: StatusBadge(status: 'waiting')),
                    DropdownMenuItem(value: 'review', child: StatusBadge(status: 'review')),
                    DropdownMenuItem(value: 'completed', child: StatusBadge(status: 'completed')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _status = val);
                      _triggerSave();
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              const SizedBox(width: 70, child: Text('الأولوية:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: DropdownButton<String>(
                  value: _priority,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'low', child: PriorityBadge(priority: 'low')),
                    DropdownMenuItem(value: 'medium', child: PriorityBadge(priority: 'medium')),
                    DropdownMenuItem(value: 'high', child: PriorityBadge(priority: 'high')),
                    DropdownMenuItem(value: 'urgent', child: PriorityBadge(priority: 'urgent')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _priority = val);
                      _triggerSave();
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          // المجال والمشروع
          Row(
            children: [
              const SizedBox(width: 70, child: Text('المجال:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: DropdownButton<String>(
                  value: widget.areas.any((a) => a.id == _areaId) ? _areaId : null,
                  isDense: true,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: widget.areas.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.iconEmoji} ${a.name}', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _areaId = val;
                        _projectId = null; // إعادة تعيين المشروع عند تغيير المجال
                      });
                      _triggerSave();
                    }
                  },
                ),
              ),
            ],
          ),
          if (areaProjects.isNotEmpty) ...[
            const Divider(height: 16),
            Row(
              children: [
                const SizedBox(width: 70, child: Text('المشروع:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
                Expanded(
                  child: DropdownButton<String?>(
                    value: _projectId,
                    isDense: true,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('بدون مشروع (مهمة عامة)', style: TextStyle(fontSize: 12, color: Colors.grey))),
                      ...areaProjects.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.iconEmoji} ${p.name}', style: const TextStyle(fontSize: 13)))),
                    ],
                    onChanged: (val) {
                      setState(() => _projectId = val);
                      _triggerSave();
                    },
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 16),
          // تاريخ الديدلاين
          Row(
            children: [
              const SizedBox(width: 70, child: Text('الديدلاين:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                      _triggerSave();
                    }
                  },
                  child: Text(
                    _dueDate != null ? '${_dueDate!.year}/${_dueDate!.month}/${_dueDate!.day}' : 'تعيين موعد...',
                    style: TextStyle(
                      fontSize: 13,
                      color: _dueDate != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                      fontWeight: _dueDate != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (_dueDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                  splashRadius: 12,
                  onPressed: () {
                    setState(() => _dueDate = null);
                    _triggerSave();
                  },
                ),
            ],
          ),
          const Divider(height: 16),
          // وقت التنبيه
          Row(
            children: [
              const SizedBox(width: 70, child: Text('التنبيه:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _reminderTime ?? _dueDate ?? now,
                      firstDate: now,
                      lastDate: DateTime(2035),
                    );
                    if (pickedDate != null && mounted) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime != null
                            ? TimeOfDay(hour: _reminderTime!.hour, minute: _reminderTime!.minute)
                            : const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _reminderTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                        _triggerSave();
                      }
                    }
                  },
                  child: Text(
                    _reminderTime != null
                        ? '${_reminderTime!.year}/${_reminderTime!.month}/${_reminderTime!.day} ${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                        : 'ضبط تذكير...',
                    style: TextStyle(
                      fontSize: 13,
                      color: _reminderTime != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                      fontWeight: _reminderTime != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (_reminderTime != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                  splashRadius: 12,
                  onPressed: () {
                    setState(() => _reminderTime = null);
                    _triggerSave();
                  },
                ),
            ],
          ),
          const Divider(height: 16),
          // التكرار الدوري للمهمة
          Row(
            children: [
              const SizedBox(width: 70, child: Text('التكرار:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: Row(
                  children: [
                    Switch.adaptive(
                      value: _isRecurring,
                      activeColor: const Color(0xFF8B5CF6),
                      onChanged: (val) {
                        setState(() => _isRecurring = val);
                        _triggerSave();
                      },
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isRecurring ? 'مفعّل' : 'معطّل',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _isRecurring ? FontWeight.bold : FontWeight.normal,
                        color: _isRecurring ? const Color(0xFF8B5CF6) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 70, child: Text('النمط:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
                Expanded(
                  child: DropdownButton<String>(
                    value: _recurrencePattern,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('يومياً', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'weekly', child: Text('أسبوعياً', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'monthly', child: Text('شهرياً', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _recurrencePattern = val);
                        _triggerSave();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 70, child: Text('ينتهي في:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _recurrenceEndDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _recurrenceEndDate = picked);
                        _triggerSave();
                      }
                    },
                    child: Text(
                      _recurrenceEndDate != null
                          ? '${_recurrenceEndDate!.year}/${_recurrenceEndDate!.month}/${_recurrenceEndDate!.day}'
                          : 'بدون تاريخ انتهاء (مستمر)',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _recurrenceEndDate != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (_recurrenceEndDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                    splashRadius: 12,
                    onPressed: () {
                      setState(() => _recurrenceEndDate = null);
                      _triggerSave();
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الوسوم والتصنيفات (Tags)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddTagDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('إضافة وسم', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.taskTags.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context), width: 0.8),
            ),
            child: Text(
              'لا توجد وسوم مرتبطة بهذه المهمة. اضغط "إضافة وسم" للتصنيف.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.taskTags.map((tag) {
              final rawColor = AppColors.fromHex(tag.colorHex);
              final tagColor = AppColors.adaptiveCustomColor(rawColor, isDark);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rawColor.withOpacity(isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: rawColor.withOpacity(isDark ? 0.6 : 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: rawColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tagColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => widget.onRemoveTag?.call(tag),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(Icons.close, size: 14, color: tagColor.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final available = widget.availableTags.where((t) => !widget.taskTags.any((assigned) => assigned.id == t.id)).toList();
    final newTagController = TextEditingController();
    String selectedHex = '#3B82F6';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final palette = [
              '#3B82F6', '#10B981', '#8B5CF6', '#F59E0B', '#EF4444', '#EC4899', '#06B6D4', '#64748B',
            ];

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة وسم للمهمة',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // الوسوم المتاحة للاختيار السريع
                  if (available.isNotEmpty) ...[
                    const Text('الوسوم المتاحة:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: available.map((tag) {
                        final rawColor = AppColors.fromHex(tag.colorHex);
                        final tagColor = AppColors.adaptiveCustomColor(rawColor, isDark);

                        return ActionChip(
                          avatar: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: rawColor, shape: BoxShape.circle),
                          ),
                          label: Text(tag.name, style: TextStyle(fontSize: 12, color: tagColor, fontWeight: FontWeight.w600)),
                          backgroundColor: rawColor.withOpacity(isDark ? 0.2 : 0.1),
                          side: BorderSide(color: rawColor.withOpacity(0.4)),
                          onPressed: () {
                            widget.onAssignTag?.call(tag);
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // إنشاء وسم جديد
                  const Text('أو إنشاء وسم جديد:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newTagController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'اسم الوسم (مثلاً: عاجل، قطع_غيار...)',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // باليت الألوان
                  Row(
                    children: [
                      const Text('اللون: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: palette.map((hex) {
                              final isPicked = selectedHex == hex;
                              final c = AppColors.fromHex(hex);
                              return GestureDetector(
                                onTap: () => setModalState(() => selectedHex = hex),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: isPicked ? Border.all(color: Colors.white, width: 2) : null,
                                    boxShadow: isPicked
                                        ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 4, spreadRadius: 1)]
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final name = newTagController.text.trim();
                      if (name.isNotEmpty) {
                        widget.onCreateTag?.call(name, selectedHex);
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('إنشاء وإضافة الوسم'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
