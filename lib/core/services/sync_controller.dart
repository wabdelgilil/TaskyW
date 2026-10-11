import 'dart:async';
import 'package:flutter/material.dart';

import 'network_service.dart';
import 'sync_service.dart';

/// حالات المزامنة السحابية المختلفة
enum SyncStatusState {
  synced,        // جميع البيانات متزامنة
  syncing,       // جاري المزامنة الآن
  pending,       // توجد تعديلات محلية معلقة تنتظر الرفع
  offline,       // لا يوجد اتصال بالإنترنت (أوفلاين)
  error,         // حدث خطأ أثناء المزامنة
}

/// متحكم تفاعلي ذكي لإدارة وعرض حالة المزامنة اللحظية
/// يدعم المحاولات المتكررة التلقائية (Retry Engine)، واكتشاف انقطاع الإنترنت،
/// وإشعار المستخدم بدقة عند تكرار الفشل.
class SyncController extends ChangeNotifier {
  static final SyncController instance = SyncController._internal();
  SyncController._internal();

  SyncStatusState _state = SyncStatusState.synced;
  int _pendingCount = 0;
  DateTime? _lastSyncedAt;
  String? _errorMessage;

  // إدارة المحاولات التلقائية (Retry Loop)
  int _retryAttempt = 0;
  static const int maxRetryAttempts = 5;
  Timer? _retryTimer;
  bool _isAutoRetrying = false;

  SyncStatusState get state => _state;
  int get pendingCount => _pendingCount;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get errorMessage => _errorMessage;
  int get retryAttempt => _retryAttempt;
  int get maxRetries => maxRetryAttempts;
  bool get isRetrying => _isAutoRetrying;

  bool get isSyncing => _state == SyncStatusState.syncing;
  bool get isOffline => _state == SyncStatusState.offline;
  bool get isError => _state == SyncStatusState.error;
  bool get hasPending => _pendingCount > 0;

  /// تحديث عدد العمليات المعلقة مع الحفاظ على الحالات غير المستقرة (أوفلاين أو خطأ)
  void updatePendingCount(int count) {
    _pendingCount = count;
    if (_state != SyncStatusState.syncing &&
        _state != SyncStatusState.offline &&
        _state != SyncStatusState.error) {
      _state = count > 0 ? SyncStatusState.pending : SyncStatusState.synced;
    }
    notifyListeners();
  }

  /// بدء عملية المزامنة
  void startSyncing({String? message}) {
    _state = SyncStatusState.syncing;
    _errorMessage = message;
    notifyListeners();
  }

  /// إتمام المزامنة بنجاح
  void setSynced() {
    _state = SyncStatusState.synced;
    _pendingCount = 0;
    _lastSyncedAt = DateTime.now();
    _errorMessage = null;
    _retryAttempt = 0;
    _isAutoRetrying = false;
    _retryTimer?.cancel();
    NetworkService.instance.stopMonitoring();
    notifyListeners();
  }

  /// تعيين وضع الأوفلاين وإيقاف المحاولات مؤقتاً
  void setOffline({String? message}) {
    _state = SyncStatusState.offline;
    _errorMessage = message ?? 'لا يوجد اتصال بالإنترنت، توقفت المحاولات مؤقتاً حتى عودة الاتصال';
    _isAutoRetrying = false;
    _retryTimer?.cancel();
    notifyListeners();
  }

  /// تعيين حالة خطأ
  void setError(String message) {
    _state = SyncStatusState.error;
    _errorMessage = message;
    _isAutoRetrying = false;
    notifyListeners();
  }

  /// إلغاء أي محاولات مؤجلة
  void cancelRetries() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _isAutoRetrying = false;
    NetworkService.instance.stopMonitoring();
  }

  /// طلب أو تشغيل دورة المزامنة مع التكرار التلقائي وفحص الشبكة
  Future<void> triggerSync({
    bool isManual = true,
    Future<SyncResult> Function()? onPerformSync,
  }) async {
    if (_state == SyncStatusState.syncing && isManual) return;

    if (isManual) {
      _retryAttempt = 0;
      _isAutoRetrying = false;
      _retryTimer?.cancel();
      NetworkService.instance.stopMonitoring();
    }

    startSyncing(
      message: _retryAttempt > 0
          ? 'جاري إعادة المحاولة ($_retryAttempt من $maxRetryAttempts)...'
          : null,
    );

    try {
      final SyncResult result;
      if (onPerformSync != null) {
        result = await onPerformSync();
      } else {
        result = await SyncService.instance.syncNow();
      }

      if (result.isOffline) {
        setOffline(message: result.message);
        // بدء مراقبة الشبكة لاستئناف المزامنة فور عودة الاتصال
        NetworkService.instance.startMonitoring(
          onRestored: () {
            triggerSync(isManual: false, onPerformSync: onPerformSync);
          },
        );
        return;
      }

      if (result.authenticated) {
        if (result.success) {
          setSynced();
        } else {
          _handleSyncFailure(
            message: result.message ?? 'فشلت المزامنة جزئياً',
            onPerformSync: onPerformSync,
          );
        }
      } else {
        // المستخدم غير مسجل الدخول
        setError(result.message ?? 'يجب تسجيل الدخول لمزامنة البيانات');
      }
    } catch (e) {
      if (NetworkService.isNetworkError(e)) {
        setOffline(message: 'لا يوجد اتصال بالإنترنت، توقفت المحاولات مؤقتاً حتى عودة الاتصال');
        NetworkService.instance.startMonitoring(
          onRestored: () {
            triggerSync(isManual: false, onPerformSync: onPerformSync);
          },
        );
      } else {
        _handleSyncFailure(
          message: 'تعذر إتمام المزامنة: $e',
          onPerformSync: onPerformSync,
        );
      }
    }
  }

  /// معالجة الفشل وإدارة المحاولات المتكررة (Backoff Retry)
  void _handleSyncFailure({
    required String message,
    Future<SyncResult> Function()? onPerformSync,
  }) {
    if (_retryAttempt < maxRetryAttempts) {
      _retryAttempt++;
      _isAutoRetrying = true;
      final delaySeconds = 2 * _retryAttempt;
      _errorMessage = 'تعذر المزامنة، جاري إعادة المحاولة ($_retryAttempt من $maxRetryAttempts)...';
      _state = SyncStatusState.syncing;
      notifyListeners();

      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(seconds: delaySeconds), () {
        triggerSync(isManual: false, onPerformSync: onPerformSync);
      });
    } else {
      _isAutoRetrying = false;
      _retryTimer?.cancel();
      setError('فشلت المزامنة بعد $maxRetryAttempts محاولات. اضغط لإعادة المحاولة يدويًا.');

      // جدولة محاولة هادئة لاحقة كل 60 ثانية لضمان الاستمرارية
      _retryTimer = Timer(const Duration(seconds: 60), () {
        triggerSync(isManual: false, onPerformSync: onPerformSync);
      });
    }
  }

  /// نص وصفي لآخر موعد مزامنة
  String get formattedLastSync {
    if (_lastSyncedAt == null) return 'لم تتم مزامنة بعد';
    final diff = DateTime.now().difference(_lastSyncedAt!);
    if (diff.inSeconds < 45) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return '${_lastSyncedAt!.day}/${_lastSyncedAt!.month}';
  }
}
