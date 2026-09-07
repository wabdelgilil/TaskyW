import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/subtask_model.dart';
import '../../data/repositories/subtask_repository_impl.dart';
import '../../domain/repositories/i_subtask_repository.dart';

/// إدارة المهام الفرعية لمهمة محددة مع حساب نسبة الإنجاز.
class SubtasksController extends ChangeNotifier {
  SubtasksController({ISubtaskRepository? repository})
      : _repository = repository ?? SubtaskRepositoryImpl();

  final ISubtaskRepository _repository;
  final Map<String, List<SubtaskModel>> _subtasksByTask =
      <String, List<SubtaskModel>>{};
  final Map<String, double> _progressCache = <String, double>{};

  Future<void> loadSubtasks(String taskId) async {
    final list = await _repository.getSubtasksForTask(taskId);
    _subtasksByTask[taskId] = list;
    _computeProgress(taskId);
    notifyListeners();
  }

  List<SubtaskModel> getSubtasks(String taskId) =>
      List.unmodifiable(_subtasksByTask[taskId] ?? <SubtaskModel>[]);

  Future<void> toggleCompletion(String subtaskId, bool isCompleted) async {
    await _repository.toggleSubtaskCompletion(subtaskId, isCompleted);
    for (final entry in _subtasksByTask.entries) {
      final list = entry.value;
      final index = list.indexWhere((s) => s.id == subtaskId);
      if (index != -1) {
        list[index] = list[index].copyWith(
          isCompleted: isCompleted,
          updatedAt: DateTime.now().toUtc(),
        );
        _computeProgress(entry.key);
        notifyListeners();
        return;
      }
    }
  }

  Future<void> addSubtask(String taskId, String title) async {
    if (title.trim().isEmpty) return;
    final now = DateTime.now().toUtc();
    final subtask = SubtaskModel(
      id: const Uuid().v4(),
      taskId: taskId,
      title: title.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insertSubtask(subtask);
    await loadSubtasks(taskId);
  }

  Future<void> deleteSubtask(String subtaskId) async {
    await _repository.softDeleteSubtask(subtaskId);
    for (final entry in _subtasksByTask.entries) {
      entry.value.removeWhere((s) => s.id == subtaskId);
      _computeProgress(entry.key);
    }
    notifyListeners();
  }

  /// نسبة تقدم المهام الفرعية لمهمة محددة (0.0 إلى 1.0).
  double getProgress(String taskId) => _progressCache[taskId] ?? 0.0;

  void _computeProgress(String taskId) {
    final list = _subtasksByTask[taskId] ?? const <SubtaskModel>[];
    if (list.isEmpty) {
      _progressCache[taskId] = 0.0;
      return;
    }
    final completedCount = list.where((s) => s.isCompleted).length;
    _progressCache[taskId] = completedCount / list.length;
  }
}