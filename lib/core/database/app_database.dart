import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'database_seeder.dart';
import 'database_tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  /// مسار مخصص لقاعدة البيانات (يُستغل في الاختبارات).
  static String? databasePathOverride;

  /// استخدام قاعدة بيانات ذاكرة (للاختبارات فقط).
  static bool inMemory = false;

  final DatabaseSeeder _seeder = DatabaseSeeder();

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      final String path = inMemory ? inMemoryDatabasePath : 'tasky3_web_db.db';
      return await databaseFactoryFfiWeb.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (db, version) async {
            await _createTables(db);
            await _seeder.seedInitialData(db);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            await _createTables(db);
            await _ensureTaskColumns(db);
            await _ensureTaskTagColumns(db);
          },
        ),
      );
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path;
    if (inMemory) {
      path = inMemoryDatabasePath;
    } else if (databasePathOverride != null) {
      path = databasePathOverride!;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'tasky3_database.db');
    }

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seeder.seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
        await _ensureTaskColumns(db);
        await _ensureTaskTagColumns(db);
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createTables(Database db) async {
    for (final statement in DatabaseTables.allCreateStatements) {
      await db.execute(statement);
    }
  }

  /// إضافة أعمدة مرحلة الترقية (v1 → v2) للجداول القائمة دون تكرار.
  Future<void> _ensureTaskColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(tasks)');
    final existing = columns.map((c) => c['name'] as String).toSet();

    const migrationColumns = <String, String>{
      'is_recurring': 'INTEGER NOT NULL DEFAULT 0',
      'recurrence_pattern': 'TEXT',
      'recurrence_interval': 'INTEGER NOT NULL DEFAULT 1',
      'recurrence_end_date': 'TEXT',
      'assigned_to': 'TEXT',
    };

    for (final entry in migrationColumns.entries) {
      if (!existing.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE tasks ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
  }

  /// إضافة أعمدة مرحلة الترقية (v2 → v3) لجدول ربط الوسوم دون تكرار.
  Future<void> _ensureTaskTagColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(task_tags)');
    final existing = columns.map((c) => c['name'] as String).toSet();

    const migrationColumns = <String, String>{
      'id': 'TEXT',
      'sync_status': "TEXT NOT NULL DEFAULT 'pending_insert'",
      'updated_at': 'TEXT',
      'deleted_at': 'TEXT',
    };

    for (final entry in migrationColumns.entries) {
      if (!existing.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE task_tags ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }

    // تعبئة المعرّف للروابط القديمة بهوية مستقرة (task_id|tag_id).
    await db.execute(
      "UPDATE task_tags SET id = task_id || '|' || tag_id WHERE id IS NULL",
    );
    await db.execute(
      "UPDATE task_tags SET updated_at = created_at WHERE updated_at IS NULL",
    );
  }

  static Future<void> resetForTest() async {
    await _database?.close();
    _database = null;
    databasePathOverride = null;
    inMemory = false;
  }
}