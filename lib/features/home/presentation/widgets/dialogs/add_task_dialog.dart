import 'package:flutter/material.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/widgets/color_picker_dialog.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';

/// نافذة إضافة مهمة جديدة بتفاصيلها (الحالة، الأولوية، المجال، المشروع، الموعد، واللون)
class AddTaskDialog extends StatefulWidget {
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final String? defaultStatus;
  final String? initialAreaId;
  final String? initialProjectId;
  final bool isTodayFilter;
  final Function(TaskModel task) onSaveTask;
  final VoidCallback? onNeedArea;

  const AddTaskDialog({
    super.key,
    required this.areas,
    required this.projects,
    this.defaultStatus,
    this.initialAreaId,
    this.initialProjectId,
    this.isTodayFilter = false,
    required this.onSaveTask,
    this.onNeedArea,
  });

  static Future<void> show(
    BuildContext context, {
    required List<AreaModel> areas,
    required List<ProjectModel> projects,
    String? defaultStatus,
    String? initialAreaId,
    String? initialProjectId,
    bool isTodayFilter = false,
    required Function(TaskModel task) onSaveTask,
    VoidCallback? onNeedArea,
  }) async {
    if (areas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إنشاء مجال أولاً قبل إضافة المهام.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      onNeedArea?.call();
      return;
    }

    return showDialog(
      context: context,
      builder: (ctx) => AddTaskDialog(
        areas: areas,
        projects: projects,
        defaultStatus: defaultStatus,
        initialAreaId: initialAreaId,
        initialProjectId: initialProjectId,
        isTodayFilter: isTodayFilter,
        onSaveTask: onSaveTask,
        onNeedArea: onNeedArea,
      ),
    );
  }

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _status;
  String _priority = 'medium';
  String? _colorHex;
  late String _areaId;
  String? _projectId;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _status = widget.defaultStatus ?? 'todo';
    _areaId = widget.initialAreaId ?? widget.areas.first.id;
    _projectId = widget.initialProjectId;
    _dueDate = widget.isTodayFilter ? DateTime.now() : null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final areaProjects = widget.projects.where((p) => p.areaId == _areaId).toList();

    return AlertDialog(
      title: const Text('إضافة مهمة جديدة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'عنوان المهمة *', hintText: 'ما الذي ترغب في إنجازه؟'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'ملاحظات أو وصف (اختياري)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'الحالة'),
                    items: const [
                      DropdownMenuItem(value: 'todo', child: Text('قيد الانتظار')),
                      DropdownMenuItem(value: 'in_progress', child: Text('جاري التنفيذ')),
                      DropdownMenuItem(value: 'waiting', child: Text('معلّقة')),
                      DropdownMenuItem(value: 'review', child: Text('مراجعة')),
                      DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'الأولوية'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                      DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                      DropdownMenuItem(value: 'high', child: Text('عالية')),
                      DropdownMenuItem(value: 'urgent', child: Text('عاجل جداً')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _areaId,
                    decoration: const InputDecoration(labelText: 'المجال'),
                    items: widget.areas.map((a) {
                      return DropdownMenuItem(value: a.id, child: Text('${a.iconEmoji} ${a.name}'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _areaId = val;
                          _projectId = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _projectId,
                    decoration: const InputDecoration(labelText: 'المشروع'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('بدون مشروع')),
                      ...areaProjects.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.iconEmoji} ${p.name}'))),
                    ],
                    onChanged: (val) => setState(() => _projectId = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // زر تعيين الديدلاين
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_dueDate != null ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}' : 'تاريخ التسليم'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                ),
                const Spacer(),
                // زر اختيار لون المهمة
                IconButton(
                  icon: Icon(Icons.palette_outlined, color: _colorHex != null ? AppColors.fromHex(_colorHex!) : Colors.grey),
                  tooltip: 'لون مخصص للمهمة',
                  onPressed: () async {
                    final selected = await ColorPickerDialog.show(context, initialColorHex: _colorHex ?? '#3B82F6');
                    if (selected != null) setState(() => _colorHex = selected);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            final text = _titleCtrl.text.trim();
            if (text.isNotEmpty) {
              final newTask = TaskModel(
                id: 'task-${DateTime.now().millisecondsSinceEpoch}',
                areaId: _areaId,
                projectId: _projectId,
                title: text,
                description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
                status: _status,
                priority: _priority,
                colorHex: _colorHex,
                dueDate: _dueDate,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              );
              widget.onSaveTask(newTask);
              Navigator.of(context).pop();
            }
          },
          child: const Text('إضافة المهمة'),
        ),
      ],
    );
  }
}
