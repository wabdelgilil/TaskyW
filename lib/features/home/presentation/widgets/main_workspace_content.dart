import 'package:flutter/material.dart';
import 'package:tasky/features/archive/presentation/screens/archive_screen.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/areas/presentation/screens/area_detail_screen.dart';
import 'package:tasky/features/finance/presentation/screens/financial_log_screen.dart';
import 'package:tasky/features/notes/presentation/screens/notes_screen.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/features/tasks/data/models/subtask_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/widgets/kanban_board_view.dart';
import 'package:tasky/features/tasks/presentation/widgets/task_list_view.dart';
import 'package:tasky/features/tasks/presentation/widgets/tasks_table_view.dart';
import 'package:tasky/features/trash/presentation/screens/trash_screen.dart';

/// ويدجت موزع المحتوى النشط في مساحة العمل المركزية
class MainWorkspaceContent extends StatelessWidget {
  final bool showNotes;
  final bool showFinance;
  final bool showArchive;
  final bool showTrash;
  final String? selectedProjectId;
  final String? selectedAreaId;
  final bool isSearchActive;
  final String searchText;
  final String viewMode;
  final List<TaskModel> contextTasks;
  final List<ProjectModel> projects;
  final List<AreaModel> areas;
  final List<SubtaskModel> subtasks;
  final Map<String, List<TagModel>> taskTags;

  final Function(ProjectModel project)? onSaveProject;
  final Function(String projectId)? onDeleteProject;
  final Function(AreaModel area)? onSaveArea;
  final Function(String areaId)? onDeleteArea;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task, bool isCompleted)? onToggleTaskCompleted;
  final Function(TaskModel task, String newStatus)? onTaskStatusChanged;
  final Function(TaskModel task, String newPriority)? onTaskPriorityChanged;
  final Function(String areaId)? onAddNewProject;
  final Function(String? defaultStatus)? onAddNewTask;
  final Function(String projectId)? onSelectProjectId;

  const MainWorkspaceContent({
    super.key,
    required this.showNotes,
    required this.showFinance,
    required this.showArchive,
    required this.showTrash,
    required this.selectedProjectId,
    required this.selectedAreaId,
    required this.isSearchActive,
    required this.searchText,
    required this.viewMode,
    required this.contextTasks,
    required this.projects,
    required this.areas,
    required this.subtasks,
    required this.taskTags,
    this.onSaveProject,
    this.onDeleteProject,
    this.onSaveArea,
    this.onDeleteArea,
    this.onTaskTap,
    this.onToggleTaskCompleted,
    this.onTaskStatusChanged,
    this.onTaskPriorityChanged,
    this.onAddNewProject,
    this.onAddNewTask,
    this.onSelectProjectId,
  });

  @override
  Widget build(BuildContext context) {
    // 0. شاشة الملاحظات العامة (Resources & Knowledge Vault)
    if (showNotes) {
      return const NotesScreen();
    }

    // 0.1 شاشة السجل المالي والتسويات (Financial Logs & Settlements)
    if (showFinance) {
      return const FinancialLogScreen();
    }

    // 0.2 شاشة الأرشيف العام (Global Archive)
    if (showArchive) {
      return const ArchiveScreen();
    }

    // 0.3 شاشة سلة المهملات (Trash Bin)
    if (showTrash) {
      return const TrashScreen();
    }

    // 1. إذا كان المستخدم فاتحاً صفحة مشروع مخصصة
    if (selectedProjectId != null && !isSearchActive) {
      final project = projects.firstWhere((p) => p.id == selectedProjectId);
      return ProjectDetailScreen(
        project: project,
        projectTasks: contextTasks,
        taskTags: taskTags,
        viewMode: viewMode,
        onUpdateProject: (up) => onSaveProject?.call(up),
        onDeleteProject: (id) => onDeleteProject?.call(id),
        onTaskTap: (t) => onTaskTap?.call(t),
        onToggleTaskCompleted: (t, isDone) => onToggleTaskCompleted?.call(t, isDone),
        onTaskStatusChanged: onTaskStatusChanged,
        onTaskPriorityChanged: onTaskPriorityChanged,
        onAddNewTask: () => onAddNewTask?.call(null),
      );
    }

    // 2. إذا كان المستخدم فاتحاً صفحة مجال مخصصة
    if (selectedAreaId != null && !isSearchActive) {
      final area = areas.firstWhere((a) => a.id == selectedAreaId);
      final areaProjects = projects.where((p) => p.areaId == area.id).toList();

      return AreaDetailScreen(
        area: area,
        areaProjects: areaProjects,
        areaTasks: contextTasks,
        taskTags: taskTags,
        viewMode: viewMode,
        onUpdateArea: (up) => onSaveArea?.call(up),
        onDeleteArea: (id) => onDeleteArea?.call(id),
        onProjectTap: (p) => onSelectProjectId?.call(p.id),
        onTaskTap: (t) => onTaskTap?.call(t),
        onToggleTaskCompleted: onToggleTaskCompleted,
        onTaskStatusChanged: onTaskStatusChanged,
        onTaskPriorityChanged: onTaskPriorityChanged,
        onAddNewProject: () => onAddNewProject?.call(area.id),
        onAddNewTask: () => onAddNewTask?.call(null),
      );
    }

    // 3. العرض الافتراضي (اليوم، القادمة، المعلقة، عاجل، أو نتائج البحث)
    final subtaskCounts = <String, int>{};
    final completedSubtaskCounts = <String, int>{};
    for (final s in subtasks) {
      subtaskCounts[s.taskId] = (subtaskCounts[s.taskId] ?? 0) + 1;
      if (s.isCompleted) {
        completedSubtaskCounts[s.taskId] = (completedSubtaskCounts[s.taskId] ?? 0) + 1;
      }
    }

    if (viewMode == 'kanban') {
      return KanbanBoardView(
        tasks: contextTasks,
        subtaskCounts: subtaskCounts,
        completedSubtaskCounts: completedSubtaskCounts,
        taskTags: taskTags,
        onTaskTap: (t) => onTaskTap?.call(t),
        onTaskStatusChanged: (task, status) => onTaskStatusChanged?.call(task, status),
        onAddTaskInColumn: (status) => onAddNewTask?.call(status),
      );
    }

    if (viewMode == 'table') {
      return TasksTableView(
        tasks: contextTasks,
        areas: areas,
        projects: projects,
        taskTags: taskTags,
        subtaskCounts: subtaskCounts,
        completedSubtaskCounts: completedSubtaskCounts,
        onTaskTap: (t) => onTaskTap?.call(t),
        onToggleCompleted: onToggleTaskCompleted,
        onTaskStatusChanged: (task, status) => onTaskStatusChanged?.call(task, status),
        onTaskPriorityChanged: (task, priority) => onTaskPriorityChanged?.call(task, priority),
        onAddTask: () => onAddNewTask?.call(null),
      );
    }

    return TaskListView(
      tasks: contextTasks,
      subtaskCounts: subtaskCounts,
      completedSubtaskCounts: completedSubtaskCounts,
      taskTags: taskTags,
      emptyMessage: isSearchActive
          ? 'لم يتم العثور على أي نتائج تطابق "$searchText"'
          : 'لا توجد مهام في هذا القسم حالياً',
      onTaskTap: (t) => onTaskTap?.call(t),
      onToggleCompleted: onToggleTaskCompleted,
      onAddTask: () => onAddNewTask?.call(null),
    );
  }
}
