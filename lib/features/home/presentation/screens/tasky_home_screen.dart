import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/core/services/sync_controller.dart';
import 'package:tasky/core/services/sync_service.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/areas/presentation/controllers/areas_controller.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/projects/presentation/controllers/projects_controller.dart';
import 'package:tasky/features/tags/presentation/controllers/tags_controller.dart';
import 'package:tasky/features/tasks/data/models/subtask_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/subtask_repository_impl.dart';
import 'package:tasky/features/tasks/presentation/controllers/tasks_controller.dart';
import 'main_layout_screen.dart';

/// الشاشة الأم الحاضنة التي تربط المتحكمات المركزية (Controllers) بواجهات المستخدم المتطورة
class TaskyHomeScreen extends StatefulWidget {
  final TasksController? tasksController;
  final AreasController? areasController;
  final ProjectsController? projectsController;
  final TagsController? tagsController;

  const TaskyHomeScreen({
    super.key,
    this.tasksController,
    this.areasController,
    this.projectsController,
    this.tagsController,
  });

  @override
  State<TaskyHomeScreen> createState() => _TaskyHomeScreenState();
}

class _TaskyHomeScreenState extends State<TaskyHomeScreen> {
  late final TasksController _tasksController;
  late final AreasController _areasController;
  late final ProjectsController _projectsController;
  late final TagsController _tagsController;
  final SubtaskRepositoryImpl _subtaskRepo = SubtaskRepositoryImpl();

  bool _isLoading = true;
  List<SubtaskModel> _subtasks = [];
  Map<String, List<TagModel>> _taskTags = {};

  Timer? _autoSyncTimer;
  bool _initialSyncDone = false;

  @override
  void initState() {
    super.initState();
    _tasksController = widget.tasksController ?? TasksController();
    _areasController = widget.areasController ?? AreasController();
    _projectsController = widget.projectsController ?? ProjectsController();
    _tagsController = widget.tagsController ?? TagsController();

    _tasksController.addListener(_onControllerStateChanged);
    _areasController.addListener(_onControllerStateChanged);
    _projectsController.addListener(_onControllerStateChanged);
    _tagsController.addListener(_onControllerStateChanged);

    _loadAllData();
  }

  void _onControllerStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    _tasksController.removeListener(_onControllerStateChanged);
    _areasController.removeListener(_onControllerStateChanged);
    _projectsController.removeListener(_onControllerStateChanged);
    _tagsController.removeListener(_onControllerStateChanged);

    if (widget.tasksController == null) _tasksController.dispose();
    if (widget.areasController == null) _areasController.dispose();
    if (widget.projectsController == null) _projectsController.dispose();
    if (widget.tagsController == null) _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      await Future.wait([
        _areasController.loadAreas(),
        _projectsController.loadProjects(),
        _tasksController.loadTasks(),
        _tagsController.loadTags(),
      ]);

      await _loadSubtasksAndTagsMap();

      if (mounted) {
        setState(() => _isLoading = false);
      }
      _updatePendingSyncStatus();

      // مزامنة تلقائية أولية عند بدء التطبيق لسحب أي تحديثات من الأجهزة الأخرى
      if (!_initialSyncDone) {
        _initialSyncDone = true;
        _handleSilentSync();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubtasksAndTagsMap() async {
    final allSubtasks = <SubtaskModel>[];
    final taskTagsMap = <String, List<TagModel>>{};
    for (final t in _tasksController.tasks) {
      final subs = await _subtaskRepo.getSubtasksForTask(t.id);
      allSubtasks.addAll(subs);
      taskTagsMap[t.id] = await _tagsController.getTagsForTask(t.id);
    }
    if (mounted) {
      setState(() {
        _subtasks = allSubtasks;
        _taskTags = taskTagsMap;
      });
    }
  }

  Future<void> _updatePendingSyncStatus() async {
    try {
      final count = await SyncService.instance.countPendingChanges();
      SyncController.instance.updatePendingCount(count);
    } catch (_) {}
  }

  /// جدولة مزامنة تلقائية في الخلفية (Debounced Auto-Sync)
  void _scheduleAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer(const Duration(milliseconds: 1500), () {
      _handleSilentSync();
    });
  }

  /// مزامنة هادئة تلقائية بدون إظهار رسائل خطأ مزعجة إذا كان المستخدم غير متصل
  Future<void> _handleSilentSync() async {
    try {
      SyncController.instance.startSyncing();
      final result = await SyncService.instance.syncNow();
      if (result.authenticated) {
        if (result.success) {
          SyncController.instance.setSynced();
          if (result.fetchedApplied > 0) {
            await _reloadLocalDataOnly();
          }
        } else {
          SyncController.instance.setError(result.message ?? 'تعذر إتمام المزامنة التلقائية');
        }
      } else {
        _updatePendingSyncStatus();
      }
    } catch (_) {
      _updatePendingSyncStatus();
    }
  }

  /// إعادة قراءة البيانات المحلية فقط دون تشغيل مزامنة إضافية
  Future<void> _reloadLocalDataOnly() async {
    try {
      await Future.wait([
        _areasController.loadAreas(),
        _projectsController.loadProjects(),
        _tasksController.loadTasks(),
        _tagsController.loadTags(),
      ]);
      await _loadSubtasksAndTagsMap();
      _updatePendingSyncStatus();
    } catch (_) {}
  }

  Future<void> _handleSyncRequested() async {
    _autoSyncTimer?.cancel();
    SyncController.instance.startSyncing();
    final result = await SyncService.instance.syncNow();
    if (result.authenticated) {
      if (result.success) {
        SyncController.instance.setSynced();
      } else {
        SyncController.instance.setError(result.message ?? 'اكتملت المزامنة مع بعض الأخطاء');
      }
      await _reloadLocalDataOnly();
    } else {
      SyncController.instance.setError(result.message ?? 'يجب تسجيل الدخول لمزامنة البيانات');
    }
  }

  // عمليات المهام عبر TasksController
  Future<void> _handleSaveTask(TaskModel task) async {
    final existing = _tasksController.tasks.any((t) => t.id == task.id);
    if (existing) {
      await _tasksController.updateTask(task);
    } else {
      await _tasksController.createTask(task);
    }
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteTask(String taskId) async {
    await _tasksController.deleteTask(taskId);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  Future<void> _handleTaskStatusChanged(TaskModel task, String newStatus) async {
    await _tasksController.updateStatus(task.id, newStatus);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  Future<void> _handleTaskPriorityChanged(TaskModel task, String newPriority) async {
    final updated = task.copyWith(
      priority: newPriority,
      updatedAt: DateTime.now().toUtc(),
    );
    await _tasksController.updateTask(updated);
    _scheduleAutoSync();
  }

  Future<void> _handleToggleTaskCompleted(TaskModel task, bool isCompleted) async {
    final newStatus = isCompleted ? 'completed' : 'todo';
    await _tasksController.updateStatus(task.id, newStatus);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  // عمليات المهام الفرعية
  Future<void> _handleAddSubtask(String taskId, String title) async {
    final newSubtask = SubtaskModel(
      id: 'subtask-${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      title: title,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await _subtaskRepo.insertSubtask(newSubtask);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  Future<void> _handleToggleSubtask(SubtaskModel subtask, bool isCompleted) async {
    await _subtaskRepo.toggleSubtaskCompletion(subtask.id, isCompleted);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteSubtask(String subtaskId) async {
    await _subtaskRepo.softDeleteSubtask(subtaskId);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  // عمليات الوسوم عبر TagsController
  Future<void> _handleCreateTag(String name, String colorHex) async {
    await _tagsController.createTag(name: name, colorHex: colorHex);
    _scheduleAutoSync();
  }

  Future<void> _handleAssignTag(TaskModel task, TagModel tag) async {
    await _tagsController.assignTagToTask(task.id, tag.id);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  Future<void> _handleRemoveTag(TaskModel task, TagModel tag) async {
    await _tagsController.removeTagFromTask(task.id, tag.id);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteTag(TagModel tag) async {
    await _tagsController.deleteTag(tag.id);
    await _loadSubtasksAndTagsMap();
    _scheduleAutoSync();
  }

  // عمليات المجالات والمشاريع عبر AreasController و ProjectsController
  Future<void> _handleSaveArea(AreaModel area) async {
    final existing = _areasController.areas.any((a) => a.id == area.id);
    if (existing) {
      await _areasController.updateArea(area);
    } else {
      await _areasController.createArea(
        name: area.name,
        iconEmoji: area.iconEmoji,
        colorHex: area.colorHex,
      );
    }
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteArea(String areaId) async {
    await _areasController.deleteArea(areaId);
    _scheduleAutoSync();
  }

  Future<void> _handleSaveProject(ProjectModel project) async {
    final existing = _projectsController.projects.any((p) => p.id == project.id);
    if (existing) {
      await _projectsController.updateProject(project);
    } else {
      await _projectsController.createProject(
        areaId: project.areaId,
        name: project.name,
        description: project.description,
        iconEmoji: project.iconEmoji,
        colorHex: project.colorHex,
        targetDate: project.targetDate,
      );
    }
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteProject(String projectId) async {
    await _projectsController.deleteProject(projectId);
    _scheduleAutoSync();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MainLayoutScreen(
      areas: _areasController.areas,
      projects: _projectsController.projects,
      tasks: _tasksController.tasks,
      subtasks: _subtasks,
      tags: _tagsController.tags,
      taskTags: _taskTags,
      onSyncRequested: _handleSyncRequested,
      onSaveTask: _handleSaveTask,
      onDeleteTask: _handleDeleteTask,
      onTaskStatusChanged: _handleTaskStatusChanged,
      onTaskPriorityChanged: _handleTaskPriorityChanged,
      onToggleTaskCompleted: _handleToggleTaskCompleted,
      onAddSubtask: _handleAddSubtask,
      onToggleSubtask: _handleToggleSubtask,
      onDeleteSubtask: _handleDeleteSubtask,
      onSaveArea: _handleSaveArea,
      onDeleteArea: _handleDeleteArea,
      onSaveProject: _handleSaveProject,
      onDeleteProject: _handleDeleteProject,
      onAssignTag: _handleAssignTag,
      onRemoveTag: _handleRemoveTag,
      onCreateTag: _handleCreateTag,
      onDeleteTag: _handleDeleteTag,
    );
  }
}
