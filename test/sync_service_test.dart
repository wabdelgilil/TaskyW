import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/services/sync_service.dart';

void main() {
  group('SyncService.shouldOverlayCloud', () {
    test('الصف الجديد في السحابة (لا يوجد محلي) يُنزّل دائماً', () {
      final cloud = {
        'id': 't1',
        'updated_at': '2025-01-01T00:00:00.000Z',
        'sync_status': 'synced',
      };
      expect(SyncService.shouldOverlayCloud(localRow: null, cloudRow: cloud), isTrue);
    });

    test('صف محلي pending لا يُستبدل أبداً بالنسخة السحابية الأحدث', () {
      final local = {
        'id': 't1',
        'sync_status': 'pending_update',
        'updated_at': '2025-01-01T00:00:00.000Z',
        'deleted_at': null,
      };
      final cloud = {
        'id': 't1',
        'updated_at': '2025-01-02T00:00:00.000Z',
      };
      expect(SyncService.shouldOverlayCloud(localRow: local, cloudRow: cloud), isFalse);
    });

    test('صف حالي (غير pending) يتحدّث إذا كانت السحابة أحدث', () {
      final local = {
        'id': 't1',
        'sync_status': 'synced',
        'updated_at': '2025-01-01T00:00:00.000Z',
        'deleted_at': null,
      };
      final cloud = {
        'id': 't1',
        'updated_at': '2025-01-02T00:00:00.000Z',
      };
      expect(SyncService.shouldOverlayCloud(localRow: local, cloudRow: cloud), isTrue);
    });

    test('صف محلي أحدث من السحابة لا يُستبدل (last-writer-wins محلي)', () {
      final local = {
        'id': 't1',
        'sync_status': 'synced',
        'updated_at': '2025-01-05T00:00:00.000Z',
        'deleted_at': null,
      };
      final cloud = {
        'id': 't1',
        'updated_at': '2025-01-02T00:00:00.000Z',
      };
      expect(SyncService.shouldOverlayCloud(localRow: local, cloudRow: cloud), isFalse);
    });

    test('صف محلي محذوف (deleted_at) لا يُستبدل بالسحابة', () {
      final local = {
        'id': 't1',
        'sync_status': 'pending_delete',
        'updated_at': '2025-01-05T00:00:00.000Z',
        'deleted_at': '2025-01-06T00:00:00.000Z',
      };
      final cloud = {
        'id': 't1',
        'updated_at': '2025-01-07T00:00:00.000Z',
      };
      expect(SyncService.shouldOverlayCloud(localRow: local, cloudRow: cloud), isFalse);
    });

    test('عند تساوي التوقيتات تُعطى الأولوية للسحابة', () {
      final local = {
        'id': 't1',
        'sync_status': 'synced',
        'updated_at': '2025-01-01T00:00:00.000Z',
        'deleted_at': null,
      };
      final cloud = {
        'id': 't1',
        'updated_at': '2025-01-01T00:00:00.000Z',
      };
      expect(SyncService.shouldOverlayCloud(localRow: local, cloudRow: cloud), isTrue);
    });

    test('تتجاهل تنسيق DateTime مباشر وليس نصاً فقط', () {
      final local = {
        'id': 't1',
        'sync_status': 'synced',
        'updated_at': DateTime.utc(2025, 1, 1),
        'deleted_at': null,
      };
      final cloud = {
        'id': 't1',
        'updated_at': DateTime.utc(2025, 1, 2),
      };
      expect(SyncService.shouldOverlayCloud(localRow: local, cloudRow: cloud), isTrue);
    });
  });

  group('SyncService.toLocalRow', () {
    test('يزيل user_id ويحتفظ فقط بالأعمدة المعتمدة محلياً ويضبط sync_status = synced', () {
      final cloudRow = {
        'id': 'area-1',
        'user_id': 'user-uuid-1234',
        'name': 'Area Test',
        'icon_emoji': '📁',
        'color_hex': '#3B82F6',
        'order_index': 0,
        'created_at': '2026-09-08T00:00:00.000Z',
        'updated_at': '2026-09-08T00:00:00.000Z',
        'deleted_at': null,
        'extra_cloud_field': 'ignore_me',
      };

      final validColumns = [
        'id', 'name', 'icon_emoji', 'color_hex', 'order_index',
        'sync_status', 'created_at', 'updated_at', 'deleted_at',
      ];

      final localRow = SyncService.toLocalRow(cloudRow, validColumns);

      expect(localRow.containsKey('user_id'), isFalse);
      expect(localRow.containsKey('extra_cloud_field'), isFalse);
      expect(localRow['id'], equals('area-1'));
      expect(localRow['name'], equals('Area Test'));
      expect(localRow['sync_status'], equals('synced'));
    });

    test('يحوّل is_completed من boolean إلى integer (0/1)', () {
      final cloudRow = {
        'id': 'subtask-1',
        'user_id': 'u1',
        'task_id': 't1',
        'title': 'Subtask',
        'is_completed': true,
        'order_index': 0,
        'created_at': '2026-09-08T00:00:00.000Z',
        'updated_at': '2026-09-08T00:00:00.000Z',
        'deleted_at': null,
      };

      final validCols = [
        'id', 'task_id', 'title', 'is_completed', 'order_index',
        'sync_status', 'created_at', 'updated_at', 'deleted_at',
      ];

      final localRow = SyncService.toLocalRow(cloudRow, validCols);
      expect(localRow['is_completed'], equals(1));
    });
  });

  group('SyncService.toCloudPayload', () {
    test('يزيل sync_status ويضيف user_id للحمولة السحابية', () {
      final localRow = {
        'id': 'area-1',
        'name': 'Area Test',
        'sync_status': 'pending_insert',
      };

      final payload = SyncService.toCloudPayload(localRow, 'user-uuid-1234');

      expect(payload.containsKey('sync_status'), isFalse);
      expect(payload['user_id'], equals('user-uuid-1234'));
      expect(payload['name'], equals('Area Test'));
    });
  });
}

