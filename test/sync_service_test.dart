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
}
