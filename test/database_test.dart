import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/areas/data/repositories/area_repository_impl.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/projects/data/repositories/project_repository_impl.dart';
import 'package:tasky/features/tasks/data/models/subtask_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/subtask_repository_impl.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.inMemory = true;
  });

  tearDownAll(() async {
    await AppDatabase.resetForTest();
  });

  group('Database Layer', () {
    test('init database starts clean and empty', () async {
      final db = await AppDatabase.instance.database;
      expect(db.isOpen, isTrue);

      final areaRepo = AreaRepositoryImpl();
      final areas = await areaRepo.getAllAreas();
      expect(areas, isEmpty);
    });

    test('insert and retrieve area', () async {
      final repo = AreaRepositoryImpl();
      final now = DateTime.now().toUtc();
      final area = AreaModel(
        id: 'area-test-1',
        name: 'مجال اختبار',
        createdAt: now,
        updatedAt: now,
      );
      await repo.insertArea(area);

      final area2 = await repo.getAreaById('area-test-1');
      expect(area2, isNotNull);
      expect(area2!.name, 'مجال اختبار');
    });

    test('soft delete hides area', () async {
      final repo = AreaRepositoryImpl();
      await repo.softDeleteArea('area-test-1');

      final area = await repo.getAreaById('area-test-1');
      expect(area, isNull);
    });

    test('insert project with FK to area', () async {
      final areaRepo = AreaRepositoryImpl();
      final now = DateTime.now().toUtc();
      await areaRepo.insertArea(AreaModel(
        id: 'area-work-main',
        name: 'العمل الأساسي',
        createdAt: now,
        updatedAt: now,
      ));

      final projectRepo = ProjectRepositoryImpl();
      final project = ProjectModel(
        id: 'project-test-1',
        areaId: 'area-work-main',
        name: 'مشروع اختبار',
        createdAt: now,
        updatedAt: now,
      );
      await projectRepo.insertProject(project);

      final projects = await projectRepo.getProjectsByArea('area-work-main');
      expect(projects.any((p) => p.id == 'project-test-1'), isTrue);

      await projectRepo.softDeleteProject('project-test-1');
    });

    test('insert task and search within project scope', () async {
      final taskRepo = TaskRepositoryImpl();
      final now = DateTime.now().toUtc();
      final task = TaskModel(
        id: 'task-test-1',
        areaId: 'area-work-main',
        projectId: 'project-test-1',
        title: 'مهمة اختبار البحث',
        description: 'وصف تفصيلي للمهمة',
        createdAt: now,
        updatedAt: now,
      );
      await taskRepo.insertTask(task);

      final results = await taskRepo.searchTasks('اختبار البحث', projectId: 'project-test-1');
      expect(results.length, 1);
      expect(results.first.title, 'مهمة اختبار البحث');
    });

    test('insert subtask and toggle completion', () async {
      final subtaskRepo = SubtaskRepositoryImpl();
      final now = DateTime.now().toUtc();
      final subtask = SubtaskModel(
        id: 'subtask-test-1',
        taskId: 'task-test-1',
        title: 'مهمة فرعية',
        createdAt: now,
        updatedAt: now,
      );
      await subtaskRepo.insertSubtask(subtask);

      await subtaskRepo.toggleSubtaskCompletion('subtask-test-1', true);
      final subtasks = await subtaskRepo.getSubtasksForTask('task-test-1');
      expect(subtasks.first.isCompleted, isTrue);

      // اختبار البحث عن المهمة الرئيسية عبر اسم المهمة الفرعية
      final taskRepo = TaskRepositoryImpl();
      final searchBySubtask = await taskRepo.searchTasks('فرعية', projectId: 'project-test-1');
      expect(searchBySubtask.length, 1);
      expect(searchBySubtask.first.id, 'task-test-1');

      await subtaskRepo.softDeleteSubtask('subtask-test-1');
    });

    test('cleanup test data', () async {
      final taskRepo = TaskRepositoryImpl();
      await taskRepo.softDeleteTask('task-test-1');
    });
  });
}