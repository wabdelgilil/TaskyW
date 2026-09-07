import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/features/areas/presentation/controllers/areas_controller.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/projects/data/repositories/project_repository_impl.dart';
import 'package:tasky/features/projects/presentation/controllers/projects_controller.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:tasky/features/tasks/presentation/controllers/search_controller.dart';
import 'package:tasky/features/tasks/presentation/controllers/subtasks_controller.dart';
import 'package:tasky/features/tasks/presentation/controllers/tasks_controller.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('areas', {
      'id': 'area-work-main',
      'name': 'العمل الأساسي',
      'icon_emoji': '💼',
      'color_hex': '#3B82F6',
      'order_index': 0,
      'sync_status': 'pending_insert',
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
    });
  });

  tearDownAll(() async {
    await AppDatabase.resetForTest();
  });

  group('AreasController', () {
    test('تحميل المجالات يحمل المجال الافتراضي للاختبار', () async {
      final controller = AreasController();
      await controller.loadAreas();
      expect(controller.areas.length, 1);
    });

    test('إنشاء واختيار مجال جديد', () async {
      final controller = AreasController();
      await controller.loadAreas();
      final before = controller.areas.length;

      await controller.createArea(name: 'مجال جديد', colorHex: '#FF0000');
      expect(controller.areas.length, before + 1);

      final newArea = controller.areas.last;
      controller.selectArea(newArea.id);
      expect(controller.selectedAreaId, newArea.id);
      expect(controller.selectedArea?.name, 'مجال جديد');
    });

    test('تعديل اسم مجال', () async {
      final controller = AreasController();
      await controller.createArea(name: 'مجال أصلي');
      await controller.loadAreas();
      final area = controller.areas.first;

      await controller.updateArea(area.copyWith(name: 'اسم معدل'));
      expect(controller.areas.first.name, 'اسم معدل');
    });

    test('حذف مجال يزيله من القائمة ويصفر الاختيار', () async {
      final controller = AreasController();
      await controller.createArea(name: 'مجال للحذف');
      await controller.loadAreas();
      final area = controller.areas.first;
      controller.selectArea(area.id);

      await controller.deleteArea(area.id);
      expect(controller.areas.any((a) => a.id == area.id), isFalse);
      expect(controller.selectedAreaId, isNull);
    });
  });

  group('ProjectsController', () {
    test('إنشاء مشروع تحت مجال واستخراجه', () async {
      final controller = ProjectsController();
      await controller.loadProjects();
      expect(controller.projects, isEmpty);

      await controller.createProject(areaId: 'area-work-main', name: 'مشروع أ');
      expect(controller.projects.length, 1);

      final forArea = controller.getProjectsForArea('area-work-main');
      expect(forArea.length, 1);
      expect(forArea.first.name, 'مشروع أ');
    });

    test('تعديل وحذف مشروع', () async {
      final controller = ProjectsController();
      await controller.loadProjects();
      await controller.createProject(areaId: 'area-work-main', name: 'مشروع ب');

      final project = controller.projects.first;
      await controller.updateProject(project.copyWith(status: 'completed'));
      expect(controller.projects.first.status, 'completed');

      await controller.deleteProject(project.id);
      expect(controller.projects, isEmpty);
    });
  });

  group('TasksController', () {
    test('الفلاتر الحسابية الفورية', () async {
      final controller = TasksController();
      final now = DateTime.now().toUtc();

      await controller.createTask(TaskModel(
        id: 'task-today',
        areaId: 'area-work-main',
        title: 'مهمة اليوم',
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await controller.createTask(TaskModel(
        id: 'task-urgent',
        areaId: 'area-work-main',
        title: 'مهمة عاجلة',
        priority: 'urgent',
        createdAt: now,
        updatedAt: now,
      ));
      await controller.createTask(TaskModel(
        id: 'task-waiting',
        areaId: 'area-work-main',
        title: 'مهمة معلقة',
        status: 'waiting',
        createdAt: now,
        updatedAt: now,
      ));

      expect(controller.todayTasks.map((t) => t.id), contains('task-today'));
      expect(controller.urgentTasks.map((t) => t.id), contains('task-urgent'));
      expect(controller.waitingTasks.length, 1);
      expect(controller.completedTasks, isEmpty);
    });

    test('تحديث حالة المهمة', () async {
      final controller = TasksController();
      final now = DateTime.now().toUtc();

      await controller.createTask(TaskModel(
        id: 'task-status',
        areaId: 'area-work-main',
        title: 'مهمة الحالة',
        createdAt: now,
        updatedAt: now,
      ));

      await controller.updateStatus('task-status', 'completed');
      expect(controller.completedTasks.map((t) => t.id), contains('task-status'));
    });

    test('تحديث حالة المهمة يزيلها من مهام اليوم', () async {
      final controller = TasksController();
      final now = DateTime.now().toUtc();

      await controller.createTask(TaskModel(
        id: 'task-today-2',
        areaId: 'area-work-main',
        title: 'مهمة اليوم لأجل الفلترة',
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      expect(controller.todayTasks.length, 1);

      await controller.updateStatus('task-today-2', 'completed');
      expect(controller.todayTasks, isEmpty);
    });

    test('حذف مهمة عبر الحذف الهادئ', () async {
      final controller = TasksController();
      final now = DateTime.now().toUtc();

      await controller.createTask(TaskModel(
        id: 'task-delete',
        areaId: 'area-work-main',
        title: 'مهمة للحذف',
        createdAt: now,
        updatedAt: now,
      ));
      expect(controller.tasks.length, 1);

      await controller.deleteTask('task-delete');
      expect(controller.tasks, isEmpty);
    });
  });

  group('SubtasksController', () {
    Future<void> ensureParentTask(String taskId) async {
      final now = DateTime.now().toUtc();
      await TaskRepositoryImpl().insertTask(TaskModel(
        id: taskId,
        areaId: 'area-work-main',
        title: 'مهمة أم',
        createdAt: now,
        updatedAt: now,
      ));
    }

    test('إضافة مهمة فرعية وحساب نسبة التقدم', () async {
      await ensureParentTask('task-with-subtasks');
      final controller = SubtasksController();
      await controller.addSubtask('task-with-subtasks', 'أول خطوة');
      await controller.addSubtask('task-with-subtasks', 'ثاني خطوة');

      final subtasks = controller.getSubtasks('task-with-subtasks');
      expect(subtasks.length, 2);
      expect(controller.getProgress('task-with-subtasks'), 0.0);

      await controller.toggleCompletion(subtasks.first.id, true);
      expect(controller.getProgress('task-with-subtasks'), 0.5);
    });

    test('حذف مهمة فرعية والتحقق من التقدم', () async {
      await ensureParentTask('task-delete-sub');
      final controller = SubtasksController();
      await controller.addSubtask('task-delete-sub', 'خطوة واحدة');

      final subtask = controller.getSubtasks('task-delete-sub').first;
      await controller.deleteSubtask(subtask.id);
      expect(controller.getSubtasks('task-delete-sub'), isEmpty);
      expect(controller.getProgress('task-delete-sub'), 0.0);
    });
  });

  group('SearchController', () {
    test('البحث العام يجد المهام المطابقة', () async {
      final tasksController = TasksController();
      final now = DateTime.now().toUtc();
      await tasksController.createTask(TaskModel(
        id: 'task-search-1',
        areaId: 'area-work-main',
        title: 'شراء معدات الصيانة',
        description: 'مستلزمات دورية',
        createdAt: now,
        updatedAt: now,
      ));

      final searchController = SearchController(debounceDuration: Duration.zero);
      searchController.searchIn('معدات');
      await searchController.executeSearch();

      expect(searchController.searchResults.length, 1);
      expect(searchController.searchResults.first.id, 'task-search-1');
    });

    test('البحث المقيّد بمشروع يحصر النتائج داخله', () async {
      final now = DateTime.now().toUtc();
      await ProjectRepositoryImpl().insertProject(ProjectModel(
        id: 'project-x',
        areaId: 'area-work-main',
        name: 'المشروع س',
        createdAt: now,
        updatedAt: now,
      ));
      final tasksController = TasksController();
      await tasksController.createTask(TaskModel(
        id: 'task-search-in',
        areaId: 'area-work-main',
        projectId: 'project-x',
        title: 'مهمة داخل المشروع',
        createdAt: now,
        updatedAt: now,
      ));
      await tasksController.createTask(TaskModel(
        id: 'task-search-out',
        areaId: 'area-work-main',
        title: 'مهمة خارج المشروع',
        createdAt: now,
        updatedAt: now,
      ));

      final searchController = SearchController(debounceDuration: Duration.zero);
      searchController.setScope(SearchScope.project, 'project-x');
      searchController.searchIn('مهمة');
      await searchController.executeSearch();

      expect(searchController.searchResults.map((t) => t.id), contains('task-search-in'));
      expect(searchController.searchResults.map((t) => t.id), isNot(contains('task-search-out')));
    });

    test('مسح النص يفرغ النتائج', () async {
      final searchController = SearchController(debounceDuration: Duration.zero);
      searchController.searchIn('أي شىء');
      searchController.clearQuery();
      expect(searchController.isEmpty, isTrue);
      expect(searchController.searchResults, isEmpty);
    });
  });
}