import 'package:flutter/material.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/features/tasks/data/models/subtask_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/widgets/task_detail_drawer.dart';

/// فتح تفاصيل المهمة في نافذة سفلية (Bottom Sheet) لشاشات الموبايل
/// بدلاً من درج التفاصيل الجانبي على الشاشات الكبيرة.
Future<void> showTaskDetailBottomSheet(
  BuildContext context, {
  required TaskModel task,
  required List<SubtaskModel> subtasks,
  required List<AreaModel> areas,
  required List<ProjectModel> projects,
  required List<TagModel> availableTags,
  required List<TagModel> taskTags,
  required void Function(TagModel tag) onAssignTag,
  required void Function(TagModel tag) onRemoveTag,
  required void Function(String name, String colorHex) onCreateTag,
  required void Function(TaskModel updatedTask) onSaveTask,
  required void Function(String taskId) onDeleteTask,
  required void Function(String title) onAddSubtask,
  required void Function(SubtaskModel subtask, bool isCompleted)
      onToggleSubtask,
  required void Function(String subtaskId) onDeleteSubtask,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // مقبض سحب لتقليل النافذة
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: TaskDetailDrawer(
                  task: task,
                  subtasks: subtasks,
                  areas: areas,
                  projects: projects,
                  availableTags: availableTags,
                  taskTags: taskTags,
                  onAssignTag: onAssignTag,
                  onRemoveTag: onRemoveTag,
                  onCreateTag: onCreateTag,
                  onSaveTask: onSaveTask,
                  onDeleteTask: onDeleteTask,
                  onAddSubtask: onAddSubtask,
                  onToggleSubtask: onToggleSubtask,
                  onDeleteSubtask: onDeleteSubtask,
                  onClose: () {
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}