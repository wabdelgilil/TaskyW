import 'package:flutter/foundation.dart';

import '../../../../core/services/recurrence_service.dart';
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

  Future<void> _reloadWithLastFilters() => loadTasks(
        areaId: _lastAreaId,
        projectId: _lastProjectId,
        status: _lastStatus,
      );
}