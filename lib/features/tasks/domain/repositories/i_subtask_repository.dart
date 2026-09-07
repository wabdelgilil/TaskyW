import '../../data/models/subtask_model.dart';

abstract class ISubtaskRepository {
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId);
  Future<void> insertSubtask(SubtaskModel subtask);
  Future<void> updateSubtask(SubtaskModel subtask);
  Future<void> toggleSubtaskCompletion(String id, bool isCompleted);
  Future<void> softDeleteSubtask(String id);
}
