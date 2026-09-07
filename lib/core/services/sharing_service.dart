import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'supabase_service.dart';

/// نوع الكيان الذي يمكن مشاركته (هرمي: منطقة / مشروع / مهمة).
enum ShareEntityType {
  area('area'),
  project('project'),
  task('task');

  final String value;
  const ShareEntityType(this.value);

  static ShareEntityType? fromValue(String? value) {
    for (final type in ShareEntityType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// صلاحيات المتعاون.
enum SharePermission {
  viewer('viewer'),
  editor('editor'),
  admin('admin');

  final String value;
  const SharePermission(this.value);

  static SharePermission? fromValue(String? value) {
    for (final permission in SharePermission.values) {
      if (permission.value == value) return permission;
    }
    return null;
  }
}

/// سجل مشاركة (كيان + اسم مستخدم + صلاحية).
class ShareModel {
  final String id;
  final ShareEntityType entityType;
  final String entityId;
  final String? userId;
  final String? email;
  final String? displayName;
  final SharePermission permission;
  final String? shareToken;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ShareModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.userId,
    this.email,
    this.displayName,
    this.permission = SharePermission.viewer,
    this.shareToken,
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ShareModel.fromMap(Map<String, dynamic> map) => ShareModel(
    id: map['id'] as String,
    entityType: ShareEntityType.fromValue(map['entity_type'] as String?) ??
        ShareEntityType.task,
    entityId: map['entity_id'] as String,
    userId: map['user_id'] as String?,
    email: map['email'] as String?,
    displayName: map['display_name'] as String?,
    permission:
        SharePermission.fromValue(map['permission'] as String?) ??
        SharePermission.viewer,
    shareToken: map['share_token'] as String?,
    isPublic: (map['is_public'] as bool?) ?? false,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'entity_type': entityType.value,
    'entity_id': entityId,
    'user_id': userId,
    'email': email,
    'display_name': displayName,
    'permission': permission.value,
    'share_token': shareToken,
    'is_public': isPublic,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };
}

/// خدمة المشاركة والتعاون (Sharing & Collaboration).
///
/// تدعم:
/// 1. روابط قراءة عامة (لا تتطلب حساباً، عبر `share_token`).
/// 2. متعاونين بحسابات ذات صلاحيات viewer / editor / admin.
class SharingService {
  static final SharingService instance = SharingService._internal();
  SharingService._internal();

  static const String entitySharesTable = 'entity_shares';

  final Uuid _uuid = const Uuid();

  SupabaseClient? get _client {
    try {
      if (!SupabaseService.isAuthenticated) return null;
      return SupabaseService.client;
    } catch (_) {
      return null;
    }
  }

  /// إنشاء رابط قراءة عام (public read-only link) لكيان معيّن.
  ///
  /// يعيد `share_token` الذي يُستخدم لاحقاً للحصول على بيانات الكيان.
  /// إذا وُجد رمز سابق يُعاد دون إنشاء رمز جديد.
  Future<String?> generatePublicLink({
    required ShareEntityType entityType,
    required String entityId,
  }) async {
    final client = _client;
    if (client == null) return null;

    final existing = await client
        .from(entitySharesTable)
        .select('share_token')
        .eq('entity_type', entityType.value)
        .eq('entity_id', entityId)
        .eq('is_public', true)
        .maybeSingle();

    if (existing != null && existing['share_token'] != null) {
      return existing['share_token'] as String;
    }

    final token = _generateShareToken();
    final now = DateTime.now().toUtc();

    final row = {
      'id': _uuid.v4(),
      'entity_type': entityType.value,
      'entity_id': entityId,
      'email': null,
      'permission': SharePermission.viewer.value,
      'share_token': token,
      'is_public': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await client.from(entitySharesTable).insert(row);

    // تحديث share_token على الجدول الفعلي (tasks لديه عمود share_token)
    if (entityType == ShareEntityType.task) {
      await client.from('tasks').update({'share_token': token}).eq('id', entityId);
    }

    return token;
  }

  /// إلغاء رابط القراءة العام لكيان.
  Future<bool> revokePublicLink({
    required ShareEntityType entityType,
    required String entityId,
  }) async {
    final client = _client;
    if (client == null) return false;

    final deleted = await client
        .from(entitySharesTable)
        .delete()
        .eq('entity_type', entityType.value)
        .eq('entity_id', entityId)
        .eq('is_public', true);

    if (deleted.error == null) {
      // إزالة share_token من صف المهمة إن وُجد
      if (entityType == ShareEntityType.task) {
        await client
            .from('tasks')
            .update({'share_token': null})
            .eq('id', entityId);
      }
      return true;
    }
    return false;
  }

  /// دعوة متعاون بريد إلكتروني مع صلاحية محددة.
  Future<ShareModel?> inviteCollaborator({
    required ShareEntityType entityType,
    required String entityId,
    required String email,
    SharePermission permission = SharePermission.viewer,
    String? displayName,
    String? userId,
  }) async {
    final client = _client;
    if (client == null) return null;

    final now = DateTime.now().toUtc();
    final row = {
      'id': _uuid.v4(),
      'entity_type': entityType.value,
      'entity_id': entityId,
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'permission': permission.value,
      'is_public': false,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final result = await client.from(entitySharesTable).insert(row).select().single();
    return ShareModel.fromMap(result);
  }

  /// تحديث صلاحية متعاون.
  Future<bool> updatePermission({
    required String shareId,
    required SharePermission permission,
  }) async {
    final client = _client;
    if (client == null) return false;

    final result = await client
        .from(entitySharesTable)
        .update({'permission': permission.value})
        .eq('id', shareId);

    return result.error == null;
  }

  /// إزالة مشاركة (تعاون أو عمومية).
  Future<bool> removeShare({required String shareId}) async {
    final client = _client;
    if (client == null) return false;

    final result = await client
        .from(entitySharesTable)
        .delete()
        .eq('id', shareId);

    return result.error == null;
  }

  /// جلب كل المشاركات الخاصة بكيان.
  Future<List<ShareModel>> getSharesForEntity({
    required ShareEntityType entityType,
    required String entityId,
  }) async {
    final client = _client;
    if (client == null) return [];

    final rows = await client
        .from(entitySharesTable)
        .select()
        .eq('entity_type', entityType.value)
        .eq('entity_id', entityId);

    return rows.map(ShareModel.fromMap).toList();
  }

  /// جلب بيانات كيان عبر رمز مشاركة عام (لا يتطلب حساباً).
  ///
  /// الوصول يتم عبر دالة RPC آمنة في قاعدة البيانات تتحقق من `share_token`
  /// دون كشف صفوف المستخدم.
  Future<Map<String, dynamic>?> getPublicShareByToken(String token) async {
    if (token.trim().isEmpty) return null;
    try {
      final client = _client;
      if (client == null) return null;
      final result = await client
          .rpc('get_shared_entity', params: {'p_token': token})
          .single();
      return result as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[SharingService] getPublicShareByToken error: $e');
      return null;
    }
  }

  String _generateShareToken() {
    return _uuid.v4().replaceAll('-', '');
  }
}
