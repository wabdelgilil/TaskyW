import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';

/// خدمة الإشعارات المحلية (Singleton) لدعم Windows و Android و iOS.
class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService._internal();

  static const String _taskChannelId = 'task_reminders';
  static const String _taskChannelName = 'تذكيرات المهام';
  static const String _taskChannelDescription = 'تذكيرات المواعيد النهائية للمهام';

  /// تهيئة الإشعارات لنظامي Windows و Android/iOS.
  Future<void> init() async {
    if (_isInitialized) return;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      await _configureTimeZone();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: iosInit,
      );

      await _plugin.initialize(settings, onDidReceiveNotificationResponse: onNotificationTap);
      _isInitialized = true;
    }
  }

  /// معالج النقر على الإشعار (نمط دالة عمومية لتجنب تحذيرات الفحص).
  @pragma('vm:entry-point')
  static void onNotificationTap(NotificationResponse response) {
    // تُستخدم لاحقاً لفتح تفاصيل المهمة عند النقر على الإشعار (payload يحمل taskId).
  }

  /// طلب صلاحيات التنبيه.
  Future<bool> requestPermissions() async {
    await init();
    if (!_isInitialized) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission() ?? true;
    if (!androidGranted) return false;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    return iosGranted;
  }

  /// هل صلاحية التنبيهات مفعّلة على النظام؟ (تعمل مع أندرويد وIOS فقط)
  Future<bool> checkPermissionStatus() async {
    await init();
    if (!_isInitialized) return false;

    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted = await android?.areNotificationsEnabled() ?? true;
      if (!androidGranted) return false;

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosStatus = await ios?.checkPermissions();
      if (iosStatus != null) {
        return iosStatus.isEnabled;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// التحقق المزدوج قبل إرسال أي تنبيه: الإعدادات العامة + تفعيل إشعارات المشروع.
  bool shouldNotifyFor({ProjectModel? project, DateTime? scheduledDate}) {
    if (!SettingsController.instance.notificationsEnabled) return false;
    if (project != null && !project.notificationsEnabled) return false;
    if (scheduledDate != null && !scheduledDate.isAfter(DateTime.now())) {
      return false;
    }
    return true;
  }

  /// جدولة تذكير مهمة عند حلول الموعد المحدد (مع التحقق المزدوج الذكي).
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required DateTime scheduledDate,
    ProjectModel? project,
  }) async {
    await init();
    if (!_isInitialized) return;

    // تحقق مزدوج: الإعدادات العامة + كتم المشروع + موعد مستقبلي.
    if (!shouldNotifyFor(project: project, scheduledDate: scheduledDate)) {
      await cancelTaskReminder(taskId);
      return;
    }

    await _plugin.zonedSchedule(
      _notificationIdFor(taskId),
      title,
      'حان موعد تنفيذ المهمة',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannelId,
          _taskChannelName,
          channelDescription: _taskChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: taskId,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// إلغاء تذكير مهمة مجدول مسبقاً.
  Future<void> cancelTaskReminder(String taskId) async {
    if (!_isInitialized) return;
    await _plugin.cancel(_notificationIdFor(taskId));
  }

  /// إلغاء تذكيرات مجموعة مهام دفعة واحدة (يُستخدم عند كتم إشعارات مشروع).
  Future<void> cancelRemindersForTasks(Iterable<String> taskIds) async {
    if (!_isInitialized) return;
    for (final taskId in taskIds) {
      await _plugin.cancel(_notificationIdFor(taskId));
    }
  }

  int _notificationIdFor(String taskId) => taskId.hashCode & 0x7fffffff;

  Future<void> _configureTimeZone() async {
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }
}