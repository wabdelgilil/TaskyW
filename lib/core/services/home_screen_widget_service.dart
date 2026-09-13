import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';

/// خدمة إدارة وتحديث ودجت شاشة الهاتف (Home Screen Widget) لنظام أندرويد
class HomeScreenWidgetService {
  static final HomeScreenWidgetService instance = HomeScreenWidgetService._internal();

  HomeScreenWidgetService._internal();

  static const String _providerName = 'TaskyWidgetProvider';
  static const String _tasksJsonKey = 'tasks_json';
  static const String _tasksCountKey = 'tasks_count';

  /// إشعار يتم الاستماع إليه عند النقر على عناصر أو أزرار الودجت
  /// يحمل المسار المطلوب مثل: "tasky://add_task" أو "tasky://task?id=..."
  final ValueNotifier<Uri?> widgetActionNotifier = ValueNotifier<Uri?>(null);

  bool _isInitialized = false;

  /// تهيئة الاستماع للروابط المنطلقة من الودجت
  Future<void> init() async {
    if (_isInitialized) return;
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      // فحص إذا كان التطبيق قد تم فتحه بالنقر على زر في الودجت
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) {
        widgetActionNotifier.value = initialUri;
      }

      // الاستماع للنقرات أثناء تشغيل التطبيق في الخلفية
      HomeWidget.widgetClicked.listen((Uri? uri) {
        if (uri != null) {
          widgetActionNotifier.value = uri;
        }
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('[HomeScreenWidgetService] init error: $e');
    }
  }

  /// مزامنة المهام النشطة مع الودجت وتحديث العرض فوراً
  Future<void> updateWidgetTasks({
    required List<TaskModel> allTasks,
    List<ProjectModel>? projects,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      // استخراج المهام النشطة فقط (غير المكتملة) وترتيبها
      final activeTasks = allTasks.where((t) => t.status != 'completed').toList();

      final tasksData = activeTasks.map((t) {
        final project = projects?.cast<ProjectModel?>().firstWhere(
              (p) => p?.id == t.projectId,
              orElse: () => null,
            );

        return {
          'id': t.id,
          'title': t.title,
          'priority': t.priority,
          'dueDate': t.dueDate?.toIso8601String() ?? '',
          'projectName': project?.name ?? '',
        };
      }).toList();

      await HomeWidget.saveWidgetData<String>(_tasksJsonKey, jsonEncode(tasksData));
      await HomeWidget.saveWidgetData<int>(_tasksCountKey, activeTasks.length);

      await HomeWidget.updateWidget(
        name: _providerName,
        androidName: _providerName,
      );
    } catch (e) {
      debugPrint('[HomeScreenWidgetService] updateWidgetTasks error: $e');
    }
  }

  /// مسح معالج الإجراء بعد معالجته في الواجهة
  void clearAction() {
    widgetActionNotifier.value = null;
  }
}
