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
          version: 2,
          onCreate: (db, version) async {
            await _createTables(db);
            await _seeder.seedInitialData(db);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            await _createTables(db);
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
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seeder.seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
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

  static Future<void> resetForTest() async {
    await _database?.close();
    _database = null;
    databasePathOverride = null;
    inMemory = false;
  }
}