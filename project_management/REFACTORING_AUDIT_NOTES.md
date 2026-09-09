# تقرير تدقيق إعادة الهيكلة — Tasky 3.0

> تاريخ الفحص: 2026-09-09
> الحالة الأساسية: `flutter analyze` = No issues | `flutter test` = 238/238

## 1. تكرار جوهري (أعلى أولوية)

- `lib/features/archive/presentation/screens/archive_screen.dart` (615 سطر) و
  `lib/features/trash/presentation/screens/trash_screen.dart` (707 سطر) يتشاركان
  **511 سطراً متطابقاً** (نفس التبويبات الثلاثة: مهام/مشاريع/ملاحظات، البحث، منطق
  الملكية/الإطلاق، الاسترجاع).
- الحل المقترح: استخراج Scaffold مشترك + أقسام تبويبات قابلة لإعادة الاستخدام،
  توفير ~40% من كل شاشة.

## 2. ويدجتات عملاقة متبقية

| الملف | السطور | الحالة |
|---|---|---|
| `lib/features/home/presentation/screens/main_layout_screen.dart` | 1188 | يحتوي `_buildTopHeader` مكرراً داخلياً (سطر 666) بينما يوجد `main_top_header.dart` (393 سطراً) مستخرج و**غير موصول** (orphan، غير متتبع في git) — يُكمل البنود 2.1/2.2 المعلقة في خطة 12. |
| `lib/features/collaboration/presentation/widgets/universal_share_dialog.dart` | 776 | حوار واحد ضخم قابل للتقسيم (تبويب عام/أعضاء + صفوف فرعية) |
| `lib/features/auth/presentation/screens/auth_screen.dart` | 670 | شاشة مصادقة كبيرة |
| `lib/features/tasks/presentation/widgets/tasks_table_view.dart` | 490 | طاولة لوحات |
| `lib/features/trash/.../trash_screen.dart` / `lib/features/archive/.../archive_screen.dart` | 707/615 | مشمولة بالبند 1 |

## 3. كود ميت

- `lib/features/sharing/presentation/controllers/sharing_controller.dart` (162) —
  لا يستورده أي ملف في `lib` (خطة 12 المرحلة 1 زعمت حذفه لكنه ما زال موجوداً).
- `lib/core/services/sharing_service.dart` (299) — لا يستخدمه في `lib` سوى الـ
  controller الميت أعلاه. تحفظ: له `test/sharing_service_test.dart`.
- ملفات البرميل `lib/features/tasks/tasks.dart` و `lib/features/areas/areas.dart`
  و `lib/features/projects/projects.dart` — لا أحد يستوردها (لا `lib` ولا `test`)،
  وليست موحّدة مع بقية الميزات (tags/notes/finance/... بلا برميل).

## 4. تناقض طبقات الـ Repository

- نمط نظيف مطبق في tasks/projects/areas/tags/finance:
  `domain/repositories/i_*.dart` + `data/repositories/*_impl.dart`.
- مخالفات:
  - `INoteRepository` معرف داخل `lib/features/notes/data/repositories/note_repository_impl.dart` نفسه.
  - `IAttachmentRepository` معرف داخل `lib/features/tasks/data/repositories/attachment_repository_impl.dart` نفسه.
  - `collaboration_repository.dart` بلا واجهة `i_*` إطلاقاً ولا مجلد `domain`.

## 5. خدمات ميزات ما زالت في `lib/core/services`

| الخدمة | الموقع الصحيح |
|---|---|
| `collaboration_service.dart` + `permission_guard_service.dart` | features/collaboration |
| `attachment_service.dart` + `recurrence_service.dart` + `notification_service.dart` | features/tasks |
| `export_service.dart` | features/home |
| `share_read_service.dart` | features/sharing |
| `sharing_service.dart` | كود ميت/قديم (انظر البند 3) |

تُبقى في core صحيحاً: `supabase_service.dart`، `sync_service.dart`.

## 6. تغطية الاختبارات

- أقسام `sidebar_tree/*` و `task_drawer/*` لا اختبارات ويدجت مخصصة لها (تُختبر
  ضمناً عبر widget_test فقط).
- توجد سابقاً: `test/admin_only_reshare_test.dart` (يغطي UniversalShareDialog)،
  `test/archive_and_trash_views_test.dart`.

## خطة التنفيذ المقترحة (مرتبة)

1. توصيل/تنظيف `main_top_header.dart` + استخراج `MainWorkspaceSwitcher` → تقليص
   MainLayoutScreen (يُكمل بندي 2.1/2.2 المعلقين في خطة 12).
2. توحيد Archive/Trash بمكوّن مشترك (~950 سطر مكرر).
3. حذف الكود الميت: `sharing_controller.dart` + القرار بشأن `sharing_service.dart`.
4. توحيد طبقات الريبو: نقل `INoteRepository`/`IAttachmentRepository` إلى domain
   وإنشاء `ICollaborationRepository`.
5. إعادة توزيع خدمات core على ميزاتها.

## ضوابط إغلاق كل بند

- `flutter analyze` → No issues found
- `flutter test` → 238/238
- بدون لمس قاعدة البيانات (SQLite/Supabase) وبدون تعديل
  `MASTER_PLAN.md` / `COMPLETED_WORK.md`.