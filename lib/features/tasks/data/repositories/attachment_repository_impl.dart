import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/repositories/i_attachment_repository.dart';
import '../models/attachment_model.dart';
export '../../domain/repositories/i_attachment_repository.dart';

class AttachmentRepositoryImpl implements IAttachmentRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<AttachmentModel>> getAttachmentsByTask(String taskId) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.attachmentTable,
      where: 'task_id = ? AND deleted_at IS NULL',
      whereArgs: [taskId],
      orderBy: 'created_at ASC',
    );
    return rows.map(AttachmentModel.fromMap).toList();
  }

  @override
  Future<AttachmentModel?> getAttachmentById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.attachmentTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AttachmentModel.fromMap(rows.first);
  }

  @override
  Future<void> insertAttachment(AttachmentModel attachment) async {
    final db = await _db;
    await db.insert(DatabaseTables.attachmentTable, attachment.toMap());
  }

  @override
  Future<void> updateAttachment(AttachmentModel attachment) async {
    final db = await _db;
    await db.update(
      DatabaseTables.attachmentTable,
      attachment
          .copyWith(
            updatedAt: DateTime.now().toUtc(),
            syncStatus: 'pending_update',
          )
          .toMap(),
      where: 'id = ?',
      whereArgs: [attachment.id],
    );
  }

  @override
  Future<void> softDeleteAttachment(String id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.attachmentTable,
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
  Future<List<AttachmentModel>> getAttachmentsBySyncStatus(
    String syncStatus,
  ) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.attachmentTable,
      where: 'sync_status = ?',
      whereArgs: [syncStatus],
    );
    return rows.map(AttachmentModel.fromMap).toList();
  }
}