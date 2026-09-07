import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// كلاس مركزي لإدارة وتهيئة خدمة Supabase لمشروع Tasky
class SupabaseService {
  static const String projectUrl = 'https://yjcpevqahefzcpbvajcq.supabase.co';
  static const String anonKey = 'sb_publishable_uSsp_QE2JldkFTNiU2O28w_Fz1y7HEA';

  static bool _isInitialized = false;

  /// تهيئة اتصال Supabase بأمان مع مراعاة بيئات الويب والمكتبي والموبايل
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: projectUrl,
        anonKey: anonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Initialized successfully for project: yjcpevqahefzcpbvajcq');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization warning/error (Offline fallback active): ');
    }
  }

  /// العميل المباشر للتعامل مع سوبابيز
  static SupabaseClient get client => Supabase.instance.client;

  /// فحص هل المستخدم مسجل دخوله حالياً في سوبابيز
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// الحصول على معرّف المستخدم الحالي (أو null إذا كان غير مسجل)
  static String? get currentUserId => client.auth.currentUser?.id;

  /// البريد الإلكتروني للمستخدم الحالي
  static String? get currentUserEmail => client.auth.currentUser?.email;
}
