import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/collaboration/data/models/entity_share_model.dart';
import '../../features/collaboration/data/repositories/collaboration_repository.dart';
import 'permission_guard_service.dart';
import 'supabase_service.dart';

/// واجهة السحابة لاختبار [CollaborationService] دون الاتصال بـ Supabase.
abstract class CollaborationCloud {
  Future<bool> get isAuthenticated;

  Future<String?> get currentUserId;

  Future<String?> get currentUserEmail;

  Future<List<Map<String, dynamic>>> fetchShares({
    required String entityType,
    required String entityId,
  });

  Future<Map<String, dynamic>?> findShareByEmail({
    required String entityType,
    required String entityId,
    required String email,
  });

  Future<Map<String, dynamic>> insertShare(Map<String, dynamic> row);

  Future<void> updateShare({
    required String shareId,
    required Map<String, dynamic> changes,
  });

  /// مشاركات المستخدم النشطة (بعد تفعيل Auto-Link لحظة الدخول).
  Future<List<Map<String, dynamic>>> fetchSharedWithMe();

  /// جلب صف الكيان ذاته (tasks/projects/areas) لإدماج بياناته مع المشاركة.
  Future<Map<String, dynamic>?> fetchEntityRow({
    required String entityType,
    required String entityId,
  });
}

/// تنفيذ حقيقي عبر Supabase Service.
class SupabaseCollaborationCloud implements CollaborationCloud {
  SupabaseClient? get _client {
    try {
      if (!SupabaseService.isAuthenticated) return null;
      return SupabaseService.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> get isAuthenticated async => _client != null;

  @override
  Future<String?> get currentUserId async => SupabaseService.currentUserId;

  @override
  Future<String?> get currentUserEmail async => SupabaseService.currentUserEmail;

  @override
  Future<List<Map<String, dynamic>>> fetchShares({
    required String entityType,
    required String entityId,
  }) async {
    final client = _client;
    if (client == null) return [];
    final rows = await client
        .from('entity_shares')
        .select()
        .eq('entity_type', entityType)
        .eq('entity_id', entityId)
        .order('created_at');
    return rows;
  }

  @override
  Future<Map<String, dynamic>?> findShareByEmail({
    required String entityType,
    required String entityId,
    required String email,
  }) async {
    final client = _client;
    if (client == null) return null;
    final existing = await client
        .from('entity_shares')
        .select()
        .eq('entity_type', entityType)
        .eq('entity_id', entityId)
        .eq('collaborator_email', email.toLowerCase())
        .maybeSingle();
    return existing;
  }

  @override
  Future<Map<String, dynamic>> insertShare(Map<String, dynamic> row) async {
    final client = _client;
    if (client == null) throw StateError('Collaboration requires login.');
    final result = await client.from('entity_shares').insert(row).select().single();
    return result;
  }

  @override
  Future<void> updateShare({
    required String shareId,
    required Map<String, dynamic> changes,
  }) async {
    final client = _client;
    if (client == null) return;
    // Supabase v2 يرمي PostgrestException عند الفشل — لا حاجة لفحص `.error`.
    await client
        .from('entity_shares')
        .update(changes)
        .eq('id', shareId);
    // ربط أي دعوة معلقة بهذا الحساب فور إجرائها إن كان البريد مسجلاً لدينا.
    await _tryAutoLink();
  }

  Future<void> _tryAutoLink() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.rpc('auto_link_collaborator_current');
    } catch (e) {
      debugPrint('[CollaborationCloud] auto-link skipped: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedWithMe() async {
    final client = _client;
    final uid = await currentUserId;
    final email = (await currentUserEmail)?.trim().toLowerCase();
    if (client == null || (uid == null && email == null)) return [];
    await _tryAutoLink();

    // نجلب الدعوات النشطة والمعلقة الموجهة لهذا المستخدم أو بريده
    var query = client
        .from('entity_shares')
        .select()
        .inFilter('status', ['active', 'pending'])
        .isFilter('deleted_at', null);

    if (uid != null && email != null) {
      query = query.or('collaborator_id.eq.$uid,collaborator_email.eq.$email');
    } else if (uid != null) {
      query = query.eq('collaborator_id', uid);
    } else {
      query = query.eq('collaborator_email', email!);
    }
    final rows = await query.order('created_at');
    return rows;
  }


  @override
  Future<Map<String, dynamic>?> fetchEntityRow({
    required String entityType,
    required String entityId,
  }) async {
    final client = _client;
    if (client == null) return null;
    
    // تحويل نوع الكيان إلى اسم الجدول الفعلي في قاعدة البيانات
    final tableName = switch (entityType) {
      'project' => 'projects',
      'area' => 'areas',
      'task' => 'tasks',
      _ => entityType,
    };

    final result = await client
        .from(tableName)
        .select()
        .eq('id', entityId)
        .maybeSingle();
    return result;
  }
}


/// خدمة التعاون: دعوة متعاونين، إدارة الصلاحيات، السحب، وجلب المشاركات.
///
/// مبدأ العمل:
/// 1. في السحابة، وتحويل النتيجة إلى [EntityShareModel].
/// 2. متزامنة في ذاكرة محلية (SQLite) لدعم Offline-First.
/// 3. مع فشل السحابة تُرتجع آخر نسخة محلية مخزّنة.
class CollaborationService {
  final CollaborationCloud cloud;
  final ICollaborationRepository repository;
  final Uuid _uuid = const Uuid();

  CollaborationService({
    required this.cloud,
    required this.repository,
  });

  factory CollaborationService.instance() =>
      CollaborationService(
        cloud: SupabaseCollaborationCloud(),
        repository: CollaborationRepositoryImpl(),
      );

  Future<bool> get isAuthenticated => cloud.isAuthenticated;

  Future<String?> get currentUserId => cloud.currentUserId;

  Future<String?> get currentUserEmail => cloud.currentUserEmail;

  /// المشاركات الخاصة بكيان (سحابة أولاً، محلي عند عدم الاتصال).
  Future<List<EntityShareModel>> getEntityShares({
    required String entityType,
    required String entityId,
  }) async {
    List<Map<String, dynamic>> cloudRows;
    try {
      cloudRows = await cloud.fetchShares(entityType: entityType, entityId: entityId);
    } catch (e) {
      debugPrint('[CollaborationService] cloud fetch failed: $e');
      cloudRows = [];
    }

    final shares = cloudRows.map(EntityShareModel.fromMap).toList();

    // النسخ المحلي ليعمل بدون اتصال.
    await repository.upsertShares(shares);

    if (cloudRows.isNotEmpty) return shares;

    // احتياط محلي عند انقطاع الشبكة.
    return repository.getEntityShares(entityType: entityType, entityId: entityId);
  }

  /// هل يمتلك المستخدم الحالي صلاحية إدارة المشاركات على هذا الكيان؟
  ///
  /// متاح للمالك الأصلي والمسؤول (Admin) فقط، مع وراثة هرمية من الأجداد
  /// (مهمة ← مشروع ← مجال) عبر جلب صف الكيان من السحابة ومشاركات أجداده.
  /// تُستخدم كحارس أمني على مستوى الخدمة قبل أي عملية دعوة/تعديل/سحب.
  Future<bool> canManageEntity({
    required String entityType,
    required String entityId,
  }) async {
    final guard = PermissionGuardService();
    guard.setCurrentUser(
      id: await cloud.currentUserId,
      email: await cloud.currentUserEmail,
    );

    final allShares = <EntityShareModel>[];
    final ancestors = <String>[];

    try {
      final directRows = await cloud.fetchShares(
        entityType: entityType,
        entityId: entityId,
      );
      allShares.addAll(directRows.map(EntityShareModel.fromMap));
    } catch (e) {
      debugPrint('[CollaborationService] canManageEntity fetch direct failed: $e');
    }

    // تحديد الأجداد الهرميين حسب نوع الكيان
    try {
      final row = await cloud.fetchEntityRow(entityType: entityType, entityId: entityId);
      if (entityType == 'task') {
        final projectId = row?['project_id'] as String?;
        final areaId = row?['area_id'] as String?;
        if (projectId != null) ancestors.add(projectId);
        if (areaId != null) ancestors.add(areaId);
      } else if (entityType == 'project') {
        final areaId = row?['area_id'] as String?;
        if (areaId != null) ancestors.add(areaId);
      }
    } catch (e) {
      debugPrint('[CollaborationService] canManageEntity fetch row failed: $e');
    }

    for (final ancestorId in ancestors) {
      final ancestorType = entityType == 'task' ? 'project' : 'area';
      try {
        final rows = await cloud.fetchShares(
          entityType: ancestorType,
          entityId: ancestorId,
        );
        allShares.addAll(rows.map(EntityShareModel.fromMap));
      } catch (e) {
        debugPrint('[CollaborationService] canManageEntity fetch ancestor failed: $e');
      }
    }

    guard.loadShares(allShares);
    return guard.canManageInherited(
      entityId: entityId,
      ancestorEntityIds: ancestors,
    );
  }

  /// دعوة متعاون بالبريد مع صلاحية.
  Future<EntityShareModel?> inviteCollaborator({
    required String entityType,
    required String entityId,
    required String email,
    String permissionLevel = 'viewer',
    String? collaboratorId,
    String? ownerId,
  }) async {
    // حارس أمني: فقط المالك/المسؤول يمكنه الدعوة أو إعادة المشاركة.
    if (!await canManageEntity(entityType: entityType, entityId: entityId)) {
      debugPrint('[CollaborationService] invite blocked: user cannot manage shares');
      return null;
    }

    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final now = DateTime.now().toUtc();

    Map<String, dynamic> row;
    try {
      final existing = await cloud.findShareByEmail(
        entityType: entityType,
        entityId: entityId,
        email: normalized,
      );
      if (existing != null) {
        final shareId = existing['id'] as String;
        await cloud.updateShare(shareId: shareId, changes: {
          'permission_level': permissionLevel,
          'status': CollaborationShareStatus.active.value,
          'collaborator_id': collaboratorId ?? existing['collaborator_id'],
          'collaborator_email': normalized,
          'updated_at': now.toIso8601String(),
        });
        final refreshed =
            await cloud.fetchShares(entityType: entityType, entityId: entityId);
        row = refreshed.firstWhere(
          (r) => r['id'] == shareId,
          orElse: () => existing,
        );
      } else {
        row = await cloud.insertShare({
          'id': _uuid.v4(),
          'entity_type': entityType,
          'entity_id': entityId,
          'owner_id': ownerId ?? await cloud.currentUserId,
          'collaborator_email': normalized,
          'collaborator_id': collaboratorId,
          'permission_level': permissionLevel,
          'status': CollaborationShareStatus.pending.value,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('[CollaborationService] invite failed: $e');
      return null;
    }

    final share = EntityShareModel.fromMap(row);
    await repository.upsertShare(share);
    return share;
  }

  /// تعديل صلاحية متعاون.
  Future<EntityShareModel?> updateCollaboratorPermission({
    required String shareId,
    required String newPermissionLevel,
  }) async {
    // حارس أمني: تحديد الكيان التابع للمشاركة والتحقق من صلاحية الإدارة.
    final share = await repository.getShareById(shareId);
    if (share == null) return null;
    if (!await canManageEntity(
      entityType: share.entityType,
      entityId: share.entityId,
    )) {
      debugPrint('[CollaborationService] updatePermission blocked: user cannot manage shares');
      return null;
    }

    try {
      await cloud.updateShare(shareId: shareId, changes: {
        'permission_level': newPermissionLevel,
        'status': CollaborationShareStatus.active.value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[CollaborationService] update failed: $e');
      return null;
    }

    await repository.updatePermission(
      shareId: shareId,
      newPermissionLevel: newPermissionLevel,
    );
    return repository.getShareById(shareId);
  }

  /// سحب مشاركة (إبطال وصول المتعاون نهائياً).
  Future<bool> revokeShare({required String shareId}) async {
    // حارس أمني: تحديد الكيان التابع للمشاركة والتحقق من صلاحية الإدارة.
    final share = await repository.getShareById(shareId);
    if (share == null) return false;
    if (!await canManageEntity(
      entityType: share.entityType,
      entityId: share.entityId,
    )) {
      debugPrint('[CollaborationService] revoke blocked: user cannot manage shares');
      return false;
    }

    try {
      await cloud.updateShare(shareId: shareId, changes: {
        'status': CollaborationShareStatus.revoked.value,
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[CollaborationService] revoke failed: $e');
      return false;
    }
    await repository.revokeShare(shareId);
    return true;
  }

  /// كل الكيانات التي شاركها الآخرون مع المستخدم الحالي.
  ///
  /// يعيد قائمة خرائط: بيانات الكيان + مفتاحا `_permission_level` و `_status`
  /// للصلاحية والحالة. عند انقطاع الاتصال يعتمد على السجل المحلي.
  Future<List<Map<String, dynamic>>> fetchSharedWithMe() async {
    final uid = await cloud.currentUserId;
    final email = await cloud.currentUserEmail;

    try {
      final rows = await cloud.fetchSharedWithMe();
      final result = <Map<String, dynamic>>[];
      for (final row in rows) {
        final entity = await cloud.fetchEntityRow(
          entityType: row['entity_type'] as String,
          entityId: row['entity_id'] as String,
        );
        if (entity != null) {
          result.add({
            ...entity,
            '_entity_type': row['entity_type'],
            '_share_id': row['id'],
            '_permission_level': row['permission_level'],
            '_status': row['status'],
          });
        } else {
          // في حال كانت الدعوة قيد الانتظار (pending) أو الكيان لا يزال في المزامنة
          result.add({
            'id': row['entity_id'],
            'title': 'مشروع مشترك (${row['permission_level'] ?? 'مشارك'})',
            'name': 'مشروع مشترك',
            '_entity_type': row['entity_type'],
            '_share_id': row['id'],
            '_permission_level': row['permission_level'],
            '_status': row['status'],
          });
        }
      }
      return result;
    } catch (e) {
      debugPrint('[CollaborationService] fetchSharedWithMe failed: $e');
    }

    final local = await repository.getSharesForUser(
      currentUserId: uid,
      currentUserEmail: email,
    );
    return local
        .map((s) => {
          'id': s.entityId,
          '_entity_type': s.entityType,
          '_share_id': s.id,
          '_permission_level': s.permissionLevel,
          '_status': s.status,
        })
        .toList();
  }
}