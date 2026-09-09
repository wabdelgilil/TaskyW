import 'package:flutter/material.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/widgets/confirm_delete_dialog.dart';
import 'package:tasky/core/widgets/progress_bar_widget.dart';
import 'package:tasky/features/tasks/data/models/subtask_model.dart';

/// مكون قائمة المهام الفرعية ومؤشر التقدم
class TaskSubtasksSection extends StatefulWidget {
  final List<SubtaskModel> subtasks;
  final Color? customColor;
  final Function(String title) onAddSubtask;
  final Function(SubtaskModel subtask, bool isCompleted) onToggleSubtask;
  final Function(String subtaskId) onDeleteSubtask;

  const TaskSubtasksSection({
    super.key,
    required this.subtasks,
    this.customColor,
    required this.onAddSubtask,
    required this.onToggleSubtask,
    required this.onDeleteSubtask,
  });

  @override
  State<TaskSubtasksSection> createState() => _TaskSubtasksSectionState();
}

class _TaskSubtasksSectionState extends State<TaskSubtasksSection> {
  late final TextEditingController _newSubtaskController;

  @override
  void initState() {
    super.initState();
    _newSubtaskController = TextEditingController();
  }

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  double get _subtaskProgress {
    if (widget.subtasks.isEmpty) return 0.0;
    final completed = widget.subtasks.where((s) => s.isCompleted).length;
    return completed / widget.subtasks.length;
  }

  void _handleAddSubtask() {
    final text = _newSubtaskController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddSubtask(text);
      _newSubtaskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.customColor ?? AppColors.statusCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

        if (widget.subtasks.isNotEmpty) ...[
          ProgressBarWidget(
            progress: _subtaskProgress,
            color: activeColor,
            showPercentage: true,
          ),
          const SizedBox(height: 12),
        ],

        ...widget.subtasks.map((subtask) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Checkbox(
                    value: subtask.isCompleted,
                    activeColor: activeColor,
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
              onPressed: _handleAddSubtask,
              child: const Text('إضافة'),
            ),
          ],
        ),
      ],
    );
  }
}
