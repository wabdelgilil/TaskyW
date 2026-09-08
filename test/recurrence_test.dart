import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/services/recurrence_service.dart';
import 'package:tasky/features/tasks/data/models/subtask_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/subtask_repository_impl.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';
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

  group('RecurrenceService.calculateNextDueDate', () {
    final base = DateTime(2026, 9, 8, 9, 30);

    test('daily يضيف عدد الأيام', () {
      final next = RecurrenceService.calculateNextDueDate(
        base,
        TaskRecurrencePattern.daily,
        1,
      );
      expect(next, DateTime(2026, 9, 9, 9, 30));
    });

    test('weekly يضيف أسبوعاً', () {
      final next = RecurrenceService.calculateNextDueDate(
        base,
        TaskRecurrencePattern.weekly,
        1,
      );
      expect(next, DateTime(2026, 9, 15, 9, 30));
    });

    test('custom_interval يستخدم عدد الأيام المخصص', () {
      final next = RecurrenceService.calculateNextDueDate(
        base,
        TaskRecurrencePattern.customInterval,
        3,
      );
      expect(next, DateTime(2026, 9, 11, 9, 30));
    });

    test('interval صغير أو صفري يُعامَل كواحد آمن', () {
      final next = RecurrenceService.calculateNextDueDate(
        base,
        TaskRecurrencePattern.daily,
        0,
      );
      expect(next, DateTime(2026, 9, 9, 9, 30));
    });

    test('monthly مع نهاية شهر يتجاوزها (31 يناير → 28 فبراير)', () {
      final jan31 = DateTime(2026, 1, 31, 9, 30);
      final next = RecurrenceService.calculateNextDueDate(
        jan31,
        TaskRecurrencePattern.monthly,
        1,
      );
      expect(next, DateTime(2026, 2, 28, 9, 30));
    });

    test('monthly يعبر حدود السنوات', () {
      final dec = DateTime(2026, 12, 15, 9, 30);
      final next = RecurrenceService.calculateNextDueDate(
        dec,
        TaskRecurrencePattern.monthly,
        3,
      );
      expect(next, DateTime(2027, 3, 15, 9, 30));
    });
  });

  group('RecurrenceService.generateNextRecurrence', () {
    final taskRepo = TaskRepositoryImpl();
    final subtaskRepo = SubtaskRepositoryImpl();

    test('مهمة غير متكررة لا تولد نسخة جديدة', () async {
      final now = DateTime.now().toUtc();
      final task = TaskModel(
        id: 'task-plain',
        areaId: 'area-work-main',
        title: 'مهمة عادية',
        createdAt: now,
        updatedAt: now,
      );
      final next = await RecurrenceService.generateNextRecurrence(
        task,
        taskRepo: taskRepo,
        subtaskRepo: subtaskRepo,
      );
      expect(next, isNull);
      expect(await taskRepo.getTasks(), isEmpty);
    });

    test('توليد مهمة يومية بعد الإنجاز مع نسخ المهام الفرعية', () async {
      final now = DateTime.now().toUtc();
      final source = TaskModel(
        id: 'task-recurring',
        areaId: 'area-work-main',
        title: 'رياضة يومية',
        priority: 'high',
        dueDate: DateTime(2026, 9, 8, 7, 0),
        isRecurring: true,
        recurrencePattern: TaskRecurrencePattern.daily,
        recurrenceInterval: 1,
        createdAt: now,
        updatedAt: now,
      );
      await taskRepo.insertTask(source);
      await subtaskRepo.insertSubtask(SubtaskModel(
        id: 'sub-1',
        taskId: source.id,
        title: 'إحماء',
        createdAt: now,
        updatedAt: now,
      ));

      final next = await RecurrenceService.generateNextRecurrence(
        source,
        taskRepo: taskRepo,
        subtaskRepo: subtaskRepo,
      );

      expect(next, isNotNull);
      expect(next!.id, isNot(source.id));
      expect(next.title, 'رياضة يومية');
      expect(next.status, 'todo');
      expect(next.isRecurring, isTrue);
      expect(next.recurrencePattern, TaskRecurrencePattern.daily);
      expect(next.dueDate, DateTime(2026, 9, 9, 7, 0));
      expect(next.shareToken, isNull);

      final copied = await subtaskRepo.getSubtasksForTask(next.id);
      expect(copied, hasLength(1));
      expect(copied.first.title, 'إحماء');
      expect(copied.first.isCompleted, isFalse);
    });

    test('انتهاء التكرار يمنع توليد نسخة جديدة', () async {
      final now = DateTime.now().toUtc();
      final task = TaskModel(
        id: 'task-ended',
        areaId: 'area-work-main',
        title: 'مهمة منتهية',
        dueDate: DateTime(2026, 9, 8, 7, 0),
        isRecurring: true,
        recurrencePattern: TaskRecurrencePattern.daily,
        recurrenceEndDate: DateTime(2026, 9, 8, 23, 59),
        createdAt: now,
        updatedAt: now,
      );
      await taskRepo.insertTask(task);

      final next = await RecurrenceService.generateNextRecurrence(
        task,
        taskRepo: taskRepo,
        subtaskRepo: subtaskRepo,
      );
      expect(next, isNull);
      expect(await taskRepo.getTasks(), hasLength(1));
    });
  });

  group('TasksController يتكامل مع التكرار', () {
    test('إكمال مهمة متكررة يولّد النسخة التالية تلقائياً', () async {
      final controller = TasksController();
      final now = DateTime.now().toUtc();
      await controller.createTask(TaskModel(
        id: 'task-auto-recur',
        areaId: 'area-work-main',
        title: 'تقرير أسبوعي',
        dueDate: DateTime(2026, 9, 8, 7, 0),
        isRecurring: true,
        recurrencePattern: TaskRecurrencePattern.weekly,
        createdAt: now,
        updatedAt: now,
      ));

      await controller.updateStatus('task-auto-recur', 'completed');

      final tasks = controller.tasks;
      expect(tasks.where((t) => t.id == 'task-auto-recur').first.status, 'completed');
      final recurring = tasks.where((t) => t.status == 'todo').toList();
      expect(recurring, hasLength(1));
      expect(recurring.first.title, 'تقرير أسبوعي');
      expect(
        recurring.first.dueDate!.isAtSameMomentAs(DateTime(2026, 9, 15, 7, 0)),
        isTrue,
      );
    });

    test('إكمال مهمة عادية لا يولّد نسخاً', () async {
      final controller = TasksController();
      final now = DateTime.now().toUtc();
      await controller.createTask(TaskModel(
        id: 'task-simple-complete',
        areaId: 'area-work-main',
        title: 'مهمة عادية',
        createdAt: now,
        updatedAt: now,
      ));

      await controller.updateStatus('task-simple-complete', 'completed');
      expect(controller.completedTasks.map((t) => t.id), contains('task-simple-complete'));
      expect(controller.tasks, hasLength(1));
    });
  });
}