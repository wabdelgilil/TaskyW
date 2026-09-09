import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/features/tasks/services/attachment_service.dart';
import 'package:tasky/core/services/sync_service.dart';
import 'package:tasky/features/tasks/data/models/attachment_model.dart';
import 'package:tasky/features/tasks/data/repositories/attachment_repository_impl.dart';

class _FakeStorage implements AttachmentStorageCloud {
  final uploaded = <String, List<int>>{};
  final removed = <String>[];
  String? signedUrlValue = 'https://fake.example/signed/file';

  @override
  Future<String> upload({
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    uploaded[path] = bytes;
    return path;
  }

  @override
  Future<void> delete(String path) async {
    removed.add(path);
  }

  @override
  Future<String?> signedUrl(String path) async => signedUrlValue;
}

Future<void> _seedAreaAndTask() async {
  final db = await AppDatabase.instance.database;
  final now = DateTime.now().toUtc().toIso8601String();
  await db.insert('areas', {
    'id': 'area-1',
    'name': 'مجال',
    'created_at': now,
    'updated_at': now,
    'sync_status': 'synced',
  });
  await db.insert('tasks', {
    'id': 'task-1',
    'area_id': 'area-1',
    'title': 'مهمة',
    'created_at': now,
    'updated_at': now,
    'sync_status': 'synced',
  });
  await db.insert('tasks', {
    'id': 'task-other',
    'area_id': 'area-1',
    'title': 'مهمة أخرى',
    'created_at': now,
    'updated_at': now,
    'sync_status': 'synced',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.inMemory = true;
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
  });

  group('AttachmentModel', () {
    test('toMap/fromMap round-trip بعدّ الحقول كاملة', () {
      final now = DateTime.now().toUtc();
      final model = AttachmentModel(
        id: 'att-1',
        taskId: 'task-1',
        fileName: 'تقرير.pdf',
        filePath: r'C:\tmp\att-1.pdf',
        fileSize: 2048,
        mimeType: 'application/pdf',
        fileUrl: 'user-1/att-1/تقرير.pdf',
        syncStatus: 'synced',
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );

      final restored = AttachmentModel.fromMap(model.toMap());
      expect(restored.id, 'att-1');
      expect(restored.taskId, 'task-1');
      expect(restored.fileName, 'تقرير.pdf');
      expect(restored.filePath, r'C:\tmp\att-1.pdf');
      expect(restored.fileSize, 2048);
      expect(restored.mimeType, 'application/pdf');
      expect(restored.fileUrl, 'user-1/att-1/تقرير.pdf');
      expect(restored.syncStatus, 'synced');
      expect(restored.deletedAt, isNull);
    });

    test('لما تك الحقول الاختيارية غائبة تحصل قيم افتراضية آمنة', () {
      final now = DateTime.now().toUtc();
      final map = {
        'id': 'a9',
        'task_id': 't9',
        'file_name': 'x.txt',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final model = AttachmentModel.fromMap(map);
      expect(model.fileSize, 0);
      expect(model.fileUrl, isNull);
      expect(model.syncStatus, 'pending_insert');
      expect(model.filePath, isNull);
    });

    test('copyWith يبدّل الحقول المطلوبة فقط', () {
      final now = DateTime.now().toUtc();
      final model = AttachmentModel(
        id: 'a1',
        taskId: 't1',
        fileName: 'old.txt',
        createdAt: now,
        updatedAt: now,
      );
      final updated = model.copyWith(fileUrl: 'u/a1/x.txt', syncStatus: 'synced');
      expect(updated.fileUrl, 'u/a1/x.txt');
      expect(updated.syncStatus, 'synced');
      expect(updated.fileName, 'old.txt');
      expect(updated.id, 'a1');
    });
  });

  group('AttachmentRepositoryImpl', () {
    late AttachmentRepositoryImpl repo;

    setUp(() => repo = AttachmentRepositoryImpl());

    test('إدراج وقراءة مرفقات مهمة معينة (تُستبعد المارحة المحذوفة)', () async {
      await _seedAreaAndTask();
      final now = DateTime.now().toUtc();
      await repo.insertAttachment(AttachmentModel(
        id: 'a1',
        taskId: 'task-1',
        fileName: 'doc.pdf',
        fileSize: 10,
        createdAt: now,
        updatedAt: now,
      ));
      await repo.insertAttachment(AttachmentModel(
        id: 'a2',
        taskId: 'task-1',
        fileName: 'img.png',
        fileSize: 20,
        createdAt: now,
        updatedAt: now,
      ));
      await repo.insertAttachment(AttachmentModel(
        id: 'a3',
        taskId: 'task-other',
        fileName: 'other.txt',
        fileSize: 30,
        createdAt: now,
        updatedAt: now,
      ));

      final taskAttachments = await repo.getAttachmentsByTask('task-1');
      expect(taskAttachments.map((a) => a.id), containsAll(['a1', 'a2']));
      expect(taskAttachments.any((a) => a.id == 'a3'), isFalse);
    });

    test('الحذف الناعم يضبط sync_status المطلوب ويخفي المرفق', () async {
      await _seedAreaAndTask();
      final now = DateTime.now().toUtc();
      await repo.insertAttachment(AttachmentModel(
        id: 'a-del',
        taskId: 'task-1',
        fileName: 'to-remove.pdf',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.softDeleteAttachment('a-del');

      final byId = await repo.getAttachmentById('a-del');
      expect(byId, isNotNull);
      expect(byId!.syncStatus, 'pending_delete');
      expect(byId.deletedAt, isNotNull);

      final visible = await repo.getAttachmentsByTask('task-1');
      expect(visible, isEmpty);

      final pending = await repo.getAttachmentsBySyncStatus('pending_delete');
      expect(pending.map((a) => a.id), contains('a-del'));
    });
  });

  group('AttachmentService', () {
    test('addAttachment يبقي مرفقاً محلياً بحالة pending_insert ويحفظ ملفاً محلياً', () async {
      await _seedAreaAndTask();
      final service = AttachmentService(
        repository: AttachmentRepositoryImpl(),
        storage: _FakeStorage(),
        isWeb: false,
      );
      final bytes = List<int>.generate(64, (i) => i % 256);

      final model = await service.addAttachment(
        taskId: 'task-1',
        fileName: 'report.txt',
        fileSize: bytes.length,
        mimeType: 'text/plain',
        bytes: bytes,
      );

      expect(model.id, isNotEmpty);
      expect(model.syncStatus, 'pending_insert');
      expect(model.fileUrl, isNull);
      expect(model.filePath, isNotNull);

      final saved = File(model.filePath!);
      expect(await saved.exists(), isTrue);
      expect(await saved.readAsBytes(), bytes);

      final list = await service.getAttachments('task-1');
      expect(list.single.id, model.id);
    });

    test('getDownloadUrl يعيد رابطاً موقّعاً من التخزين عند وجود fileUrl', () async {
      await _seedAreaAndTask();
      final storage = _FakeStorage();
      final service = AttachmentService(
        repository: AttachmentRepositoryImpl(),
        storage: storage,
        isWeb: true,
      );
      await service.addAttachment(
        taskId: 'task-1',
        fileName: 'cloud.pdf',
        fileSize: 1,
        mimeType: 'application/pdf',
      );
      final local = await service.getAttachments('task-1');
      final withUrl = local.single.copyWith(
        fileUrl: 'user-1/${local.single.id}/cloud.pdf',
        syncStatus: 'synced',
      );

      final url = await service.getDownloadUrl(withUrl);
      expect(url, 'https://fake.example/signed/file');
    });

    test('getDownloadUrl يعيد مساراً محلياً إذا لم يُرفع المرفق بعد', () async {
      await _seedAreaAndTask();
      final service = AttachmentService(
        repository: AttachmentRepositoryImpl(),
        storage: _FakeStorage(),
        isWeb: false,
      );
      await service.addAttachment(
        taskId: 'task-1',
        fileName: 'local.bin',
        fileSize: 8,
        bytes: List<int>.filled(8, 0),
      );
      final local = (await service.getAttachments('task-1')).single;

      final url = await service.getDownloadUrl(local);
      expect(url, startsWith('file://'));
    });

    test('deleteAttachment يحوّل المرفق إلى pending_delete', () async {
      await _seedAreaAndTask();
      final service = AttachmentService(
        repository: AttachmentRepositoryImpl(),
        storage: _FakeStorage(),
        isWeb: true,
      );
      await service.addAttachment(
        taskId: 'task-1',
        fileName: 'gone.pdf',
        fileSize: 4,
      );
      final local = (await service.getAttachments('task-1')).single;

      await service.deleteAttachment(local.id);
      expect(await service.getAttachments('task-1'), isEmpty);

      final all = await AttachmentRepositoryImpl()
          .getAttachmentsBySyncStatus('pending_delete');
      expect(all.single.id, local.id);
    });
  });

  group('SyncServiceAttachment (تكامل المزامنة للمرفقات)', () {
    test('toCloudPayload لا يضيف file_path لأعمدة المزامنة (العمود محلي فقط)', () {
      final row = {
        'id': 'att-1',
        'task_id': 'task-1',
        'file_name': 'x.pdf',
        'file_path': r'C:\tmp\att-1.pdf',
        'file_url': null,
        'sync_status': 'pending_insert',
        'created_at': '2026-09-08T00:00:00.000Z',
        'updated_at': '2026-09-08T00:00:00.000Z',
        'deleted_at': null,
      };
      final payload = SyncService.toCloudPayload(row, 'user-1');

      expect(payload.containsKey('user_id'), isTrue);
      expect(payload['user_id'], 'user-1');
      expect(payload.containsKey('sync_status'), isFalse);
      expect(payload.containsKey('file_path'), isTrue);
      expect(payload['file_name'], 'x.pdf');
    });

    test('toLocalRow للمرفقات يحتفظ فقط بالأعمدة المعتمدة وبلا file_path من السحابة', () {
      const validColumns = [
        'id', 'task_id', 'file_name', 'file_size', 'mime_type', 'file_url',
        'sync_status', 'created_at', 'updated_at', 'deleted_at',
      ];
      final cloudRow = {
        'id': 'att-c',
        'task_id': 'task-1',
        'user_id': 'user-1',
        'file_name': 'cloud.pdf',
        'file_size': 100,
        'mime_type': 'application/pdf',
        'file_url': 'user-1/att-c/cloud.pdf',
        'file_path': '/tmp/should-not-exist.pdf',
        'created_at': '2026-09-08T00:00:00.000Z',
        'updated_at': '2026-09-08T00:00:00.000Z',
        'deleted_at': null,
      };

      final localRow = SyncService.toLocalRow(cloudRow, validColumns);

      expect(localRow.containsKey('user_id'), isFalse);
      expect(localRow.containsKey('file_path'), isFalse);
      expect(localRow['file_url'], 'user-1/att-c/cloud.pdf');
      expect(localRow['file_name'], 'cloud.pdf');
      expect(localRow['sync_status'], 'synced');
    });
  });
}