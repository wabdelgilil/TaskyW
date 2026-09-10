import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

/// نتيجة جلب كيان مشارك عام.
class SharedEntityResult {
  final Map<String, dynamic> entity;
  final List<Map<String, dynamic>> children;

  const SharedEntityResult({required this.entity, this.children = const []});

  /// هل هذا الكيان مهمة (لها أعمدة `priority` و `reminder_time`)؟
  bool get isTask => entity.containsKey('priority');

  /// هل هذا الكيان مشروع؟
  bool get isProject => entity.containsKey('target_date') && !isTask;

  /// هل هذا الكيان مجال؟
  bool get isArea => !isTask && !isProject;
}

/// خدمة قراءة الكيانات المشاركة برابط عام (بدون حساب).
///
/// تستخدم دالة RPC الآمنة `get_shared_entity` المصرّح بها للمستخدم المجهول
/// (anon) على المشروع `yjcpevqahefzcpbvajcq` فقط — قراءة لا تعديل ولا حذف.
class ShareReadService {
  ShareReadService({SupabaseServiceLike? supabase})
      : _supabase = supabase ?? _SupabaseAdapter();

  final SupabaseServiceLike _supabase;

  /// جلب كيان مشارك عبر رمز الرابط العام مع محتواه الفرعي (قراءة فقط).
  ///
  /// - مهمة: تعيد المهمة + مهامها الفرعية.
  /// - مشروع: يعيد المشروع + مهامه.
  /// - مجال: يعيد المجال + مشاريعه.
  /// يرجع `null` عند غياب الحصة أو انتهاء الرابط أو خطأ في الاتصال.
  Future<SharedEntityResult?> fetchPublicEntityByToken(
    String shareToken,
  ) async {
    final token = shareToken.trim();
    if (token.isEmpty) return null;
    try {
      final row = await _supabase.fetchSharedEntity(token);
      if (row == null || row.isEmpty) return null;

      final entity = Map<String, dynamic>.from(row);
      final result = SharedEntityResult(entity: entity);

      // جلب الأولاد عبر دوال RPC آمنة بنفس الرمز (RLS تمنع الجلب المباشر
      // للزائر المجهول). أي فشل في الأولاد لا يعطّل عرض الكيان الأب.
      final children = result.isTask
          ? await _fetchChildrenSafe(() => _supabase.fetchSharedSubtasks(token))
          : result.isProject
              ? await _fetchChildrenSafe(() => _supabase.fetchSharedTasks(token))
              : await _fetchChildrenSafe(() => _supabase.fetchSharedProjects(token));

      return SharedEntityResult(entity: entity, children: children);
    } catch (e) {
      debugPrint('[ShareReadService] fetchPublicEntityByToken error: $e');
      return null;
    }
  }

  /// تلغي أي خطأ في جلب الأولاد وتعيد قائمة فارغة حتى لا يكسر عرض الكيان.
  Future<List<Map<String, dynamic>>> _fetchChildrenSafe(
    Future<List<Map<String, dynamic>>> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (e) {
      debugPrint('[ShareReadService] children fetch skipped: $e');
      return const [];
    }
  }

  /// جلب بيانات مهمة عامة + مهامها الفرعية فقط (إن لم تكن مهمة يرجع null).
  Future<SharedEntityResult?> fetchPublicTaskWithSubtasks(
    String shareToken,
  ) async {
    final result = await fetchPublicEntityByToken(shareToken);
    if (result == null || !result.isTask) return null;
    return result;
  }
}

/// عقد قابل للحقن يسمح باختبار الخدمة دون اتصال فعلي بـ Supabase.
abstract class SupabaseServiceLike {
  Future<Map<String, dynamic>?> fetchSharedEntity(String shareToken);
  Future<List<Map<String, dynamic>>> fetchSharedSubtasks(String shareToken);
  Future<List<Map<String, dynamic>>> fetchSharedTasks(String shareToken);
  Future<List<Map<String, dynamic>>> fetchSharedProjects(String shareToken);
}

class _SupabaseAdapter implements SupabaseServiceLike {
  @override
  Future<Map<String, dynamic>?> fetchSharedEntity(String shareToken) async {
    final client = SupabaseService.client;
    final result = await client
        .rpc('get_shared_entity', params: {'p_token': shareToken})
        .single();
    return result as Map<String, dynamic>?;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedSubtasks(
    String shareToken,
  ) async {
    final client = SupabaseService.client;
    final rows = await client.rpc(
      'get_shared_subtasks',
      params: {'p_token': shareToken},
    );
    return rows is List
        ? List<Map<String, dynamic>>.from(rows)
        : const <Map<String, dynamic>>[];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedTasks(
    String shareToken,
  ) async {
    final client = SupabaseService.client;
    final rows = await client.rpc(
      'get_shared_tasks',
      params: {'p_token': shareToken},
    );
    return rows is List
        ? List<Map<String, dynamic>>.from(rows)
        : const <Map<String, dynamic>>[];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedProjects(
    String shareToken,
  ) async {
    final client = SupabaseService.client;
    final rows = await client.rpc(
      'get_shared_projects',
      params: {'p_token': shareToken},
    );
    return rows is List
        ? List<Map<String, dynamic>>.from(rows)
        : const <Map<String, dynamic>>[];
  }
}