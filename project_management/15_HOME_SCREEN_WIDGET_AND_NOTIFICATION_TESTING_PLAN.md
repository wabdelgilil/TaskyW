# خطة بناء ودجت شاشة الهاتف الكبيرة (Android Widget) ونظام اختبار الإشعارات
### Document ID: `15_HOME_SCREEN_WIDGET_AND_NOTIFICATION_TESTING_PLAN.md`
### ارتباط الماستر بلان: مرتبط بـ `MASTER_PLAN.md` (القسم الثاني - تجربة الموبايل والإنتاجية)

---

## 1. نظرة عامة والأهداف (Overview & Objectives)
تهدف هذه الخطة إلى نقل تفاعل المستخدم مع تطبيق **Tasky** على نظام أندرويد إلى أعلى المستويات من خلال:
1. **ودجت شاشة الهاتف الكبيرة (Large Scrollable Home Screen Widget)**:
   - تعرض جميع المهام النشطة (غير المكتملة) في قائمة سلسة قابلة للتمرير (`ListView`).
   - شريط علوي يحتوي على هوية التطبيق، عداد المهام النشطة، وزر إضافة فوري `(+)`.
   - النقر على زر `(+)` يقوم بإطلاق التطبيق عبر رابط عميق (`tasky://add_task`) لفتح نافذة إضافة المهمة مباشرة.
   - النقر على أي مهمة ينقل المستخدم إليها فوراً.
   - دعم التحديث اللحظي عند أي تعديل على المهام في التطبيق.
2. **زر اختبار الإشعارات الفوري (Instant Cross-Platform Test Notification)**:
   - إضافة خيار في شاشة الإعدادات تحت قسم التنبيهات لإرسال إشعار فوري للتأكد من عمل التنبيهات والصلاحيات عبر جميع المنصات (Android, Windows, macOS/iOS).

---

## 2. مصفوفة تقسيم العمل والملفات المستهدفة

| المجال | نطاق العمل والملفات المستهدفة |
| :--- | :--- |
| **Dart & Flutter Core** | • إضافة التبعية `home_widget: ^0.9.4` في `pubspec.yaml`.<br>• إنشاء `HomeScreenWidgetService` لإدارة مزامنة البيانات والروابط العميقة.<br>• ترقية `NotificationService` بإضافة `showInstantTestNotification`.<br>• ربط `TasksController` لتحديث بيانات الودجت تلقائياً.<br>• ربط `MainLayoutScreen` لفتح `AddTaskDialog` عند استقبال رابط الإضافة السريعة.<br>• إضافة زر الاختبار في `SettingsScreen` مع رسائل `SnackBar` التفاعلية.<br>• تحديث ملفات الترجمة `app_ar.arb` و `app_en.arb`. |
| **Android Native** | • تعديل `AndroidManifest.xml` لإضافة فلتر `tasky://` والـ Receiver والـ Service.<br>• إنشاء `TaskyWidgetProvider.kt` لإدارة الودجت.<br>• إنشاء `TaskyWidgetService.kt` (`RemoteViewsService` + `RemoteViewsFactory`).<br>• إنشاء تخطيطات XML: `tasky_widget_layout.xml`، `tasky_widget_item.xml`، و `tasky_widget_info.xml`.<br>• إنشاء تصاميم الخلفيات والأزرار في `res/drawable/`. |

---

## 3. خطة التنفيذ والتحقق

1. تفعيل التبعيات وتحديث ملفات الترجمة.
2. بناء ميزة اختبار الإشعارات الفورية والتأكد منها على بيئة سطح المكتب.
3. بناء خدمة الودجت في Dart وربطها بدورة حياة المهام.
4. إنشاء طبقة الأندرويد الأصلية (Layouts + Provider + RemoteViewsService).
5. فحص الأكواد واختبار البناء عبر `flutter analyze`.
