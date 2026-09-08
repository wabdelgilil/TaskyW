import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../models/entity_share_model.dart';

/// مستودع المشاركات المحلي (Offline-First).
///
/// يخزّن سجلات `entity_shares` في SQLite لعرضها والعمل بها دون اتصال،
/// ويوفّر فحص الصلاحية السريع `getUserPermission`.
abstract class ICollaborationRepository {
  Future<List<EntityShareModel>> getEntityShares({
    required String entityType,
    required String entityId,
  });

  Future<EntityShareModel?> getShareById(String shareId);

  Future<void> upsertShare(EntityShareModel share);

  Future<void> upsertShares(List<EntityShareModel> shares);

  Future<void> updatePermission({
    required String shareId,
    required String newPermissionLevel,
  });

  Future<void> revokeShare(String shareId);

  /// الصلاحية المحلية السريعة لكيان:
  /// 'owner' | 'editor' | 'admin' | 'viewer' | null (غير مشترك).
  Future<String?> getUserPermission({
    required String entityId,
    required String? currentUserId,
  });

  Future<List<EntityShareModel>> getSharesForUser({
    required String? currentUserId,
    String? currentUserEmail,
  });
}

class CollaborationRepositoryImpl implements ICollaborationRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  @override
  Future<List<EntityShareModel>> getEntityShares({
    required String entityType,
    required String entityId,
  }) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.entityShareTable,
      where: 'entity_type = ? AND entity_id = ? AND deleted_at IS NULL',
      whereArgs: [entityType, entityId],
      orderBy: 'created_at ASC',
    );
    return rows.map(EntityShareModel.fromMap).toList();
  }

  @override
  Future<EntityShareModel?> getShareById(String shareId) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.entityShareTable,
      where: 'id = ?',
      whereArgs: [shareId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return EntityShareModel.fromMap(rows.first);
  }

  @override
  Future<void> upsertShare(EntityShareModel share) async {
    final db = await _db;
    await db.insert(
      DatabaseTables.entityShareTable,
      share.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertShares(List<EntityShareModel> shares) async {
    final db = await _db;
    final batch = db.batch();
    for (final share in shares) {
      batch.insert(
        DatabaseTables.entityShareTable,
        share.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updatePermission({
    required String shareId,
    required String newPermissionLevel,
  }) async {
    final db = await _db;
    await db.update(
      DatabaseTables.entityShareTable,
      {
        'permission_level': newPermissionLevel,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status': 'pending_update',
      },
      where: 'id = ?',
      whereArgs: [shareId],
    );
  }

  @override
  Future<void> revokeShare(String shareId) async {
    final db = await _db;
    await db.update(
      DatabaseTables.entityShareTable,
      {
        'status': CollaborationShareStatus.revoked.value,
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status': 'pending_update',
      },
      where: 'id = ?',
      whereArgs: [shareId],
    );
  }

  @override
  Future<String?> getUserPermission({
    required String entityId,
    required String? currentUserId,
  }) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.entityShareTable,
      where: 'entity_id = ? AND deleted_at IS NULL AND status = ?',
      whereArgs: [entityId, CollaborationShareStatus.active.value],
      orderBy: 'created_at ASC',
    );
    for (final row in rows) {
      final share = EntityShareModel.fromMap(row);
      // المستخدم المالك للكيان.
      if (share.ownerId != null && share.ownerId == currentUserId) {
        return 'owner';
      }
      // المستخدم المتعاون بالبريد أو بالمعرّف.
      if (share.collaboratorId == currentUserId) {
        return share.permissionLevel;
      }
    }
    return 'owner';
  }

  @override
  Future<List<EntityShareModel>> getSharesForUser({
    required String? currentUserId,
    String? currentUserEmail,
  }) async {
    final db = await _db;
    final where = StringBuffer('deleted_at IS NULL AND status = ?');
    final args = <Object?>[CollaborationShareStatus.active.value];
    if (currentUserId != null) {
      where.write(' AND (collaborator_id = ?');
      args.add(currentUserId);
      if (currentUserEmail != null) {
        where.write(' OR collaborator_email = ?');
        args.add(currentUserEmail.toLowerCase());
      }
      where.write(')');
    } else if (currentUserEmail != null) {
      where.write(' AND collaborator_email = ?');
      args.add(currentUserEmail.toLowerCase());
    } else {
      return [];
    }
    final rows = await db.query(
      DatabaseTables.entityShareTable,
      where: where.toString(),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows.map(EntityShareModel.fromMap).toList();
  }
}