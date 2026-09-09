import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/services/attachment_service.dart';
import 'package:tasky/features/tasks/data/models/attachment_model.dart';
import 'package:tasky/features/tasks/data/repositories/attachment_repository_impl.dart';
import 'package:tasky/features/tasks/presentation/widgets/task_attachments_section.dart';

class _FakeRepository implements IAttachmentRepository {
  final Map<String, Map<String, dynamic>> rows = {};

  @override
  Future<List<AttachmentModel>> getAttachmentsByTask(String taskId) async {
    final list = rows.values
        .where((r) => r['task_id'] == taskId && r['deleted_at'] == null)
        .toList()
      ..sort((a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String));
    return list.map(AttachmentModel.fromMap).toList();
  }

  @override
  Future<AttachmentModel?> getAttachmentById(String id) async {
    final row = rows[id];
    return row == null ? null : AttachmentModel.fromMap(row);
  }

  @override
  Future<void> insertAttachment(AttachmentModel attachment) async {
    rows[attachment.id] = attachment.toMap();
  }

  @override
  Future<void> updateAttachment(AttachmentModel attachment) async {
    rows[attachment.id] = attachment.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending_update',
    ).toMap();
  }

  @override
  Future<void> softDeleteAttachment(String id) async {
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
  Future<List<AttachmentModel>> getAttachmentsBySyncStatus(String syncStatus) async {
    return rows.values
        .where((r) => r['sync_status'] == syncStatus)
        .map(AttachmentModel.fromMap)
        .toList();
  }
}

class _FakeStorage implements AttachmentStorageCloud {
  String signedUrlValue = 'https://cdn.example/tasky-attachments/signed/report.pdf';

  @override
  Future<String> upload({
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    return path;
  }

  @override
  Future<void> delete(String path) async {}

  @override
  Future<String?> signedUrl(String path) async => signedUrlValue;
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('يظهر حالة فارغة ثم يُضاف مرفق عبر منتقي الملفات', (tester) async {
    final service = AttachmentService(
      repository: _FakeRepository(),
      storage: _FakeStorage(),
      isWeb: true,
    );

    await tester.pumpWidget(_wrap(TaskAttachmentsSection(
      taskId: 'task-1',
      service: service,
      pickFile: () async => PickedAttachment(
        fileName: 'plan.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList(List<int>.filled(128, 7)),
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.text('المرفقات (0)'), findsOneWidget);
    expect(find.textContaining('لا توجد مرفقات بعد'), findsOneWidget);

    await tester.tap(find.byTooltip('إضافة مرفق'));
    await tester.pumpAndSettle();

    expect(find.text('المرفقات (1)'), findsOneWidget);
    expect(find.text('plan.pdf'), findsOneWidget);
    expect(find.text('1 KB'), findsOneWidget);
    expect(find.textContaining('قيد المزامنة'), findsOneWidget);
  });

  testWidgets('الضغط على زر التنزيل يفتح الرابط الموقّع من التخزين عبر openUrl', (tester) async {
    final now = DateTime.now().toUtc();
    final fakeRepo = _FakeRepository();
    fakeRepo.insertAttachment(AttachmentModel(
      id: 'att-cloud',
      taskId: 'task-1',
      fileName: 'report.pdf',
      fileSize: 1024,
      mimeType: 'application/pdf',
      fileUrl: 'user-1/att-cloud/report.pdf',
      syncStatus: 'synced',
      createdAt: now,
      updatedAt: now,
    ));
    final storage = _FakeStorage();
    storage.signedUrlValue = 'https://cdn.example/tasky-attachments/signed/report.pdf';
    final service = AttachmentService(
      repository: fakeRepo,
      storage: storage,
      isWeb: true,
    );
    String? openedUrl;

    await tester.pumpWidget(_wrap(TaskAttachmentsSection(
      taskId: 'task-1',
      service: service,
      openUrl: (url) async => openedUrl = url,
    )));
    await tester.pumpAndSettle();

    expect(find.text('report.pdf'), findsOneWidget);
    expect(find.text('✓ مزامن'), findsOneWidget);

    await tester.tap(find.byTooltip('فتح / تنزيل المرفق'));
    await tester.pumpAndSettle();

    expect(openedUrl, 'https://cdn.example/tasky-attachments/signed/report.pdf');
  });

  testWidgets('حذف مرفق بعد تأكيد حوار الحذف', (tester) async {
    final fakeRepo = _FakeRepository();
    final service = AttachmentService(
      repository: fakeRepo,
      storage: _FakeStorage(),
      isWeb: true,
    );

    await tester.pumpWidget(_wrap(TaskAttachmentsSection(
      taskId: 'task-1',
      service: service,
      pickFile: () async => PickedAttachment(
        fileName: 'draft.txt',
        mimeType: 'text/plain',
        bytes: Uint8List.fromList(List<int>.filled(16, 2)),
      ),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('إضافة مرفق'));
    await tester.pumpAndSettle();
    expect(find.text('draft.txt'), findsOneWidget);

    await tester.tap(find.byTooltip('حذف المرفق'));
    await tester.pumpAndSettle();
    expect(find.text('حذف المرفق'), findsWidgets);

    await tester.tap(find.text('نعم، احذف'));
    await tester.pumpAndSettle();

    expect(find.text('draft.txt'), findsNothing);
    expect(find.text('المرفقات (0)'), findsOneWidget);
  });
}