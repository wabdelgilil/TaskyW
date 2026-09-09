import 'package:flutter/foundation.dart';

import '../../services/recurrence_service.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/subtask_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/i_subtask_repository.dart';
import '../../domain/repositories/i_task_repository.dart';

/// إدارة حالة المهام مع فلاتر حسابية فورية للعروض الذكية.
class TasksController extends ChangeNotifier {
  TasksController({
    ITaskRepository? repository,
    ISubtaskRepository? subtaskRepository,
  })  : _repository = repository ?? TaskRepositoryImpl(),
        _subtaskRepository = subtaskRepository ?? SubtaskRepositoryImpl();

  final ITaskRepository _repository;
  final ISubtaskRepository _subtaskRepository;
  List<TaskModel> _tasks = <TaskModel>[];
  bool _isLoading = false;

  // قوائم الأرشفة وسلة المهملات
  List<TaskModel> _archivedTasks = <TaskModel>[];
  List<TaskModel> _trashTasks = <TaskModel>[];
  bool _isLoadingArchived = false;
  bool _isLoadingTrash = false;
  String? _lastArchivedAreaId;
  String? _lastArchivedProjectId;

  String? _lastAreaId;
  String? _lastProjectId;
  String? _lastStatus;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  /// مهام اليوم غير المكتملة.
  List<TaskModel> get todayTasks => _tasks
      .where((t) => DateTimeUtils.isToday(t.dueDate) && t.status != 'completed')
      .toList();

  /// المهام القادمة غير المكتملة.
  List<TaskModel> get upcomingTasks => _tasks
      .where((t) => DateTimeUtils.isUpcoming(t.dueDate) && t.status != 'completed')
      .toList();

  /// المهام قيد الانتظار.
  List<TaskModel> get waitingTasks =>
      _tasks.where((t) => t.status == 'waiting').toList();

  /// المهام العاجلة غير المكتملة.
  List<TaskModel> get urgentTasks => _tasks
      .where((t) => t.priority == 'urgent' && t.status != 'completed')
      .toList();

  /// المهام المكتملة.
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.status == 'completed').toList();

  // ─── الأرشفة وسلة المهملات (Archive & Trash System) ───────────────────
  List<TaskModel> get archivedTasks => List.unmodifiable(_archivedTasks);
  List<TaskModel> get trashTasks => List.unmodifiable(_trashTasks);
  int get archivedCount => _archivedTasks.length;
  int get trashCount => _trashTasks.length;
  bool get isLoadingArchived => _isLoadingArchived;
  bool get isLoadingTrash => _isLoadingTrash;

  Future<void> loadTasks({
    String? areaId,
    String? projectId,
    String? status,
  }) async {
    _lastAreaId = areaId;
    _lastProjectId = projectId;
    _lastStatus = status;
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _repository.getTasks(
        areaId: areaId,
        projectId: projectId,
        status: status,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(TaskModel task) async {
    await _repository.insertTask(task);
    await _reloadWithLastFilters();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
    await _reloadWithLastFilters();
  }

  Future<void> updateStatus(String taskId, String newStatus) async {
    final current = await _repository.getTaskById(taskId);
    await _repository.updateTaskStatus(taskId, newStatus);
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now().toUtc(),
      );
    }

    if (newStatus == 'completed' && current != null) {
      final next = await RecurrenceService.generateNextRecurrence(
        current,
        taskRepo: _repository,
        subtaskRepo: _subtaskRepository,
      );
      if (next != null) {
        await _reloadWithLastFilters();
        return;
      }
    }
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.softDeleteTask(taskId);
    await _reloadWithLastFilters();
  }

  // ─── الأرشفة وسلة المهملات (Archive & Trash System) ───────────────────

  Future<void> loadArchivedTasks({
    String? areaId,
    String? projectId,
  }) async {
    _lastArchivedAreaId = areaId;
    _lastArchivedProjectId = projectId;
    _isLoadingArchived = true;
    notifyListeners();
    try {
      _archivedTasks = await _repository.getArchivedTasks(
        areaId: areaId,
        projectId: projectId,
      );
    } finally {
      _isLoadingArchived = false;
      notifyListeners();
    }
  }

  Future<void> loadTrashTasks() async {
    _isLoadingTrash = true;
    notifyListeners();
    try {
      _trashTasks = await _repository.getTrashTasks();
    } finally {
      _isLoadingTrash = false;
      notifyListeners();
    }
  }

  /// نقل مهمة إلى الأرشيف وإشعار المستمعين.
  Future<bool> archiveTask(String id) async {
    try {
      await _repository.archiveTask(id);
      await _reloadWithLastFilters();
      await loadArchivedTasks(
        areaId: _lastArchivedAreaId,
        projectId: _lastArchivedProjectId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// استعادة مهمة من الأرشيف للعمل النشط.
  Future<bool> unarchiveTask(String id, {String targetStatus = 'todo'}) async {
    try {
      await _repository.unarchiveTask(id, targetStatus: targetStatus);
      await _reloadWithLastFilters();
      await loadArchivedTasks(
        areaId: _lastArchivedAreaId,
        projectId: _lastArchivedProjectId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// استرجاع مهمة من سلة المهملات وإعادتها للقوائم النشطة.
  Future<bool> restoreTask(String id) async {
    try {
      await _repository.restoreTaskFromTrash(id);
      await _reloadWithLastFilters();
      await loadTrashTasks();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// حذف نهائي لا رجعة فيه.
  Future<bool> permanentlyDeleteTask(String id) async {
    try {
      await _repository.permanentlyDeleteTask(id);
      await loadTrashTasks();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// تفريغ سلة المهملات بالكامل.
  Future<bool> emptyTrash() async {
    try {
      await _repository.emptyTrash();
      _trashTasks = <TaskModel>[];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _reloadWithLastFilters() => loadTasks(
        areaId: _lastAreaId,
        projectId: _lastProjectId,
        status: _lastStatus,
      );
}