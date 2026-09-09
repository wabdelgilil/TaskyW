import 'package:flutter/material.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/task_model.dart';
import '../../../areas/data/models/area_model.dart';
import '../../../projects/data/models/project_model.dart';

/// مكوّن جدول بيانات تفاعلي متقدم للمهام (DataGrid / Table View)
/// مستوحى من جداول Notion مع دعم التعديل الفوري داخل الخلايا والفرز التفاعلي.
class TasksTableView extends StatefulWidget {
  final List<TaskModel> tasks;
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final Map<String, List<TagModel>> taskTags;
  final Map<String, int> subtaskCounts;
  final Map<String, int> completedSubtaskCounts;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleCompleted;
  final Function(TaskModel task, String newStatus)? onTaskStatusChanged;
  final Function(TaskModel task, String newPriority)? onTaskPriorityChanged;
  final VoidCallback? onAddTask;

  const TasksTableView({
    super.key,
    required this.tasks,
    this.areas = const [],
    this.projects = const [],
    this.taskTags = const {},
    this.subtaskCounts = const {},
    this.completedSubtaskCounts = const {},
    this.onTaskTap,
    this.onToggleCompleted,
    this.onTaskStatusChanged,
    this.onTaskPriorityChanged,
    this.onAddTask,
  });

  @override
  State<TasksTableView> createState() => _TasksTableViewState();
}

enum _SortColumn { title, status, priority, dueDate }

class _TasksTableViewState extends State<TasksTableView> {
  _SortColumn _sortColumn = _SortColumn.dueDate;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onSort(_SortColumn column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  List<TaskModel> get _sortedTasks {
    final list = List<TaskModel>.from(widget.tasks);
    list.sort((a, b) {
      int cmp = 0;
      switch (_sortColumn) {
        case _SortColumn.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case _SortColumn.status:
          cmp = a.status.compareTo(b.status);
          break;
        case _SortColumn.priority:
          final pMap = {'urgent': 4, 'high': 3, 'medium': 2, 'low': 1};
          final pA = pMap[a.priority] ?? 0;
          final pB = pMap[b.priority] ?? 0;
          cmp = pA.compareTo(pB);
          break;
        case _SortColumn.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            cmp = 0;
          } else if (a.dueDate == null) {
            cmp = 1;
          } else if (b.dueDate == null) {
            cmp = -1;
          } else {
            cmp = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = _sortedTasks;

    if (sorted.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_rows_outlined, size: 60, color: Theme.of(context).hintColor.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              'لا توجد مهام لعرضها في الجدول',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
            ),
            if (widget.onAddTask != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onAddTask,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مهمة جديدة'),
              ),
            ],
          ],
        ),
      );
    }

    final projectMap = {for (final p in widget.projects) p.id: p};
    final areaMap = {for (final a in widget.areas) a.id: a};

    return Scrollbar(
      controller: _verticalScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 950),
              child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: WidgetStateProperty.all(
              isDark ? AppColors.surface(context) : Colors.grey.shade100,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.hovered)) {
                return Theme.of(context).colorScheme.primary.withValues(alpha: 0.05);
              }
              return null;
            }),
            columnSpacing: 18,
            horizontalMargin: 16,
            dividerThickness: 1.0,
            columns: [
              const DataColumn(
                label: SizedBox(
                  width: 32,
                  child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              DataColumn(
                label: InkWell(
                  onTap: () => _onSort(_SortColumn.title),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('عنوان المهمة', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_sortColumn == _SortColumn.title)
                        Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                    ],
                  ),
                ),
              ),
              DataColumn(
                label: InkWell(
                  onTap: () => _onSort(_SortColumn.status),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_sortColumn == _SortColumn.status)
                        Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                    ],
                  ),
                ),
              ),
              DataColumn(
                label: InkWell(
                  onTap: () => _onSort(_SortColumn.priority),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('الأولوية', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_sortColumn == _SortColumn.priority)
                        Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                    ],
                  ),
                ),
              ),
              DataColumn(
                label: InkWell(
                  onTap: () => _onSort(_SortColumn.dueDate),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('تاريخ الاستحقاق', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_sortColumn == _SortColumn.dueDate)
                        Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                    ],
                  ),
                ),
              ),
              const DataColumn(
                label: Text('المجال / المشروع', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const DataColumn(
                label: Text('الوسوم', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const DataColumn(
                label: Text('المهام الفرعية', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: sorted.map((task) {
              final isCompleted = task.status == 'completed';
              final totalSubs = widget.subtaskCounts[task.id] ?? 0;
              final doneSubs = widget.completedSubtaskCounts[task.id] ?? 0;
              final tags = widget.taskTags[task.id] ?? const [];

              // اسم المشروع والمجال
              final project = task.projectId != null ? projectMap[task.projectId] : null;
              final area = areaMap[task.areaId];

              return DataRow(
                onSelectChanged: (_) => widget.onTaskTap?.call(task),
                cells: [
                  // 1. زر إكمال المهمة
                  DataCell(
                    Checkbox(
                      value: isCompleted,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        widget.onToggleCompleted?.call(task, val ?? false);
                      },
                    ),
                  ),

                  // 2. العنوان + شارة التكرار
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.isRecurring) ...[
                            Container(
                              padding: const EdgeInsets.all(3),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.repeat, size: 13, color: Colors.purple),
                            ),
                          ],
                          Flexible(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted
                                    ? AppColors.textSecondary(context).withValues(alpha: 0.6)
                                    : AppColors.textPrimary(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. الحالة (تعديل مباشر عبر قائمة منسدلة داخل الخلية)
                  DataCell(
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: task.status,
                        isDense: true,
                        borderRadius: BorderRadius.circular(8),
                        items: const [
                          DropdownMenuItem(value: 'todo', child: StatusBadge(status: 'todo')),
                          DropdownMenuItem(value: 'in_progress', child: StatusBadge(status: 'in_progress')),
                          DropdownMenuItem(value: 'waiting', child: StatusBadge(status: 'waiting')),
                          DropdownMenuItem(value: 'review', child: StatusBadge(status: 'review')),
                          DropdownMenuItem(value: 'completed', child: StatusBadge(status: 'completed')),
                        ],
                        onChanged: (newStatus) {
                          if (newStatus != null && newStatus != task.status) {
                            widget.onTaskStatusChanged?.call(task, newStatus);
                          }
                        },
                      ),
                    ),
                  ),

                  // 4. الأولوية (تعديل مباشر عبر قائمة منسدلة داخل الخلية)
                  DataCell(
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: task.priority,
                        isDense: true,
                        borderRadius: BorderRadius.circular(8),
                        items: const [
                          DropdownMenuItem(value: 'low', child: PriorityBadge(priority: 'low')),
                          DropdownMenuItem(value: 'medium', child: PriorityBadge(priority: 'medium')),
                          DropdownMenuItem(value: 'high', child: PriorityBadge(priority: 'high')),
                          DropdownMenuItem(value: 'urgent', child: PriorityBadge(priority: 'urgent')),
                        ],
                        onChanged: (newPriority) {
                          if (newPriority != null && newPriority != task.priority) {
                            widget.onTaskPriorityChanged?.call(task, newPriority);
                          }
                        },
                      ),
                    ),
                  ),

                  // 5. تاريخ الاستحقاق
                  DataCell(
                    task.dueDate != null
                        ? _buildDueDateCell(task.dueDate!, isCompleted, context)
                        : Text('-', style: TextStyle(color: Theme.of(context).hintColor)),
                  ),

                  // 6. النطاق (المشروع / المجال)
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (project != null) ...[
                            Text(project.iconEmoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                project.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else if (area != null) ...[
                            Text(area.iconEmoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                area.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else
                            Text('-', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ),

                  // 7. الوسوم
                  DataCell(
                    tags.isNotEmpty
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: [
                                ...tags.take(2).map((t) {
                                  final color = AppColors.fromHex(t.colorHex);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t.name,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  );
                                }),
                                if (tags.length > 2)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text(
                                      '+${tags.length - 2}',
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Text('-', style: TextStyle(color: Theme.of(context).hintColor)),
                  ),

                  // 8. المهام الفرعية
                  DataCell(
                    totalSubs > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                doneSubs == totalSubs ? Icons.check_circle : Icons.checklist,
                                size: 14,
                                color: doneSubs == totalSubs ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$doneSubs/$totalSubs',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: doneSubs == totalSubs ? Colors.green : Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : Text('-', style: TextStyle(color: Theme.of(context).hintColor)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildDueDateCell(DateTime dueDate, bool isCompleted, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isPast = target.isBefore(today) && !isCompleted;
    final isToday = target.isAtSameMomentAs(today);

    Color textColor = AppColors.textPrimary(context);
    if (isPast) textColor = Colors.red;
    if (isToday) textColor = Colors.orange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 13,
          color: textColor,
        ),
        const SizedBox(width: 5),
        Text(
          '${dueDate.year}/${dueDate.month}/${dueDate.day}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isPast || isToday ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
