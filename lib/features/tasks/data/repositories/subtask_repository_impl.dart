import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/repositories/i_subtask_repository.dart';
import '../models/subtask_model.dart';

class SubtaskRepositoryImpl implements ISubtaskRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.subtaskTable,
      where: 'task_id = ? AND deleted_at IS NULL',
      whereArgs: [taskId],
      orderBy: 'order_index ASC',
    );
    return rows.map(SubtaskModel.fromMap).toList();
  }

  @override
  Future<void> insertSubtask(SubtaskModel subtask) async {
    final db = await _db;
    await db.insert(DatabaseTables.subtaskTable, subtask.toMap());
  }

  @override
  Future<void> updateSubtask(SubtaskModel subtask) async {
    final db = await _db;
    await db.update(
      DatabaseTables.subtaskTable,
      subtask.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending_update',
      ).toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  @override
  Future<void> toggleSubtaskCompletion(String id, bool isCompleted) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.subtaskTable,
      {
        'is_completed': isCompleted ? 1 : 0,
        'sync_status': 'pending_update',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> softDeleteSubtask(String id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.subtaskTable,
      {
        'deleted_at': now,
        'sync_status': 'pending_delete',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
