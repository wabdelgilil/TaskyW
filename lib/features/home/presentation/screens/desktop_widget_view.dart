import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/utils/date_time_utils.dart';
import 'package:tasky/core/services/desktop_widget_controller.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';

/// واجهة الودجت المصغرة لسطح المكتب (Desktop Floating Mini Widget)
/// مصممة خصيصاً للشاشات والنوافذ المدمجة (Compact Floating Mode)
class DesktopWidgetView extends StatefulWidget {
  final List<TaskModel> tasks;
  final List<ProjectModel> projects;
  final List<AreaModel> areas;
  final Function(TaskModel task)? onSaveTask;
  final Function(TaskModel task, bool isCompleted)? onToggleTaskCompleted;
  final Function(String taskId)? onDeleteTask;

  const DesktopWidgetView({
    super.key,
    required this.tasks,
    required this.projects,
    required this.areas,
    this.onSaveTask,
    this.onToggleTaskCompleted,
    this.onDeleteTask,
  });

  @override
  State<DesktopWidgetView> createState() => _DesktopWidgetViewState();
}

class _DesktopWidgetViewState extends State<DesktopWidgetView> {
  String _filter = 'today'; // 'today', 'all', 'urgent'
  final TextEditingController _quickAddController = TextEditingController();
  final FocusNode _quickAddFocus = FocusNode();

  @override
  void dispose() {
    _quickAddController.dispose();
    _quickAddFocus.dispose();
    super.dispose();
  }

  List<TaskModel> get _filteredTasks {
    final activeTasks = widget.tasks.where((t) => t.status != 'completed').toList();
    switch (_filter) {
      case 'today':
        return activeTasks.where((t) => DateTimeUtils.isToday(t.dueDate)).toList();
      case 'urgent':
        return activeTasks.where((t) => t.priority == 'urgent' || t.priority == 'high').toList();
      case 'all':
      default:
        return activeTasks;
    }
  }

  void _submitQuickAdd() {
    final title = _quickAddController.text.trim();
    if (title.isEmpty) return;

    final newTask = TaskModel(
      id: const Uuid().v4(),
      areaId: widget.areas.isNotEmpty ? widget.areas.first.id : 'default',
      title: title,
      status: 'pending',
      priority: _filter == 'urgent' ? 'urgent' : 'medium',
      dueDate: _filter == 'today' ? DateTime.now() : null,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    widget.onSaveTask?.call(newTask);
    _quickAddController.clear();
    _quickAddFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final desktopCtrl = DesktopWidgetController.instance;

    final todayCount = widget.tasks
        .where((t) => t.status != 'completed' && DateTimeUtils.isToday(t.dueDate))
        .length;
    final allCount = widget.tasks.where((t) => t.status != 'completed').length;
    final urgentCount = widget.tasks
        .where((t) => t.status != 'completed' && (t.priority == 'urgent' || t.priority == 'high'))
        .length;

    final tasksToShow = _filteredTasks;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ─── 1. شريط الرأس القابل للسحب (Draggable Titlebar) ───
            DragToMoveArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // شعار وعنوان Tasky
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradientSimple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tasky',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$allCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // زر التثبيت فوق النوافذ (Always on Top)
                    ListenableBuilder(
                      listenable: desktopCtrl,
                      builder: (context, _) {
                        final isPinned = desktopCtrl.isAlwaysOnTop;
                        return IconButton(
                          icon: Icon(
                            isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                            size: 18,
                            color: isPinned ? AppColors.brandPrimary : Colors.grey,
                          ),
                          tooltip: l10n.desktopWidgetAlwaysOnTop,
                          onPressed: () => desktopCtrl.toggleAlwaysOnTop(),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),

                    // زر العودة إلى النافذة الكاملة (Restore to Full App)
                    IconButton(
                      icon: const Icon(Icons.open_in_full_rounded, size: 17),
                      tooltip: l10n.desktopWidgetExpand,
                      onPressed: () => desktopCtrl.exitWidgetMode(),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            // ─── 2. فلاتر التبويب السريعة ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  _FilterChip(
                    label: '${l10n.desktopWidgetFilterToday} ($todayCount)',
                    isSelected: _filter == 'today',
                    onTap: () => setState(() => _filter = 'today'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: '${l10n.desktopWidgetFilterAll} ($allCount)',
                    isSelected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: '${l10n.desktopWidgetFilterUrgent} ($urgentCount)',
                    isSelected: _filter == 'urgent',
                    onTap: () => setState(() => _filter = 'urgent'),
                  ),
                ],
              ),
            ),

            // ─── 3. قائمة المهام القابلة للتمرير ───
            Expanded(
              child: tasksToShow.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 40,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.desktopWidgetEmpty,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      itemCount: tasksToShow.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final task = tasksToShow[index];
                        return _MiniTaskTile(
                          task: task,
                          projects: widget.projects,
                          isDark: isDark,
                          onToggle: (done) => widget.onToggleTaskCompleted?.call(task, done),
                          onDelete: () => widget.onDeleteTask?.call(task.id),
                        );
                      },
                    ),
            ),

            // ─── 4. شريط الإضافة السريع بالأسفل ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quickAddController,
                      focusNode: _quickAddFocus,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: l10n.desktopWidgetQuickAddHint,
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.brandPrimary),
                        ),
                      ),
                      onSubmitted: (_) => _submitQuickAdd(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _submitQuickAdd,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniTaskTile extends StatelessWidget {
  final TaskModel task;
  final List<ProjectModel> projects;
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _MiniTaskTile({
    required this.task,
    required this.projects,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final project = projects.cast<ProjectModel?>().firstWhere(
          (p) => p?.id == task.projectId,
          orElse: () => null,
        );

    final priorityColor = switch (task.priority.toLowerCase()) {
      'urgent' => const Color(0xFFEF4444),
      'high' => const Color(0xFFF97316),
      'low' => const Color(0xFF94A3B8),
      _ => AppColors.brandPrimary,
    };

    final isCompleted = task.status == 'completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // شريط مؤشر الأولوية
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),

          // علامة الإنجاز (Checkbox)
          InkWell(
            onTap: () => onToggle(!isCompleted),
            child: Icon(
              isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: isCompleted ? AppColors.statusCompleted : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),

          // تفاصيل المهمة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? Colors.grey
                        : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (project != null || task.dueDate != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (project != null) ...[
                        Text(
                          '📁 ${project.name}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.dueDate != null)
                          const Text(' • ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                      if (task.dueDate != null)
                        Text(
                          '📅 ${DateTimeUtils.formatFriendlyDate(task.dueDate)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: DateTimeUtils.isToday(task.dueDate)
                                ? const Color(0xFFF59E0B)
                                : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // زر الحذف السريع
          IconButton(
            icon: const Icon(Icons.close, size: 14, color: Colors.grey),
            onPressed: onDelete,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
