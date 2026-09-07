import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/services/sharing_service.dart';

void main() {
  group('ShareEntityType', () {
    test('fromValue يطابق القيم المعروفة ويتجاهل غيرها', () {
      expect(ShareEntityType.fromValue('area'), ShareEntityType.area);
      expect(ShareEntityType.fromValue('project'), ShareEntityType.project);
      expect(ShareEntityType.fromValue('task'), ShareEntityType.task);
      expect(ShareEntityType.fromValue('unknown'), isNull);
      expect(ShareEntityType.fromValue(null), isNull);
    });
  });

  group('SharePermission', () {
    test('fromValue يطابق القيم المعروفة ويتجاهل غيرها', () {
      expect(SharePermission.fromValue('viewer'), SharePermission.viewer);
      expect(SharePermission.fromValue('editor'), SharePermission.editor);
      expect(SharePermission.fromValue('admin'), SharePermission.admin);
      expect(SharePermission.fromValue('owner'), isNull);
    });
  });

  group('ShareModel', () {
    test('toMap ثم fromMap يحافظان على كل الحقول', () {
      final share = ShareModel(
        id: 'share-1',
        entityType: ShareEntityType.task,
        entityId: 'task-99',
        email: 'demo@example.com',
        displayName: 'متعاون',
        permission: SharePermission.editor,
        shareToken: 'abc123',
        isPublic: true,
        createdAt: DateTime.utc(2025, 5, 1),
        updatedAt: DateTime.utc(2025, 5, 2),
      );

      final restored = ShareModel.fromMap(share.toMap());

      expect(restored.id, 'share-1');
      expect(restored.entityType, ShareEntityType.task);
      expect(restored.entityId, 'task-99');
      expect(restored.email, 'demo@example.com');
      expect(restored.displayName, 'متعاون');
      expect(restored.permission, SharePermission.editor);
      expect(restored.shareToken, 'abc123');
      expect(restored.isPublic, isTrue);
      expect(restored.createdAt, DateTime.utc(2025, 5, 1));
      expect(restored.updatedAt, DateTime.utc(2025, 5, 2));
    });

    test('يستخدم القيم الافتراضية عند غياب الحقول الاختيارية', () {
      final share = ShareModel.fromMap({
        'id': 'share-2',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'created_at': '2025-05-01T00:00:00.000Z',
      });

      expect(share.permission, SharePermission.viewer);
      expect(share.isPublic, isFalse);
      expect(share.email, isNull);
      expect(share.updatedAt, isNull);
    });
  });
}
