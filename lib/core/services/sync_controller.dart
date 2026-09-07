import 'package:flutter/material.dart';

/// حالات المزامنة السحابية المختلفة
enum SyncStatusState {
  synced,        // جميع البيانات متزامنة
  syncing,       // جاري المزامنة الآن
  pending,       // توجد تعديلات محلية معلقة تنتظر الرفع
  offline,       // لا يوجد اتصال بالإنترنت (أوفلاين)
  error,         // حدث خطأ أثناء المزامنة
}

/// متحكم تفاعلي لإدارة وعرض حالة المزامنة اللحظية
class SyncController extends ChangeNotifier {
  static final SyncController instance = SyncController._internal();
  SyncController._internal();

  SyncStatusState _state = SyncStatusState.synced;
  int _pendingCount = 0;
  DateTime? _lastSyncedAt;
  String? _errorMessage;

  SyncStatusState get state => _state;
  int get pendingCount => _pendingCount;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get errorMessage => _errorMessage;

  bool get isSyncing => _state == SyncStatusState.syncing;
  bool get hasPending => _pendingCount > 0;

  /// تحديث عدد العمليات المعلقة
  void updatePendingCount(int count) {
    _pendingCount = count;
    if (_state != SyncStatusState.syncing) {
      _state = count > 0 ? SyncStatusState.pending : SyncStatusState.synced;
    }
    notifyListeners();
  }

  /// بدء عملية المزامنة
  void startSyncing() {
    _state = SyncStatusState.syncing;
    _errorMessage = null;
    notifyListeners();
  }

  /// إتمام المزامنة بنجاح
  void setSynced() {
    _state = SyncStatusState.synced;
    _pendingCount = 0;
    _lastSyncedAt = DateTime.now();
    _errorMessage = null;
    notifyListeners();
  }

  /// تعيين وضع الأوفلاين
  void setOffline() {
    _state = SyncStatusState.offline;
    notifyListeners();
  }

  /// تعيين حالة خطأ
  void setError(String message) {
    _state = SyncStatusState.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// محاكاة أو طلب المزامنة الفورية (Trigger Manual Sync)
  Future<void> triggerSync({Future<void> Function()? onPerformSync}) async {
    if (_state == SyncStatusState.syncing) return;

    startSyncing();

    try {
      if (onPerformSync != null) {
        await onPerformSync();
      } else {
        // محاكاة الاتصال والرفع في حال عدم تمرير خدمة خلفية بعد
        await Future.delayed(const Duration(milliseconds: 1200));
      }
      setSynced();
    } catch (e) {
      setError('تعذر إتمام المزامنة. تأكد من اتصال الإنترنت.');
    }
  }

  /// نص وصفي لآخر موعد مزامنة
  String get formattedLastSync {
    if (_lastSyncedAt == null) return 'لم تتم مزامنة بعد';
    final diff = DateTime.now().difference(_lastSyncedAt!);
    if (diff.inSeconds < 45) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ  دقيقة';
    if (diff.inHours < 24) return 'منذ  ساعة';
    return '/';
  }
}
