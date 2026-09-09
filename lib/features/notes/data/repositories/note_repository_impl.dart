import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../models/note_model.dart';

/// مستودع الملاحظات المحلي (Offline-First).
abstract class INoteRepository {
  Future<List<NoteModel>> getNotes({bool includeArchived = false});

  Future<NoteModel?> getNoteById(String id);

  Future<void> insertNote(NoteModel note);

  Future<void> updateNote(NoteModel note);

  Future<void> softDeleteNote(String id);

  Future<List<NoteModel>> getNotesBySyncStatus(String syncStatus);
}

class NoteRepositoryImpl implements INoteRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<NoteModel>> getNotes({bool includeArchived = false}) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.noteTable,
      where: includeArchived
          ? 'deleted_at IS NULL'
          : 'deleted_at IS NULL AND is_archived = 0',
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return rows.map(NoteModel.fromMap).toList();
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.noteTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return NoteModel.fromMap(rows.first);
  }

  @override
  Future<void> insertNote(NoteModel note) async {
    final db = await _db;
    await db.insert(DatabaseTables.noteTable, note.toMap());
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final db = await _db;
    await db.update(
      DatabaseTables.noteTable,
      note
          .copyWith(
            updatedAt: DateTime.now().toUtc(),
            syncStatus: 'pending_update',
          )
          .toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> softDeleteNote(String id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.noteTable,
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
  Future<List<NoteModel>> getNotesBySyncStatus(String syncStatus) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.noteTable,
      where: 'sync_status = ?',
      whereArgs: [syncStatus],
    );
    return rows.map(NoteModel.fromMap).toList();
  }
}