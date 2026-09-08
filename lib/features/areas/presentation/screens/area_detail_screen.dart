import 'package:flutter/material.dart';
import '../../../../core/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/color_picker_dialog.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/emoji_picker_dialog.dart';
import '../../../../core/widgets/progress_bar_widget.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/widgets/task_list_view.dart';
import '../../data/models/area_model.dart';

/// صفحة تفاصيل وإدارة المجال المتكاملة
class AreaDetailScreen extends StatelessWidget {
  final AreaModel area;
  final List<ProjectModel> areaProjects;
  final List<TaskModel> areaTasks;
  final Map<String, List<TagModel>> taskTags;
  final Function(AreaModel updatedArea) onUpdateArea;
  final Function(String areaId) onDeleteArea;
  final Function(ProjectModel project)? onProjectTap;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleTaskCompleted;
  final VoidCallback? onAddNewProject;
  final VoidCallback? onAddNewTask;

  const AreaDetailScreen({
    super.key,
    required this.area,
    required this.areaProjects,
    required this.areaTasks,
    this.taskTags = const {},
    required this.onUpdateArea,
    required this.onDeleteArea,
    this.onProjectTap,
    this.onTaskTap,
    this.onToggleTaskCompleted,
    this.onAddNewProject,
    this.onAddNewTask,
  });

  int get _completedTasksCount => areaTasks.where((t) => t.status == 'completed').length;
  double get _overallProgress => areaTasks.isEmpty ? 0.0 : _completedTasksCount / areaTasks.length;

  void _showEditAreaDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: area.name);
    String emoji = area.iconEmoji;
    String colorHex = area.colorHex;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final aColor = AppColors.fromHex(colorHex);
          return AlertDialog(
            title: const Text('تعديل بيانات المجال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            color: aColor.withOpacity(0.15),
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
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(width: 16, height: 16, decoration: BoxDecoration(color: aColor, shape: BoxShape.circle)),
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
                    decoration: const InputDecoration(labelText: 'اسم المجال'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final updated = area.copyWith(
                      name: nameCtrl.text.trim(),
                      iconEmoji: emoji,
                      colorHex: colorHex,
                    );
                    onUpdateArea(updated);
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
    final rawAreaColor = AppColors.fromHex(area.colorHex);
    final areaColor = AppColors.adaptiveCustomColor(rawAreaColor, isDark);
    final standaloneTasks = areaTasks.where((t) => t.projectId == null).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // كارت الرأس ونظرة عامة للمجال
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
                        color: Colors.black.withOpacity(0.04),
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
                        color: areaColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: areaColor.withOpacity(0.5)),
                      ),
                      child: Text(area.iconEmoji, style: const TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'مجال مسؤولية يضم ${areaProjects.length} مشاريع و ${areaTasks.length} مهام',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'تعديل المجال',
                      onPressed: () => _showEditAreaDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      tooltip: 'حذف المجال',
                      onPressed: () async {
                        final confirmed = await ConfirmDeleteDialog.show(
                          context,
                          title: 'حذف المجال',
                          message: 'هل أنت متأكد من رغبتك في حذف مجال "${area.name}" وجميع المشاريع والمهام التابعة له؟ لا يمكن التراجع عن هذا الإجراء.',
                          confirmLabel: 'حذف المجال بالكامل',
                        );
                        if (confirmed) {
                          onDeleteArea(area.id);
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
                              const Text('معدل إنجاز المجال العام:', style: TextStyle(fontSize: 12.5, color: Colors.grey)),
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

          const SizedBox(height: 24),

          // قسم المشاريع التابعة للمجال
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('المشاريع التابعة للمجال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: areaColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${areaProjects.length}',
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
                onPressed: onAddNewProject,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('مشروع جديد'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (areaProjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: const Text('لا توجد مشاريع مضافة تحت هذا المجال بعد', style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: areaProjects.map((p) {
                final pTasks = areaTasks.where((t) => t.projectId == p.id).toList();
                final pDone = pTasks.where((t) => t.status == 'completed').length;
                final pProg = pTasks.isEmpty ? 0.0 : pDone / pTasks.length;
                final pColor = AppColors.fromHex(p.colorHex);

                return InkWell(
                  onTap: () => onProjectTap?.call(p),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border(context)),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.iconEmoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ProgressBarWidget(progress: pProg, color: pColor, height: 6),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$pDone/${pTasks.length} مهام', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                            Text('${(pProg * 100).toInt()}%', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: pColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 28),

          // قسم المهام المستقلة التابعة للمجال مباشرة (دون مشروع)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('مهام عامة تابعة للمجال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${standaloneTasks.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onAddNewTask,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('إضافة مهمة عامة'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (standaloneTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: const Text('لا توجد مهام عامة خارج المشاريع لهذا المجال', style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            TaskListView(
              tasks: standaloneTasks,
              taskTags: taskTags,
              onTaskTap: onTaskTap,
              onToggleCompleted: onToggleTaskCompleted,
              onAddTask: onAddNewTask,
            ),
        ],
      ),
    );
  }
}
