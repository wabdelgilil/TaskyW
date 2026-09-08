import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tasky_db_upgrade');
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ترقية قاعدة البيانات v1 → v2', () {
    test('قاعدة v1 قديمة تحصل على الجداول والأعمدة الجديدة بعد الفتح', () async {
      AppDatabase.databasePathOverride = p.join(tempDir.path, 'old.db');

      // فتح قاعدة v1 أولاً بإنشاء الجداول الإصدار الأول فقط (بدون مزامنة خارجية)
      final oldDb = await databaseFactory.openDatabase(
        AppDatabase.databasePathOverride!,
        options: OpenDatabaseOptions(version: 1,
            onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS areas (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              icon_emoji TEXT NOT NULL DEFAULT '📁',
              color_hex TEXT NOT NULL DEFAULT '#3B82F6',
              order_index INTEGER NOT NULL DEFAULT 0,
              sync_status TEXT NOT NULL DEFAULT 'pending_insert',
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              deleted_at TEXT
            );
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
              id TEXT PRIMARY KEY,
              area_id TEXT NOT NULL,
              project_id TEXT,
              title TEXT NOT NULL,
              description TEXT,
              status TEXT NOT NULL DEFAULT 'todo',
              priority TEXT NOT NULL DEFAULT 'medium',
              color_hex TEXT,
              due_date TEXT,
              reminder_time TEXT,
              share_token TEXT UNIQUE,
              order_index INTEGER NOT NULL DEFAULT 0,
              sync_status TEXT NOT NULL DEFAULT 'pending_insert',
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              deleted_at TEXT
            );
          ''');
          final now = DateTime.now().toUtc().toIso8601String();
          await db.insert('areas', {
            'id': 'area-upgrade',
            'name': 'مجال قديم',
            'created_at': now,
            'updated_at': now,
          });
        }),
      );
      await oldDb.insert('tasks', {
        'id': 'task-old-1',
        'area_id': 'area-upgrade',
        'title': 'مهمة قديمة',
        'status': 'todo',
        'order_index': 0,
        'sync_status': 'pending_insert',
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      await oldDb.close();

      // إعادة الفتح عبر AppDatabase (النسخة الحالية v2) يستدعي onUpgrade.
      final db = await AppDatabase.instance.database;

      // التحقق من وجود جدول الوسوم والأعمدة الجديدة.
      final tagTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('tags', 'task_tags')",
      );
      expect(tagTables, hasLength(2));

      final taskColumns = await db.rawQuery('PRAGMA table_info(tasks)');
      final columnNames = taskColumns.map((c) => c['name']).toSet();
      expect(columnNames, containsAll([
        'is_recurring',
        'recurrence_pattern',
        'recurrence_interval',
        'recurrence_end_date',
        'assigned_to',
      ]));

      // البيانات القديمة ما زالت محفوظة وقابلة للقراءة.
      final repo = TaskRepositoryImpl();
      final oldTask = await repo.getTaskById('task-old-1');
      expect(oldTask, isNotNull);
      expect(oldTask!.title, 'مهمة قديمة');
      expect(oldTask.isRecurring, isFalse);

      // قراءة مهمة متكررة جديدة بعد الترقية تعمل بشكل طبيعي.
      final now = DateTime.now().toUtc();
      await repo.insertTask(TaskModel(
        id: 'task-new-recurring',
        areaId: 'area-upgrade',
        title: 'مهمة متكررة جديدة',
        dueDate: DateTime.utc(2026, 9, 8, 7, 0),
        isRecurring: true,
        recurrencePattern: 'weekly',
        recurrenceInterval: 1,
        createdAt: now,
        updatedAt: now,
      ));
      final fetched = await repo.getTaskById('task-new-recurring');
      expect(fetched!.isRecurring, isTrue);
      expect(fetched.recurrencePattern, 'weekly');
    });
  });
}