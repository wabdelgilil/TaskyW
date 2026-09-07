import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<TaskModel>> getTasks({
    String? areaId,
    String? projectId,
    String? status,
    String? priority,
    DateTime? dueBefore,
  }) async {
    final db = await _db;
    final conditions = <String>['deleted_at IS NULL'];
    final args = <Object?>[];

    if (areaId != null) {
      conditions.add('area_id = ?');
      args.add(areaId);
    }
    if (projectId != null) {
      conditions.add('project_id = ?');
      args.add(projectId);
    }
    if (status != null) {
      conditions.add('status = ?');
      args.add(status);
    }
    if (priority != null) {
      conditions.add('priority = ?');
      args.add(priority);
    }
    if (dueBefore != null) {
      conditions.add('due_date IS NOT NULL AND due_date <= ?');
      args.add(dueBefore.toUtc().toIso8601String());
    }

    final rows = await db.query(
      DatabaseTables.taskTable,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'order_index ASC',
    );
    return rows.map(TaskModel.fromMap).toList();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.taskTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TaskModel.fromMap(rows.first);
  }

  @override
  Future<void> insertTask(TaskModel task) async {
    final db = await _db;
    await db.insert(DatabaseTables.taskTable, task.toMap());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final db = await _db;
    await db.update(
      DatabaseTables.taskTable,
      task.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending_update',
      ).toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> updateTaskStatus(String id, String status) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.taskTable,
      {
        'status': status,
        'sync_status': 'pending_update',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> softDeleteTask(String id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.taskTable,
      {
        'deleted_at': now,
        'sync_status': 'pending_delete',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<TaskModel>> searchTasks(String query, {String? areaId, String? projectId}) async {
    final db = await _db;
    final conditions = <String>['deleted_at IS NULL'];
    final args = <Object?>[];

    final likeQuery = '%$query%';
    conditions.add('(title LIKE ? OR description LIKE ? OR id IN (SELECT task_id FROM ${DatabaseTables.subtaskTable} WHERE title LIKE ? AND deleted_at IS NULL))');
    args.addAll([likeQuery, likeQuery, likeQuery]);

    if (areaId != null) {
      conditions.add('area_id = ?');
      args.add(areaId);
    }
    if (projectId != null) {
      conditions.add('project_id = ?');
      args.add(projectId);
    }

    final rows = await db.query(
      DatabaseTables.taskTable,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'order_index ASC',
    );
    return rows.map(TaskModel.fromMap).toList();
  }
}
