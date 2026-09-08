import 'dart:async';
import 'package:flutter/material.dart';
import '../../../areas/data/models/area_model.dart';
import '../../../areas/data/repositories/area_repository_impl.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../projects/data/repositories/project_repository_impl.dart';
import '../../../tasks/data/models/subtask_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/data/repositories/subtask_repository_impl.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/sync_controller.dart';
import 'main_layout_screen.dart';

/// الشاشة الأم الحاضنة التي تربط المستودعات (Repositories) بواجهات المستخدم المتطورة
class TaskyHomeScreen extends StatefulWidget {
  const TaskyHomeScreen({super.key});

  @override
  State<TaskyHomeScreen> createState() => _TaskyHomeScreenState();
}

class _TaskyHomeScreenState extends State<TaskyHomeScreen> {
  final AreaRepositoryImpl _areaRepo = AreaRepositoryImpl();
  final ProjectRepositoryImpl _projectRepo = ProjectRepositoryImpl();
  final TaskRepositoryImpl _taskRepo = TaskRepositoryImpl();
  final SubtaskRepositoryImpl _subtaskRepo = SubtaskRepositoryImpl();

  bool _isLoading = true;
  List<AreaModel> _areas = [];
  List<ProjectModel> _projects = [];
  List<TaskModel> _tasks = [];
  List<SubtaskModel> _subtasks = [];

  Timer? _autoSyncTimer;
  bool _initialSyncDone = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      final areas = await _areaRepo.getAllAreas();
      final projects = await _projectRepo.getAllProjects();
      final tasks = await _taskRepo.getTasks();

      final allSubtasks = <SubtaskModel>[];
      for (final t in tasks) {
        final subs = await _subtaskRepo.getSubtasksForTask(t.id);
        allSubtasks.addAll(subs);
      }

      if (mounted) {
        setState(() {
          _areas = areas;
          _projects = projects;
          _tasks = tasks;
          _subtasks = allSubtasks;
          _isLoading = false;
        });
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

  Future<void> _updatePendingSyncStatus() async {
    try {
      final count = await SyncService.instance.countPendingChanges();
      SyncController.instance.updatePendingCount(count);
    } catch (_) {}
  }

  /// جدولة مزامنة تلقائية في الخلفية (Debounced Auto-Sync)
  /// تنتظر 1.5 ثانية بعد آخر تعديل لترفع البيانات دفعة واحدة دون إرهاق الشبكة
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
          // إعادة تحميل البيانات إذا طُبقت أي تحديثات قادمة من السحابة
          if (result.fetchedApplied > 0) {
            await _reloadLocalDataOnly();
          }
        } else {
          SyncController.instance.setError(result.message ?? 'تعذر إتمام المزامنة التلقائية');
        }
      } else {
        // المستخدم غير مسجل الدخول، نعيد حالة الـ pending بدون إظهار خطأ
        _updatePendingSyncStatus();
      }
    } catch (_) {
      _updatePendingSyncStatus();
    }
  }

  /// إعادة قراءة البيانات المحلية فقط دون تشغيل مزامنة إضافية
  Future<void> _reloadLocalDataOnly() async {
    try {
      final areas = await _areaRepo.getAllAreas();
      final projects = await _projectRepo.getAllProjects();
      final tasks = await _taskRepo.getTasks();

      final allSubtasks = <SubtaskModel>[];
      for (final t in tasks) {
        final subs = await _subtaskRepo.getSubtasksForTask(t.id);
        allSubtasks.addAll(subs);
      }

      if (mounted) {
        setState(() {
          _areas = areas;
          _projects = projects;
          _tasks = tasks;
          _subtasks = allSubtasks;
        });
      }
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

  // عمليات المهام
  Future<void> _handleSaveTask(TaskModel task) async {
    final existingIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (existingIndex >= 0) {
      await _taskRepo.updateTask(task);
    } else {
      await _taskRepo.insertTask(task);
    }
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteTask(String taskId) async {
    await _taskRepo.softDeleteTask(taskId);
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleTaskStatusChanged(TaskModel task, String newStatus) async {
    await _taskRepo.updateTaskStatus(task.id, newStatus);
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleToggleTaskCompleted(TaskModel task, bool isCompleted) async {
    final newStatus = isCompleted ? 'completed' : 'todo';
    await _taskRepo.updateTaskStatus(task.id, newStatus);
    await _loadAllData();
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
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleToggleSubtask(SubtaskModel subtask, bool isCompleted) async {
    await _subtaskRepo.toggleSubtaskCompletion(subtask.id, isCompleted);
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteSubtask(String subtaskId) async {
    await _subtaskRepo.softDeleteSubtask(subtaskId);
    await _loadAllData();
    _scheduleAutoSync();
  }

  // عمليات المجالات والمشاريع
  Future<void> _handleSaveArea(AreaModel area) async {
    final existing = _areas.any((a) => a.id == area.id);
    if (existing) {
      await _areaRepo.updateArea(area);
    } else {
      await _areaRepo.insertArea(area);
    }
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteArea(String areaId) async {
    await _areaRepo.softDeleteArea(areaId);
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleSaveProject(ProjectModel project) async {
    final existing = _projects.any((p) => p.id == project.id);
    if (existing) {
      await _projectRepo.updateProject(project);
    } else {
      await _projectRepo.insertProject(project);
    }
    await _loadAllData();
    _scheduleAutoSync();
  }

  Future<void> _handleDeleteProject(String projectId) async {
    await _projectRepo.softDeleteProject(projectId);
    await _loadAllData();
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
      areas: _areas,
      projects: _projects,
      tasks: _tasks,
      subtasks: _subtasks,
      onSyncRequested: _handleSyncRequested,
      onSaveTask: _handleSaveTask,
      onDeleteTask: _handleDeleteTask,
      onTaskStatusChanged: _handleTaskStatusChanged,
      onToggleTaskCompleted: _handleToggleTaskCompleted,
      onAddSubtask: _handleAddSubtask,
      onToggleSubtask: _handleToggleSubtask,
      onDeleteSubtask: _handleDeleteSubtask,
      onSaveArea: _handleSaveArea,
      onDeleteArea: _handleDeleteArea,
      onSaveProject: _handleSaveProject,
      onDeleteProject: _handleDeleteProject,
    );
  }
}
