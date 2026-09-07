import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements IProjectRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.projectTable,
      where: 'deleted_at IS NULL',
      orderBy: 'order_index ASC',
    );
    return rows.map(ProjectModel.fromMap).toList();
  }

  @override
  Future<List<ProjectModel>> getProjectsByArea(String areaId) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.projectTable,
      where: 'area_id = ? AND deleted_at IS NULL',
      whereArgs: [areaId],
      orderBy: 'order_index ASC',
    );
    return rows.map(ProjectModel.fromMap).toList();
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.projectTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ProjectModel.fromMap(rows.first);
  }

  @override
  Future<void> insertProject(ProjectModel project) async {
    final db = await _db;
    await db.insert(DatabaseTables.projectTable, project.toMap());
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    final db = await _db;
    await db.update(
      DatabaseTables.projectTable,
      project.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending_update',
      ).toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  @override
  Future<void> softDeleteProject(String id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseTables.projectTable,
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
