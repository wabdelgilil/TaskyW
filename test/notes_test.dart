import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/services/sync_service.dart';
import 'package:tasky/features/notes/data/models/note_model.dart';
import 'package:tasky/features/notes/data/repositories/note_repository_impl.dart';
import 'package:tasky/features/notes/presentation/controllers/notes_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.inMemory = true;
  });

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  group('NoteModel', () {
    test('toMap/fromMap round-trip بكامل الحقول', () {
      final now = DateTime.now().toUtc();
      final note = NoteModel(
        id: 'note-1',
        title: 'فكرة مشروع',
        content: 'ملاحظة مطولة',
        colorHex: '#FFF3B0',
        isPinned: true,
        isArchived: false,
        areaId: 'area-1',
        syncStatus: 'synced',
        createdAt: now,
        updatedAt: now,
      );

      final restored = NoteModel.fromMap(note.toMap());
      expect(restored.id, 'note-1');
      expect(restored.title, 'فكرة مشروع');
      expect(restored.content, 'ملاحظة مطولة');
      expect(restored.colorHex, '#FFF3B0');
      expect(restored.isPinned, isTrue);
      expect(restored.isArchived, isFalse);
      expect(restored.areaId, 'area-1');
      expect(restored.syncStatus, 'synced');
    });

    test('القيم الافتراضية عندما تكون الحقول اختيارية غائبة', () {
      final now = DateTime.now().toUtc();
      final note = NoteModel.fromMap({
        'id': 'n2',
        'title': 'بدون محتوى',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      expect(note.isPinned, isFalse);
      expect(note.isArchived, isFalse);
      expect(note.content, isNull);
      expect(note.syncStatus, 'pending_insert');
    });
  });

  group('NoteRepositoryImpl', () {
    late NoteRepositoryImpl repo;

    setUp(() => repo = NoteRepositoryImpl());

    test('إدراج وقراءة الملاحظات مع ترتيب الثيبينات أولاً', () async {
      final now = DateTime.now().toUtc();
      await repo.insertNote(NoteModel(
        id: 'n1',
        title: 'عادية',
        createdAt: now,
        updatedAt: now,
      ));
      await repo.insertNote(NoteModel(
        id: 'n2',
        title: 'مثبتة',
        isPinned: true,
        createdAt: now,
        updatedAt: now,
      ));

      final notes = await repo.getNotes();
      expect(notes.map((n) => n.id).toList(), ['n2', 'n1']);
    });

    test('الأرشيف لا يظهر في getNotes الافتراضي لكنه يظهر مع includeArchived', () async {
      final now = DateTime.now().toUtc();
      await repo.insertNote(NoteModel(
        id: 'n-arch',
        title: 'مؤرشفة',
        isArchived: true,
        createdAt: now,
        updatedAt: now,
      ));

      expect(await repo.getNotes(), isEmpty);
      expect((await repo.getNotes(includeArchived: true)).single.id, 'n-arch');
    });

    test('الحذف الناعم يضبط pending_delete ويختفي من القائمة', () async {
      final now = DateTime.now().toUtc();
      await repo.insertNote(NoteModel(
        id: 'n-del',
        title: 'للحذف',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.softDeleteNote('n-del');
      expect(await repo.getNotes(), isEmpty);

      final pending = await repo.getNotesBySyncStatus('pending_delete');
      expect(pending.single.id, 'n-del');
    });

    test('updateNote يضبط pending_update', () async {
      final now = DateTime.now().toUtc();
      await repo.insertNote(NoteModel(
        id: 'n-up',
        title: 'أصلي',
        createdAt: now,
        updatedAt: now,
      ));

      final loaded = await repo.getNoteById('n-up');
      await repo.updateNote(loaded!.copyWith(title: 'محدث'));

      final updated = await repo.getNoteById('n-up');
      expect(updated!.title, 'محدث');
      expect(updated.syncStatus, 'pending_update');
    });
  });

  group('NotesController', () {
    test('add يعيد النموذج ويرفعه في القائمة, update يعدّل, remove يحذف', () async {
      final controller = NotesController(repository: NoteRepositoryImpl());
      await controller.load();

      final added = await controller.add(
        title: 'أول ملاحظة',
        content: 'محتوى',
        colorHex: '#FFF3B0',
      );
      expect(added, isNotNull);
      expect(controller.notes.single.title, 'أول ملاحظة');

      await controller.update(id: added!.id, title: 'عنوان جديد');
      expect(controller.notes.single.title, 'عنوان جديد');

      expect(await controller.remove(added.id), isTrue);
      expect(controller.notes, isEmpty);
    });

    test('setPinned ينقل الملاحظة إلى قائمة المثبتة', () async {
      final controller = NotesController(repository: NoteRepositoryImpl());
      await controller.load();
      final added = await controller.add(title: 'هام', content: null);

      expect(await controller.setPinned(added!.id, true), isTrue);
      expect(controller.pinnedNotes.single.id, added.id);
      expect(controller.normalNotes, isEmpty);
    });

    test('setArchived يزيل الملاحظة من القائمة المرئية', () async {
      final controller = NotesController(repository: NoteRepositoryImpl());
      await controller.load();
      final added = await controller.add(title: 'سري', content: null);

      expect(await controller.setArchived(added!.id, true), isTrue);
      expect(controller.notes, isEmpty);
    });

    test('البحث يتطابق مع العنوان والمحتوى فقط', () async {
      final controller = NotesController(repository: NoteRepositoryImpl());
      await controller.load();
      await controller.add(title: 'مواعيد الدفع', content: 'مرجع المحاسبة');
      await controller.add(title: 'قائمة التسوق', content: 'حليب وخبز');

      controller.setQuery('الدفع');
      expect(controller.visibleNotes.single.title, 'مواعيد الدفع');

      controller.setQuery('حليب');
      expect(controller.visibleNotes.single.title, 'قائمة التسوق');

      controller.setQuery('لا يوجد');
      expect(controller.visibleNotes, isEmpty);
    });
  });

  group('SyncServiceNotes (تكامل المزامنة)', () {
    test('toLocalRow يحوّل is_pinned/is_archived من منطقي إلى رقمي', () {
      const validColumns = [
        'id', 'title', 'content', 'color_hex',
        'is_pinned', 'is_archived', 'area_id',
        'sync_status', 'created_at', 'updated_at', 'deleted_at',
      ];
      final cloudRow = {
        'id': 'n1',
        'user_id': 'user-1',
        'title': 'مرجع',
        'content': 'نص',
        'is_pinned': true,
        'is_archived': false,
        'area_id': null,
        'created_at': '2026-09-08T00:00:00.000Z',
        'updated_at': '2026-09-08T00:00:00.000Z',
        'deleted_at': null,
      };

      final localRow = SyncService.toLocalRow(cloudRow, validColumns);
      expect(localRow['is_pinned'], 1);
      expect(localRow['is_archived'], 0);
      expect(localRow.containsKey('user_id'), isFalse);
      expect(localRow['sync_status'], 'synced');
    });

    test('toCloudPayload يضيف user_id ويزيل sync_status', () {
      final now = DateTime.now().toUtc();
      final row = NoteModel(
        id: 'n2',
        title: 'مرجع',
        createdAt: now,
        updatedAt: now,
      ).toMap();
      final payload = SyncService.toCloudPayload(row, 'user-1');
      expect(payload['user_id'], 'user-1');
      expect(payload.containsKey('sync_status'), isFalse);
      expect(payload['is_pinned'], 0);
    });
  });
}