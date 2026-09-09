import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/projects/data/repositories/project_repository_impl.dart';
import 'package:tasky/features/projects/presentation/controllers/projects_controller.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:tasky/features/tasks/presentation/controllers/tasks_controller.dart';

/// بذر إعداد يتضمن مجالاً ومهام بحالات مختلفة في سيناريو الأرشفة وسلة المهملات.
Future<Map<String, String>> _seed() async {
  final db = await AppDatabase.instance.database;
  final now = DateTime.now().toUtc().toIso8601String();
  final later =
      DateTime.now().toUtc().add(const Duration(hours: 5)).toIso8601String();

  await db.insert('areas', {
    'id': 'area-1',
    'name': 'مجال العمل',
    'created_at': now,
    'updated_at': now,
    'sync_status': 'synced',
  });

  TaskModel buildTask(String id, {String status = 'todo', String? updated}) =>
      TaskModel(
        id: id,
        areaId: 'area-1',
        title: 'مهمة $id',
        status: status,
        createdAt: DateTime.parse(now),
        updatedAt: DateTime.parse(updated ?? now),
        syncStatus: 'synced',
      );

  // مهمة نشطة (todo)
  await db.insert('tasks', buildTask('active-1').toMap());
  // مهمة نشطة أخرى بمجال آخر لتأكيد الفلترة
  await db.insert('areas', {
    'id': 'area-2',
    'name': 'مجال شخصي',
    'created_at': now,
    'updated_at': now,
    'sync_status': 'synced',
  });
  await db.insert(
    'tasks',
    buildTask('active-2', status: 'todo').toMap().copyWith(areaId: 'area-2'),
  );
  // مهمة مكتملة
  await db.insert('tasks', buildTask('done-1', status: 'completed').toMap());
  // مهمة مؤرشفة (أقدم تحديثاً)
  await db.insert(
    'tasks',
    buildTask('arch-1', status: 'archived', updated: now).toMap(),
  );
  // مهمة مؤرشفة أحدث — يجب أن تترتب قبل arch-1 عند getArchivedTasks
  await db.insert(
    'tasks',
    buildTask('arch-2', status: 'archived', updated: later).toMap(),
  );
  // مهمة في سلة المهملات (deleted_at)
  await db.insert('tasks', {
    ...buildTask('trash-1').toMap(),
    'deleted_at': now,
    'sync_status': 'pending_delete',
  });
  // مهمة أخرى في سلة المهملات لحذفها نهائياً/تفريغها
  await db.insert('tasks', {
    ...buildTask('trash-2').toMap(),
    'deleted_at': now,
    'sync_status': 'pending_delete',
  });

  return {
    'now': now,
    'later': later,
  };
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.inMemory = true;
  });

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    await AppDatabase.instance.database;
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  group('TaskModel helpers', () {
    test('isArchived يعكس حالة status = archived', () {
      final now = DateTime.now().toUtc();
      TaskModel make(String status) => TaskModel(
            id: 'x',
            areaId: 'area-1',
            title: 'x',
            status: status,
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          );
      expect(make('archived').isArchived, isTrue);
      expect(make('todo').isArchived, isFalse);
      expect(make('completed').isArchived, isFalse);
    });

    test('isDeleted يعكس وجود deleted_at', () {
      final now = DateTime.now().toUtc();
      TaskModel make({DateTime? deletedAt}) => TaskModel(
            id: 'x',
            areaId: 'area-1',
            title: 'x',
            deletedAt: deletedAt,
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          );
      expect(make(deletedAt: now).isDeleted, isTrue);
      expect(make().isDeleted, isFalse);
    });
  });

  group('TaskRepositoryImpl — الأرشفة وسلة المهملات', () {
    late TaskRepositoryImpl repo;
    setUp(() => repo = TaskRepositoryImpl());

    test('getTasks يستبعد المهام المؤرشفة والمحذوفة افتراضياً', () async {
      await _seed();
      final active = await repo.getTasks();
      final ids = active.map((t) => t.id).toSet();
      expect(ids, contains('active-1'));
      expect(ids, contains('active-2'));
      expect(ids, contains('done-1'));
      expect(ids.contains('arch-1'), isFalse);
      expect(ids.contains('arch-2'), isFalse);
      expect(ids.contains('trash-1'), isFalse);
      expect(ids.contains('trash-2'), isFalse);
    });

    test('getTasks بقيمة status=archived يجلب المؤرشفات (مع استرجاعها عند الطلب)', () async {
      await _seed();
      final archived = await repo.getTasks(status: 'archived');
      expect(archived.map((t) => t.id).toSet(), {'arch-1', 'arch-2'});
    });

    test('getArchivedTasks يجلب المؤرشفات فقط مرتبة تنازلياً بالتحديث', () async {
      await _seed();
      final archived = await repo.getArchivedTasks();
      expect(archived.map((t) => t.id).toList(), ['arch-2', 'arch-1']);
    });

    test('getArchivedTasks يفلتر حسب المجال', () async {
      await _seed();
      // أرشفة مهمة في مجال آخر لضمان الفلترة
      final db = await AppDatabase.instance.database;
      final now = DateTime.now().toUtc().toIso8601String();
      await db.insert('tasks', {
        'id': 'arch-area2',
        'area_id': 'area-2',
        'title': 'مؤرشفة شخصية',
        'status': 'archived',
        'created_at': now,
        'updated_at': now,
        'sync_status': 'synced',
      });

      final inArea1 = await repo.getArchivedTasks(areaId: 'area-1');
      expect(inArea1.map((t) => t.id), isNot(contains('arch-area2')));
      expect(inArea1.map((t) => t.id), contains('arch-1'));

      final inArea2 = await repo.getArchivedTasks(areaId: 'area-2');
      expect(inArea2.map((t) => t.id).toList(), ['arch-area2']);
    });

    test('getTrashTasks يجلب المحذوفة ناعماً فقط', () async {
      await _seed();
      final trash = await repo.getTrashTasks();
      expect(trash.map((t) => t.id).toSet(), {'trash-1', 'trash-2'});
      expect(trash.every((t) => t.deletedAt != null), isTrue);
    });

    test('archiveTask يضبط الحالة إلى archived مع sync_status=pending_update', () async {
      await _seed();
      await repo.archiveTask('active-1');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: ['active-1'],
      );
      expect(rows.single['status'], 'archived');
      expect(rows.single['sync_status'], 'pending_update');
      expect(rows.single['deleted_at'], isNull);
      // لم تعد تظهر في القوائم العادية
      final active = await repo.getTasks();
      expect(active.map((t) => t.id), isNot(contains('active-1')));
      // وتظهر كأرشفة
      final archived = await repo.getArchivedTasks();
      expect(archived.map((t) => t.id), contains('active-1'));
    });

    test('unarchiveTask يعيد المهمة للحالة الهدف (الافتراضي todo) مع pending_update', () async {
      await _seed();
      await repo.unarchiveTask('arch-1');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: ['arch-1'],
      );
      expect(rows.single['status'], 'todo');
      expect(rows.single['sync_status'], 'pending_update');

      // اختيار حالة هدف مخصصة
      await repo.archiveTask('active-2');
      await repo.unarchiveTask('active-2', targetStatus: 'completed');
      final rows2 = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: ['active-2'],
      );
      expect(rows2.single['status'], 'completed');
    });

    test('restoreTaskFromTrash يصفّر deleted_at ويعيدها للقوائم النشطة', () async {
      await _seed();
      await repo.restoreTaskFromTrash('trash-1');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: ['trash-1'],
      );
      expect(rows.single['deleted_at'], isNull);
      expect(rows.single['sync_status'], 'pending_update');

      expect(
        (await repo.getTasks()).map((t) => t.id),
        contains('trash-1'),
      );
      expect(
        (await repo.getTrashTasks()).map((t) => t.id),
        isNot(contains('trash-1')),
      );
    });

    test('permanentlyDeleteTask يحذف المهمة نهائياً من SQLite', () async {
      await _seed();
      await repo.permanentlyDeleteTask('trash-1');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: ['trash-1'],
      );
      expect(rows, isEmpty);
      // بقية السلة باقية
      expect((await repo.getTrashTasks()).map((t) => t.id).toList(), ['trash-2']);
    });

    test('emptyTrash يحذف كل عناصر السلة ويُبقي الباقي', () async {
      await _seed();
      await repo.emptyTrash();

      expect(await repo.getTrashTasks(), isEmpty);
      final remainingIds =
          (await repo.getTasks()).map((t) => t.id).toSet();
      expect(remainingIds, contains('active-1'));
      expect(remainingIds, contains('done-1'));
      // المؤرشفات لم تُلمس
      final archived = await repo.getArchivedTasks();
      expect(archived.map((t) => t.id).toSet(), {'arch-1', 'arch-2'});
    });
  });

  group('TasksController — الأرشفة وسلة المهملات', () {
    late TasksController controller;
    setUp(() => controller = TasksController());

    test('Getters: archivedTasks/trashTasks/archivedCount/trashCount', () async {
      await _seed();
      await controller.loadArchivedTasks();
      await controller.loadTrashTasks();

      expect(controller.archivedCount, 2);
      expect(controller.trashCount, 2);
      expect(controller.archivedTasks.map((t) => t.id).toSet(), {'arch-1', 'arch-2'});
      expect(controller.trashTasks.map((t) => t.id).toSet(), {'trash-1', 'trash-2'});
      expect(controller.isLoadingArchived, isFalse);
      expect(controller.isLoadingTrash, isFalse);
    });

    test('archiveTask ينقل مهمة نشطة إلى الأرشيف ويُحدّث العدّادات', () async {
      await _seed();
      await controller.loadArchivedTasks();
      expect(controller.archivedCount, 2);

      final removed = await controller.archiveTask('active-1');
      expect(removed, isTrue);

      await controller.loadArchivedTasks();
      expect(controller.archivedCount, 3);
      expect(controller.archivedTasks.map((t) => t.id), contains('active-1'));
      // لم تعد ضمن النشطة
      await controller.loadTasks();
      expect(controller.tasks.map((t) => t.id), isNot(contains('active-1')));
    });

    test('unarchiveTask يعيد المهمة للأرشيف للعمل النشط', () async {
      await _seed();
      await controller.loadArchivedTasks();
      expect(controller.archivedCount, 2);

      final removed = await controller.unarchiveTask('arch-1');
      expect(removed, isTrue);

      await controller.loadArchivedTasks();
      expect(controller.archivedCount, 1);
      expect(controller.archivedTasks.map((t) => t.id), isNot(contains('arch-1')));

      await controller.loadTasks();
      expect(controller.tasks.map((t) => t.id), contains('arch-1'));
    });

    test('restoreTask يسترجع مهمة من سلة المهملات', () async {
      await _seed();
      await controller.loadTrashTasks();
      expect(controller.trashCount, 2);

      final removed = await controller.restoreTask('trash-1');
      expect(removed, isTrue);

      await controller.loadTrashTasks();
      expect(controller.trashCount, 1);
      expect(controller.trashTasks.map((t) => t.id), isNot(contains('trash-1')));

      await controller.loadTasks();
      expect(controller.tasks.map((t) => t.id), contains('trash-1'));
    });

    test('permanentlyDeleteTask يزيل عنصراً من السلة دون المساس بالباقي', () async {
      await _seed();
      await controller.loadTrashTasks();
      expect(controller.trashCount, 2);

      final removed = await controller.permanentlyDeleteTask('trash-1');
      expect(removed, isTrue);

      await controller.loadTrashTasks();
      expect(controller.trashCount, 1);
      expect(controller.trashTasks.map((t) => t.id).toList(), ['trash-2']);
    });

    test('emptyTrash يفرّغ السلة بالكامل', () async {
      await _seed();
      await controller.loadTrashTasks();
      expect(controller.trashCount, 2);

      final removed = await controller.emptyTrash();
      expect(removed, isTrue);
      expect(controller.trashCount, 0);
      expect(controller.trashTasks, isEmpty);
      // النشطة والمؤرشفة باقية
      await controller.loadTasks();
      expect(controller.tasks, isNotEmpty);
      await controller.loadArchivedTasks();
      expect(controller.archivedTasks, isNotEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // طبقة المشاريع (Projects Layer)
  // ═══════════════════════════════════════════════════════════════════════════

  group('ProjectModel helpers', () {
    test('isArchived يعكس حالة status = archived', () {
      final now = DateTime.now().toUtc();
      ProjectModel make(String status) => ProjectModel(
            id: 'x',
            areaId: 'area-1',
            name: 'x',
            status: status,
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          );
      expect(make('archived').isArchived, isTrue);
      expect(make('active').isArchived, isFalse);
    });

    test('isDeleted يعكس وجود deleted_at', () {
      final now = DateTime.now().toUtc();
      ProjectModel make({DateTime? deletedAt}) => ProjectModel(
            id: 'x',
            areaId: 'area-1',
            name: 'x',
            deletedAt: deletedAt,
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          );
      expect(make(deletedAt: now).isDeleted, isTrue);
      expect(make().isDeleted, isFalse);
    });
  });

  group('ProjectRepositoryImpl — الأرشفة وسلة المهملات', () {
    late ProjectRepositoryImpl repo;
    setUp(() => repo = ProjectRepositoryImpl());

    Future<void> seedProjects() async {
      final db = await AppDatabase.instance.database;
      final now = DateTime.now().toUtc().toIso8601String();
      final later =
          DateTime.now().toUtc().add(const Duration(hours: 5)).toIso8601String();

      await db.insert('areas', {
        'id': 'area-1',
        'name': 'مجال العمل',
        'created_at': now,
        'updated_at': now,
        'sync_status': 'synced',
      });

      ProjectModel buildProject(String id,
              {String status = 'active', String? updated}) =>
          ProjectModel(
            id: id,
            areaId: 'area-1',
            name: 'مشروع $id',
            status: status,
            createdAt: DateTime.parse(now),
            updatedAt: DateTime.parse(updated ?? now),
            syncStatus: 'synced',
          );

      // مشروع نشط
      await db.insert('projects', buildProject('proj-active').toMap());
      // مشروع مكتمل
      await db.insert('projects', buildProject('proj-done', status: 'done').toMap());
      // مشروع مؤرشف
      await db.insert(
        'projects',
        buildProject('proj-arch', status: 'archived', updated: now).toMap(),
      );
      // مشروع مؤرشف أحدث
      await db.insert(
        'projects',
        buildProject('proj-arch2', status: 'archived', updated: later).toMap(),
      );
      // مشروع في سلة المهملات
      await db.insert('projects', {
        ...buildProject('proj-trash').toMap(),
        'deleted_at': now,
        'sync_status': 'pending_delete',
      });
      // مشروع آخر في السلة
      await db.insert('projects', {
        ...buildProject('proj-trash2').toMap(),
        'deleted_at': now,
        'sync_status': 'pending_delete',
      });
    }

    test('getAllProjects يستبعد المشاريع المؤرشفة والمحذوفة', () async {
      await seedProjects();
      final active = await repo.getAllProjects();
      final ids = active.map((p) => p.id).toSet();
      expect(ids, contains('proj-active'));
      expect(ids, contains('proj-done'));
      expect(ids.contains('proj-arch'), isFalse);
      expect(ids.contains('proj-arch2'), isFalse);
      expect(ids.contains('proj-trash'), isFalse);
      expect(ids.contains('proj-trash2'), isFalse);
    });

    test('getProjectsByArea يستبعد المشاريع المؤرشفة', () async {
      await seedProjects();
      final active = await repo.getProjectsByArea('area-1');
      expect(active.map((p) => p.id).toSet(), contains('proj-active'));
      expect(active.map((p) => p.id), isNot(contains('proj-arch')));
    });

    test('getArchivedProjects يجلب المؤرشفات فقط مرتبة تنازلياً بالتحديث', () async {
      await seedProjects();
      final archived = await repo.getArchivedProjects();
      expect(archived.map((p) => p.id).toList(), ['proj-arch2', 'proj-arch']);
    });

    test('getTrashProjects يجلب المحذوفة ناعماً فقط', () async {
      await seedProjects();
      final trash = await repo.getTrashProjects();
      expect(trash.map((p) => p.id).toSet(), {'proj-trash', 'proj-trash2'});
    });

    test('archiveProject يضبط الحالة إلى archived مع pending_update', () async {
      await seedProjects();
      await repo.archiveProject('proj-active');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'projects',
        where: 'id = ?',
        whereArgs: ['proj-active'],
      );
      expect(rows.single['status'], 'archived');
      expect(rows.single['sync_status'], 'pending_update');

      expect(
        (await repo.getAllProjects()).map((p) => p.id),
        isNot(contains('proj-active')),
      );
      expect(
        (await repo.getArchivedProjects()).map((p) => p.id),
        contains('proj-active'),
      );
    });

    test('unarchiveProject يعيد المشروع للحالة active مع pending_update', () async {
      await seedProjects();
      await repo.unarchiveProject('proj-arch');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'projects',
        where: 'id = ?',
        whereArgs: ['proj-arch'],
      );
      expect(rows.single['status'], 'active');
      expect(rows.single['sync_status'], 'pending_update');
      expect(
        (await repo.getArchivedProjects()).map((p) => p.id),
        isNot(contains('proj-arch')),
      );
    });

    test('restoreProjectFromTrash يصفّر deleted_at ويعيده للقوائم', () async {
      await seedProjects();
      await repo.restoreProjectFromTrash('proj-trash');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'projects',
        where: 'id = ?',
        whereArgs: ['proj-trash'],
      );
      expect(rows.single['deleted_at'], isNull);
      expect(rows.single['sync_status'], 'pending_update');

      expect(
        (await repo.getAllProjects()).map((p) => p.id),
        contains('proj-trash'),
      );
      expect(
        (await repo.getTrashProjects()).map((p) => p.id),
        isNot(contains('proj-trash')),
      );
    });

    test('permanentlyDeleteProject يحذف نهائياً من SQLite', () async {
      await seedProjects();
      await repo.permanentlyDeleteProject('proj-trash');

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'projects',
        where: 'id = ?',
        whereArgs: ['proj-trash'],
      );
      expect(rows, isEmpty);
      expect(
        (await repo.getTrashProjects()).map((p) => p.id).toList(),
        ['proj-trash2'],
      );
    });

    test('emptyProjectTrash يحذف كل المشاريع المحذوفة ناعماً', () async {
      await seedProjects();
      await repo.emptyProjectTrash();

      expect(await repo.getTrashProjects(), isEmpty);
      // المشاريع النشطة والمؤرشفة باقية
      final active = await repo.getAllProjects();
      expect(active.map((p) => p.id).toSet(), contains('proj-active'));
      expect(await repo.getArchivedProjects(), isNotEmpty);
    });
  });

  group('ProjectsController — الأرشفة وسلة المهملات', () {
    late ProjectsController controller;
    setUp(() => controller = ProjectsController());

    Future<void> seedProjects() async {
      final db = await AppDatabase.instance.database;
      final now = DateTime.now().toUtc().toIso8601String();

      await db.insert('areas', {
        'id': 'area-1',
        'name': 'مجال',
        'created_at': now,
        'updated_at': now,
        'sync_status': 'synced',
      });

      ProjectModel buildProject(String id,
              {String status = 'active', String? updated}) =>
          ProjectModel(
            id: id,
            areaId: 'area-1',
            name: 'مشروع $id',
            status: status,
            createdAt: DateTime.parse(now),
            updatedAt: DateTime.parse(updated ?? now),
            syncStatus: 'synced',
          );

      await db.insert('projects', buildProject('p-active').toMap());
      await db.insert('projects', buildProject('p-arch', status: 'archived').toMap());
      await db.insert('projects', {
        ...buildProject('p-trash').toMap(),
        'deleted_at': now,
        'sync_status': 'pending_delete',
      });
    }

    test('Getters: archivedProjects/trashProjects/archivedCount/trashCount', () async {
      await seedProjects();
      await controller.loadArchivedProjects();
      await controller.loadTrashProjects();

      expect(controller.archivedCount, 1);
      expect(controller.trashCount, 1);
      expect(controller.archivedProjects.map((p) => p.id).toList(), ['p-arch']);
      expect(controller.trashProjects.map((p) => p.id).toList(), ['p-trash']);
      expect(controller.isLoadingArchived, isFalse);
      expect(controller.isLoadingTrash, isFalse);
    });

    test('archiveProject ينقل مشروع نشط إلى الأرشيف', () async {
      await seedProjects();
      await controller.loadArchivedProjects();
      expect(controller.archivedCount, 1);

      final removed = await controller.archiveProject('p-active');
      expect(removed, isTrue);

      await controller.loadArchivedProjects();
      expect(controller.archivedCount, 2);
      expect(controller.archivedProjects.map((p) => p.id), contains('p-active'));

      await controller.loadProjects();
      expect(controller.projects.map((p) => p.id), isNot(contains('p-active')));
    });

    test('unarchiveProject يعيد المشروع للعمل النشط', () async {
      await seedProjects();
      await controller.loadArchivedProjects();
      expect(controller.archivedCount, 1);

      final removed = await controller.unarchiveProject('p-arch');
      expect(removed, isTrue);

      await controller.loadArchivedProjects();
      expect(controller.archivedCount, 0);

      await controller.loadProjects();
      expect(controller.projects.map((p) => p.id), contains('p-arch'));
    });

    test('restoreProject يسترجع مشروع من سلة المهملات', () async {
      await seedProjects();
      await controller.loadTrashProjects();
      expect(controller.trashCount, 1);

      final removed = await controller.restoreProject('p-trash');
      expect(removed, isTrue);

      await controller.loadTrashProjects();
      expect(controller.trashCount, 0);

      await controller.loadProjects();
      expect(controller.projects.map((p) => p.id), contains('p-trash'));
    });

    test('permanentlyDeleteProject يحذف نهائياً من السلة', () async {
      await seedProjects();
      await controller.loadTrashProjects();
      expect(controller.trashCount, 1);

      final removed = await controller.permanentlyDeleteProject('p-trash');
      expect(removed, isTrue);

      await controller.loadTrashProjects();
      expect(controller.trashCount, 0);
    });

    test('emptyProjectTrash يفرّغ سلة المشاريع بالكامل', () async {
      // إضافة مشروع ثاني في السلة
      final db = await AppDatabase.instance.database;
      final now = DateTime.now().toUtc().toIso8601String();
      await seedProjects();
      await db.insert('projects', {
        'id': 'p-trash2',
        'area_id': 'area-1',
        'name': 'مشروع حذف 2',
        'created_at': now,
        'updated_at': now,
        'deleted_at': now,
        'sync_status': 'pending_delete',
      });

      await controller.loadTrashProjects();
      expect(controller.trashCount, 2);

      final removed = await controller.emptyProjectTrash();
      expect(removed, isTrue);
      expect(controller.trashCount, 0);
      expect(controller.trashProjects, isEmpty);

      await controller.loadProjects();
      expect(controller.projects, isNotEmpty);
      await controller.loadArchivedProjects();
      expect(controller.archivedProjects, isNotEmpty);
    });
  });
}

extension on Map<String, dynamic> {
  Map<String, dynamic> copyWith({String? areaId}) {
    final copy = Map<String, dynamic>.from(this);
    if (areaId != null) copy['area_id'] = areaId;
    return copy;
  }
}