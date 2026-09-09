import '../../data/models/task_model.dart';

abstract class ITaskRepository {
  Future<List<TaskModel>> getTasks({
    String? areaId,
    String? projectId,
    String? status,
    String? priority,
    DateTime? dueBefore,
  });
  Future<TaskModel?> getTaskById(String id);
  Future<void> insertTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> updateTaskStatus(String id, String status);
  Future<void> softDeleteTask(String id);

  Future<List<TaskModel>> searchTasks(String query, {String? areaId, String? projectId});

  // ─── الأرشفة وسلة المهملات (Archive & Trash System) ───────────────────
  Future<List<TaskModel>> getArchivedTasks({String? areaId, String? projectId});
  Future<List<TaskModel>> getTrashTasks();
  Future<void> archiveTask(String id);
  Future<void> unarchiveTask(String id, {String targetStatus = 'todo'});
  Future<void> restoreTaskFromTrash(String id);
  Future<void> permanentlyDeleteTask(String id);
  Future<void> emptyTrash();
}
