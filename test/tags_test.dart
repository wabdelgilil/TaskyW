import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/models/tag_model.dart';
import 'package:tasky/core/repositories/tag_repository_impl.dart';
import 'package:tasky/features/tags/presentation/controllers/tags_controller.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';

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

  group('TagModel', () {
    test('toMap/fromMap round-trip', () {
      final tag = TagModel(
        id: 'tag-1',
        name: 'عاجل',
        colorHex: '#EF4444',
        orderIndex: 2,
        createdAt: DateTime.utc(2026, 9, 8),
        updatedAt: DateTime.utc(2026, 9, 8, 10),
      );
      final map = tag.toMap();
      final restored = TagModel.fromMap(map);
      expect(restored, tag);
    });

    test('fromMap يستخدم قيماً افتراضية عند غياب الحقول', () {
      final tag = TagModel.fromMap({
        'id': 'tag-x',
        'name': 'مخلص',
        'created_at': '2026-09-08T00:00:00.000Z',
        'updated_at': '2026-09-08T00:00:00.000Z',
      });
      expect(tag.colorHex, '#64748B');
      expect(tag.orderIndex, 0);
      expect(tag.syncStatus, 'pending_insert');
    });
  });

  group('TagRepositoryImpl', () {
    test('إنشاء وقراءة وتعديل وحذف هادئ', () async {
      final repo = TagRepositoryImpl();
      final now = DateTime.now().toUtc();
      await repo.insertTag(TagModel(
        id: 'tag-repo-1',
        name: 'ماليات',
        createdAt: now,
        updatedAt: now,
      ));

      final fetched = await repo.getTagById('tag-repo-1');
      expect(fetched?.name, 'ماليات');

      await repo.updateTag(fetched!.copyWith(name: 'ماليات معدل'));
      expect((await repo.getTagById('tag-repo-1'))?.name, 'ماليات معدل');

      await repo.softDeleteTag('tag-repo-1');
      expect(await repo.getTagById('tag-repo-1'), isNull);
      expect(await repo.getAllTags(), isEmpty);
    });

    test('إسناد وفك الوسوم عن المهام', () async {
      final repo = TagRepositoryImpl();
      final now = DateTime.now().toUtc();
      await repo.insertTag(TagModel(id: 'tag-a', name: 'أ', createdAt: now, updatedAt: now));

      await TaskRepositoryImpl().insertTask(TaskModel(
        id: 'task-tag-1',
        areaId: 'area-work-main',
        title: 'مهمة موسومة',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.assignTagToTask('task-tag-1', 'tag-a');
      expect((await repo.getTagsForTask('task-tag-1')).length, 1);
      expect(await repo.getTaskIdsForTag('tag-a'), ['task-tag-1']);

      await repo.removeTagFromTask('task-tag-1', 'tag-a');
      expect(await repo.getTagsForTask('task-tag-1'), isEmpty);
      expect(await repo.getTaskIdsForTag('tag-a'), isEmpty);
    });

    test('التخصيص المكرر لا يكرر الربط (PK مركب)', () async {
      final repo = TagRepositoryImpl();
      final now = DateTime.now().toUtc();
      await repo.insertTag(TagModel(id: 'tag-dd', name: 'د', createdAt: now, updatedAt: now));
      await TaskRepositoryImpl().insertTask(TaskModel(
        id: 'task-dd',
        areaId: 'area-work-main',
        title: 'مهمة',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.assignTagToTask('task-dd', 'tag-dd');
      await repo.assignTagToTask('task-dd', 'tag-dd');
      expect(await repo.getTagsForTask('task-dd'), hasLength(1));
    });

    test('ربط الوسم يحمل id و sync_status للمزامنة السحابية', () async {
      final repo = TagRepositoryImpl();
      final now = DateTime.now().toUtc();
      await repo.insertTag(TagModel(id: 'tag-sync', name: 'مزامن', createdAt: now, updatedAt: now));
      await TaskRepositoryImpl().insertTask(TaskModel(
        id: 'task-sync',
        areaId: 'area-work-main',
        title: 'مهمة',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.assignTagToTask('task-sync', 'tag-sync');
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'task_tags',
        where: 'task_id = ?',
        whereArgs: ['task-sync'],
      );
      expect(rows, hasLength(1));
      expect(rows.first['id'], 'task-sync|tag-sync');
      expect(rows.first['sync_status'], 'pending_insert');
      expect(rows.first['updated_at'], isNotNull);
    });

    test('فك الوسم يحوّله إلى pending_delete ثم الاستعادة تعيد التفعيل', () async {
      final repo = TagRepositoryImpl();
      final now = DateTime.now().toUtc();
      await repo.insertTag(TagModel(id: 'tag-restore', name: 'استعادة', createdAt: now, updatedAt: now));
      await TaskRepositoryImpl().insertTask(TaskModel(
        id: 'task-restore',
        areaId: 'area-work-main',
        title: 'مهمة',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.assignTagToTask('task-restore', 'tag-restore');
      await repo.removeTagFromTask('task-restore', 'tag-restore');
      final db = await AppDatabase.instance.database;
      final afterRemove = await db.query(
        'task_tags',
        columns: ['deleted_at', 'sync_status'],
        where: 'task_id = ?',
        whereArgs: ['task-restore'],
      );
      expect(afterRemove.single['deleted_at'], isNotNull);
      expect(afterRemove.single['sync_status'], 'pending_delete');

      await repo.assignTagToTask('task-restore', 'tag-restore');
      expect(await repo.getTagsForTask('task-restore'), hasLength(1));
      final afterRestore = await db.query(
        'task_tags',
        columns: ['deleted_at', 'sync_status'],
        where: 'task_id = ?',
        whereArgs: ['task-restore'],
      );
      expect(afterRestore.single['deleted_at'], isNull);
      expect(afterRestore.single['sync_status'], 'pending_insert');
    });
  });

  group('TagsController', () {
    test('إنشاء وتحميل واختيار وسم', () async {
      final controller = TagsController();
      await controller.createTag(name: 'عاجل جداً', colorHex: '#EF4444');
      expect(controller.tags.length, 1);
      expect(controller.tags.first.colorHex, '#EF4444');

      controller.selectTag(controller.tags.first.id);
      expect(controller.selectedTag?.name, 'عاجل جداً');
      expect(controller.hasActiveTagFilter, isTrue);
    });

    test('تعديل وحذف وسم', () async {
      final controller = TagsController();
      await controller.createTag(name: 'وسم للتعديل');
      final tag = controller.tags.first;

      await controller.updateTag(tag.copyWith(name: 'معدل'));
      expect(controller.tags.first.name, 'معدل');

      await controller.deleteTag(tag.id);
      expect(controller.tags, isEmpty);
    });

    test('فلترة المهام حسب الوسم النشط', () async {
      final controller = TagsController();
      final now = DateTime.now().toUtc();
      await controller.createTag(name: 'مكتب');
      final tag = controller.tags.first;

      final taskRepo = TaskRepositoryImpl();
      await taskRepo.insertTask(TaskModel(
        id: 'task-in-tag',
        areaId: 'area-work-main',
        title: 'داخل الوسم',
        createdAt: now,
        updatedAt: now,
      ));
      await taskRepo.insertTask(TaskModel(
        id: 'task-out-tag',
        areaId: 'area-work-main',
        title: 'خارج الوسم',
        createdAt: now,
        updatedAt: now,
      ));

      await controller.assignTagToTask('task-in-tag', tag.id);
      controller.selectTag(tag.id);
      await controller.refreshActiveTagTaskIds();

      final tasks = await taskRepo.getTasks();
      final filtered = controller.filterTasksByActiveTag(tasks);
      expect(filtered.map((t) => t.id), ['task-in-tag']);

      controller.clearTagFilter();
      expect(controller.filterTasksByActiveTag(tasks), hasLength(2));
    });

    test('حذف الوسم النشط يزيل الفلترة', () async {
      final controller = TagsController();
      await controller.createTag(name: 'وسم حذف');
      final tag = controller.tags.first;
      controller.selectTag(tag.id);

      await controller.deleteTag(tag.id);
      expect(controller.selectedTagId, isNull);
      expect(controller.hasActiveTagFilter, isFalse);
    });
  });
}