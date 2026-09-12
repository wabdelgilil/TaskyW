import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// كلاس مركزي لإدارة وتهيئة خدمة Supabase لمشروع Tasky
class SupabaseService {
  static const String projectUrl = 'https://yjcpevqahefzcpbvajcq.supabase.co';

  /// مفتاح Supabase العمومي (publishable) — يُمرر عبر
  /// `--dart-define=SUPABASE_ANON_KEY=...` وقت البناء، أو عبر ملف `.env`.
  /// المفتاح عمومي بطبيعته مخصص لجهة العميل؛ لا يحتوي أي صلاحيات حساسة.
  static const String _defaultPublishableKey =
      'sb_publishable_uSsp_QE2JldkFTNiU2O28w_Fz1y7HEA';

  static String get publishableKey {
    final fromEnv = const String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    try {
      final fromDotenv = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      if (fromDotenv.isNotEmpty) return fromDotenv;
    } catch (_) {}
    return _defaultPublishableKey;
  }

  static bool _isInitialized = false;

  /// تهيئة اتصال Supabase بأمان مع مراعاة بيئات الويب والمكتبي والموبايل
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
await Supabase.initialize(
        url: projectUrl,
        publishableKey: publishableKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Initialized successfully for project: yjcpevqahefzcpbvajcq');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization warning/error (Offline fallback active): ');
    }
  }

  static bool get isInitialized => _isInitialized;

  /// العميل المباشر للتعامل مع سوبابيز
  static SupabaseClient? get clientOrNull => _isInitialized ? Supabase.instance.client : null;
  static SupabaseClient get client => Supabase.instance.client;

  /// فحص هل المستخدم مسجل دخوله حالياً في سوبابيز
  static bool get isAuthenticated => _isInitialized && client.auth.currentUser != null;

  /// الحصول على معرّف المستخدم الحالي (أو null إذا كان غير مسجل)
  static String? get currentUserId => _isInitialized ? client.auth.currentUser?.id : null;

  /// البريد الإلكتروني للمستخدم الحالي
  static String? get currentUserEmail => _isInitialized ? client.auth.currentUser?.email : null;
}

