import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/notes/data/models/note_model.dart';
import 'package:tasky/features/notes/data/repositories/note_repository_impl.dart';
import 'package:tasky/features/notes/presentation/controllers/notes_controller.dart';
import 'package:tasky/features/notes/presentation/screens/notes_screen.dart';

class _FakeNoteRepo implements INoteRepository {
  final Map<String, Map<String, dynamic>> rows = {};

  @override
  Future<List<NoteModel>> getNotes({bool includeArchived = false}) async {
    final list = rows.values.where((r) {
      if (r['deleted_at'] != null) return false;
      if (!includeArchived && (r['is_archived'] as int? ?? 0) == 1) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final pa = a['is_pinned'] as int? ?? 0;
        final pb = b['is_pinned'] as int? ?? 0;
        if (pa != pb) return pb.compareTo(pa);
        return (b['updated_at'] as String).compareTo(a['updated_at'] as String);
      });
    return list.map(NoteModel.fromMap).toList();
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    final row = rows[id];
    return row == null ? null : NoteModel.fromMap(row);
  }

  @override
  Future<void> insertNote(NoteModel note) async {
    rows[note.id] = note.toMap();
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    rows[note.id] = note
        .copyWith(updatedAt: DateTime.now().toUtc(), syncStatus: 'pending_update')
        .toMap();
  }

  @override
  Future<void> softDeleteNote(String id) async {
    final row = rows[id];
    if (row == null) return;
    final now = DateTime.now().toUtc().toIso8601String();
    rows[id] = {
      ...row,
      'deleted_at': now,
      'sync_status': 'pending_delete',
      'updated_at': now,
    };
  }

  @override
  Future<List<NoteModel>> getNotesBySyncStatus(String syncStatus) async {
    return rows.values
        .where((r) => r['sync_status'] == syncStatus)
        .map(NoteModel.fromMap)
        .toList();
  }
}

Widget _wrap(NotesController controller) =>
    MaterialApp(home: Scaffold(body: NotesScreen(controller: controller)));

void main() {
  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.byTooltip('ملاحظة جديدة'));
    await tester.pumpAndSettle();
  }

  Future<void> fillEditorAndSave(
    WidgetTester tester, {
    required String title,
    String content = '',
  }) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextField, 'العنوان'),
      ),
      title,
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextField, 'المحتوى'),
      ),
      content,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة'));
    await tester.pumpAndSettle();
  }

  testWidgets('يعرض الحالة الفارغة عند عدم وجود ملاحظات', (tester) async {
    final controller = NotesController(repository: _FakeNoteRepo());

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('الملاحظات ومستودع المعرفة'), findsOneWidget);
    expect(find.text('لا توجد ملاحظات بعد'), findsOneWidget);
  });

  testWidgets('إضافة ملاحظة عبر محرر الحوار تظهر كبطاقة', (tester) async {
    final controller = NotesController(repository: _FakeNoteRepo());

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await openEditor(tester);
    expect(find.text('ملاحظة جديدة'), findsOneWidget);

    await fillEditorAndSave(tester, title: 'فكرة جديدة', content: 'نص الفكرة');

    expect(find.text('فكرة جديدة'), findsOneWidget);
    expect(find.text('نص الفكرة'), findsOneWidget);
    expect(find.text('لا توجد ملاحظات بعد'), findsNothing);
  });

  testWidgets('تثبيت ملاحظة ينقلها إلى قسم المثبتة (Pinned)', (tester) async {
    final controller = NotesController(repository: _FakeNoteRepo());
    await controller.add(title: 'ملاحظة هامة', content: 'محتوى هام');

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تثبيت'));
    await tester.pumpAndSettle();

    expect(find.text('المثبتة'), findsOneWidget);
    expect(find.text('ملاحظة هامة'), findsOneWidget);
  });

  testWidgets('البحث اللحظي يفلتر العناوين والمحتوى', (tester) async {
    final controller = NotesController(repository: _FakeNoteRepo());
    await controller.add(title: 'مواعيد الدفع', content: 'Ref accountant');
    await controller.add(title: 'قائمة التسوق', content: 'حليب وخبز');

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'حليب');
    await tester.pumpAndSettle();

    expect(find.text('قائمة التسوق'), findsOneWidget);
    expect(find.text('مواعيد الدفع'), findsNothing);
  });

  testWidgets('حذف ملاحظة بعد تأكيد الحوار يزيل البطاقة', (tester) async {
    final controller = NotesController(repository: _FakeNoteRepo());
    await controller.add(title: 'ملاحظة الحذف', content: null);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('ملاحظة الحذف'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    expect(find.text('ملاحظة الحذف'), findsWidgets);

    await tester.tap(find.text('نعم، احذف'));
    await tester.pumpAndSettle();

    expect(find.text('ملاحظة الحذف'), findsNothing);
    expect(find.text('لا توجد ملاحظات بعد'), findsOneWidget);
  });
}