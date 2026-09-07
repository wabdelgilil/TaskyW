import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/repositories/i_area_repository.dart';
import '../models/area_model.dart';

class AreaRepositoryImpl implements IAreaRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<AreaModel>> getAllAreas() async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.areaTable,
      where: 'deleted_at IS NULL',
      orderBy: 'order_index ASC',
    );
    return rows.map(AreaModel.fromMap).toList();
  }

  @override
  Future<AreaModel?> getAreaById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.areaTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AreaModel.fromMap(rows.first);
  }

  @override
  Future<void> insertArea(AreaModel area) async {
    final db = await _db;
    await db.insert(DatabaseTables.areaTable, area.toMap());
  }

  @override
  Future<void> updateArea(AreaModel area) async {
    final db = await _db;
    await db.update(
      DatabaseTables.areaTable,
      area.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending_update',
      ).toMap(),
      where: 'id = ?',
      whereArgs: [area.id],
    );
  }

  @override
  Future<void> softDeleteArea(String id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.areaTable,
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
