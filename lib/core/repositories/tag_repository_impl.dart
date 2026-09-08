import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/tag_model.dart';
import 'tag_repository.dart';

class TagRepositoryImpl implements ITagRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<TagModel>> getAllTags() async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.tagTable,
      where: 'deleted_at IS NULL',
      orderBy: 'order_index ASC',
    );
    return rows.map(TagModel.fromMap).toList();
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.tagTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TagModel.fromMap(rows.first);
  }

  @override
  Future<void> insertTag(TagModel tag) async {
    final db = await _db;
    await db.insert(DatabaseTables.tagTable, tag.toMap());
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    final db = await _db;
    await db.update(
      DatabaseTables.tagTable,
      tag.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending_update',
      ).toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  @override
  Future<void> softDeleteTag(String id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.tagTable,
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
  Future<void> assignTagToTask(String taskId, String tagId) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    final linkRow = {
      'id': '$taskId|$tagId',
      'task_id': taskId,
      'tag_id': tagId,
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
      'sync_status': 'pending_insert',
    };

    // استعادة رابط مُحذف مسبقاً بدلاً من فشل المفتاح المركّب.
    final updated = await db.rawUpdate(
      '''
      UPDATE ${DatabaseTables.taskTagTable}
      SET deleted_at = NULL,
          sync_status = 'pending_insert',
          updated_at = ?
      WHERE task_id = ? AND tag_id = ? AND deleted_at IS NOT NULL
      ''',
      [now, taskId, tagId],
    );

    if (updated == 0) {
      await db.insert(
        DatabaseTables.taskTagTable,
        linkRow,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  @override
  Future<void> removeTagFromTask(String taskId, String tagId) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.rawUpdate(
      '''
      UPDATE ${DatabaseTables.taskTagTable}
      SET deleted_at = ?,
          sync_status = 'pending_delete',
          updated_at = ?
      WHERE task_id = ? AND tag_id = ? AND deleted_at IS NULL
      ''',
      [now, now, taskId, tagId],
    );
  }

  @override
  Future<List<TagModel>> getTagsForTask(String taskId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '''
      SELECT t.* FROM ${DatabaseTables.tagTable} t
      INNER JOIN ${DatabaseTables.taskTagTable} tt ON tt.tag_id = t.id
      WHERE tt.task_id = ? AND tt.deleted_at IS NULL AND t.deleted_at IS NULL
      ORDER BY t.order_index ASC
      ''',
      [taskId],
    );
    return rows.map(TagModel.fromMap).toList();
  }

  @override
  Future<List<String>> getTaskIdsForTag(String tagId) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.taskTagTable,
      columns: ['task_id'],
      where: 'tag_id = ? AND deleted_at IS NULL',
      whereArgs: [tagId],
    );
    return rows.map((row) => row['task_id'] as String).toList();
  }
}