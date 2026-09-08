# تقرير المرحلة: المهام الخلفية (Backend & Logic) — Tasky 3.0

- **التاريخ**: 2026-09-08
- **النطاق**: المرحلة الأولى من خطة العمل «07_BACKEND_AND_LOGIC_AGENT_TASKS» — المهمات الأربع (الوسوم، المهام المتكررة، تصدير CSV، المشاركة) + نشر الترحيلات على Supabase.
- **النتيجة النهائية**: `flutter analyze` = **0 مشكلة** | `flutter test` = **107/107 نجاحاً** | الترحيل السحابي مثبّت على المشروع الصحيح.

---

## 1) نظام الوسوم والتصنيفات (Tags & Labels)

**قاعدة البيانات المحلية (SQLite):**
- جدول `tags`: `id (PK)`, `name`, `color_hex`, `order_index`, `sync_status`, `created_at`, `updated_at`, `deleted_at` + فهرس `idx_tags_deleted`.
- جدول الربط `task_tags`: مفتاح مركّب `(task_id, tag_id)` مع حذف متتالٍ والفهارس `idx_task_tags_task`, `idx_task_tags_tag`.
- ترقية قاعدة البيانات إلى **الإصدار v2** (في مساري الويب والـ Desktop) عبر `onUpgrade` بإعادة تطبيق جمل `IF NOT EXISTS` على القواعد القائمة دون فقدان البيانات.

**الكود:**
- `lib/core/database/database_tables.dart` — تعريفات الجداول والفهارس وإضافتها إلى `allCreateStatements`.
- `lib/core/database/app_database.dart` — ترقية v2 + `onUpgrade`.
- `lib/core/models/tag_model.dart` — `toMap/fromMap/copyWith` + `==`/`hashCode`.
- `lib/core/repositories/tag_repository.dart` + `tag_repository_impl.dart` — `ITagRepository` بتطبيق شامل: إسناد الوسم للمهمة (مع `ConflictAlgorithm.ignore`)، فك الإسناد، جلب وسوم مهمة (JOIN)، جلب معرفات المهام للوسم.
- `lib/features/tags/presentation/controllers/tags_controller.dart` — إدارة الوسوم + الفلترة حسب الوسم النشط (`filterTasksByActiveTag`, `clearTagFilter`).

**الاختبارات:** `test/tags_test.dart`.

---

## 2) محرك المهام المتكررة (Recurring Tasks)

**قاعدة البيانات المحلية:**
- أعمدة إضافية في `tasks`: `is_recurring INTEGER NOT NULL DEFAULT 0`, `recurrence_pattern TEXT`, `recurrence_interval INTEGER NOT NULL DEFAULT 1`, `recurrence_end_date TEXT`, `assigned_to TEXT`.
- دالة `_ensureTaskColumns` في `app_database.dart` تستخدم `PRAGMA table_info` + `ALTER TABLE` (آمنة للتكرار) في مسارَي `onUpgrade`.

**الكود:**
- `lib/features/tasks/data/models/task_model.dart` — حقول التكرار والإسناد في `toMap/fromMap/copyWith`.
- `lib/core/services/recurrence_service.dart`:
  - `calculateNextDueDate(baseDate, pattern, interval)` — يدعم `daily / weekly / monthly / custom_interval` مع معالجة نهاية الشهر (31 → 28/30).
  - `generateNextRecurrence(completedTask, taskRepo, subtaskRepo)` — ينشئ نسخة `todo` جديدة بنفس الخصائص، يعيد إنشاء المهام الفرعية غير المكتملة (`is_completed = 0`) مع `shareToken` جديد، ويتوقف عند تجاوز `recurrenceEndDate`.
- `lib/features/tasks/presentation/controllers/tasks_controller.dart` — ربط التكرار في `updateStatus`: عند إكمال مهمة متكررة تولَّد النسخة التالية ثم يُعاد تحميل القائمة بنفس الفلاتر.

**الاختبارات:** `test/recurrence_test.dart` (11 اختباراً، مع معالجة التخزين وفق UTC عبر `isAtSameMomentAs`).

---

## 3) خدمة تصدير CSV (Export Service)

- `lib/core/services/export_service.dart`:
  - `exportTasksToCsv({tasks, projectNames, areaNames})` — يبدأ بـ **UTF-8 BOM** ليفتح صحيحاً في Excel مع الحفاظ التام على العربية.
  - هروب الفواصل والاقتباسات والأسطر الجديدة داخل الخلايا (RFC 4180).
  - دوال عرض جدولي مساعدة: `filterByStatus`, `filterByPriority`, `sortByDueDate`, `sortByPriority`.
- **الاختبارات:** `test/export_service_test.dart` (9 اختبارات).

---

## 4) منطق المشاركة والتعاون (Sharing & Collaboration Backend)

- `lib/core/models/entity_share_model.dart` — نموذج مطابق لجدول السحابة `entity_shares` (مع دعم قراءة `permission` أو `role`) ودوال `canEdit/canDelete/isPublicLink`.
- `lib/core/services/share_read_service.dart` — قراءة الكيانات العامة عبر RPC `get_shared_entity` دون حساب:
  - `fetchPublicEntityByToken(token)` — يعيد المهمة + مهامها الفرعية، أو المشروع + مهامه، أو المجال + مشاريعه عبر بنية `SharedEntityResult` (قراءة فقط، آمنة عبر RLS وgrant المشروع).
  - `fetchPublicTaskWithSubtasks(token)`.
  - عقد `SupabaseServiceLike` قابل للحقن (seam اختباري) مع محوّل داخلي لـ `SupabaseService.client`.
- `lib/features/sharing/presentation/controllers/sharing_controller.dart` — يشرف على الرابط العام والدعوات والصلاحيات: `loadShares`, `generatePublicLink`, `revokePublicLink`, `inviteCollaborator`, `updatePermission`, `removeShare`, وتحويل `ShareModel` إلى `EntityShareModel`.
- **الاختبارات:** `test/share_read_service_test.dart` (11 اختباراً).

---

## 5) مزامنة السحابة (Sync Parity)

- تحديث قائمة أعمدة جدول `tasks` في `lib/core/services/sync_service.dart` (`_SyncTable`) لتشمل الأعمدة الخمسة الجديدة لمزامنتها مع السحابة.

---

## 6) نشر الترحيل على Supabase (تم التنفيذ)

**الملف:** `supabase/migrations/20260908000100_add_task_recurrence_columns.sql`

**التنفيذ (عبر CLI مع الاتصال المباشر `--db-url` بمشروع Tasky فقط):**
- المشروع المتصل والمؤكَّد: `postgres.yjcpevqahefzcpbvajcq` عبر pooler `aws-1-ap-south-1.pooler.supabase.com` (قاعدة TaskyDatabase).
- تنفيذ 6 جُمل (كلٌّ على حدة لأن CLI يرفض عدة جُمل في استعلام واحد):
  1. `ALTER TABLE tasks ADD COLUMN IF NOT EXISTS is_recurring integer NOT NULL DEFAULT 0` ✅
  2. `ADD COLUMN IF NOT EXISTS recurrence_pattern text` ✅
  3. `ADD COLUMN IF NOT EXISTS recurrence_interval integer NOT NULL DEFAULT 1` ✅
  4. `ADD COLUMN IF NOT EXISTS recurrence_end_date text` ✅
  5. `ADD COLUMN IF NOT EXISTS assigned_to text` ✅
  6. `CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks (assigned_to) WHERE assigned_to IS NOT NULL` ✅
- **التحقق لاحقاً:** الأعمدة الخمسة مؤكدة في `information_schema.columns` (الأنواع والافتراضات صحيحة)، والفهرس مؤكد في `pg_indexes`.

---

## 7) ملاحظات ومعالجات تمت

- آليّة تسجيل دخول CLI المؤقتة أعطت خطأ `LegacyDbConfigLoginRoleStatusError` (خلل خادمي معروف) — عولج بالاتصال المباشر `--db-url` حسب إرشادات `AGENTS.md`.
- جُمل SQL ما زالت تحافظ على طابع `IF NOT EXISTS` فأي إعادة تنفيذ مستقبلية لا تُلحق ضرراً.
- لم يُنفَّذ أي إجراء (قراءة أو كتابة) على المشروع الآخر `pioxojsrrewskptxezll` — الاتصال حكر على مشروع Tasky.
- لم يُرفع أي شيء على GitHub ولم يُنشر على Vercel في هذه المرحلة.

---

## 8) أدوات التحقق والجودة

| الفحص | النتيجة |
| --- | --- |
| `flutter analyze` | No issues found (0 أخطاء / 0 تحذيرات) |
| `flutter test` | **107/107** اختباراً ناجحاً (بما فيها اختبار ترقية v1→v2) |
| التأكد من صحة المشروع المتصل قبل الترحيل | `current_database` عبر pooler Tasky |
| التحقق بعد الترحيل | الأعمدة + الفهرس حاضرون في `information_schema` و`pg_indexes` |

**عدد الاختبارات الجديدة المضافة في هذه المرحلة: 41** (الوسوم 9 + التكرار 11 + تصدير 9 + مشاركة 11 + ترقية القاعدة 1).

---

## 9) ملحق: مزامنة الوسوم مع السحابة + نشر ترحيل المشاركة (تم التنفيذ)

بعد مراجعة المنجز، أُكملت الخطوة الأخيرة لإغلاق طبقة السحابة والمزامنة 100%:

**أ) مزامنة الوسوم (Tags Cloud Sync):**
- **ترحيل سحابي** `supabase/migrations/20260908000200_add_tags_tables.sql`:
  - `tags`: id, user_id, name, color_hex, order_index, sync_status, created_at, updated_at, deleted_at.
  - `task_tags`: id (edge sync)، user_id، task_id (FK)، tag_id (FK)، timestamps + `unique(task_id, tag_id)`.
  - الفهارس الثلاثة، تفعيل RLS، وسياسات select/insert/update/delete لمالك الصف فقط.
- **مزامنة محلية v3**: ترقية قاعدة SQLite إلى v3 مع `_ensureTaskTagColumns` (ALTER آمن + تعبئة الهوية المستقرّة `task_id|tag_id` للروابط القديمة) في مساري الويب والـ Desktop.
- **`TagRepositoryImpl`**: كتابة الروابط بهوية مستقرة و`pending_insert`، فك ربط هادئ `pending_delete` مع استعادة تلقائية عند إعادة الإسناد، وترشيح المحذوف في القراءات.
- **`SyncService._tables`**: إضافة `tags` و `task_tags` بقوائم الأعمدة الصحيحة للرفع/التنزيل التلقائي.

**ب) ترحيل المشاركة على Supabase:**
- تم التأكد أن `supabase/migrations/20260907000200_setup_entity_shares.sql` مطبَّق أصلاً: جدول `entity_shares` وRPC `get_shared_entity` وسياسات RLS حاضرة (4 سياسات).

**ج) النشر والتحقق (مشروع yjcpevqahefzcpbvajcq فقط):**
- `supabase db push --db-url` طبق: `20260908000100_add_task_recurrence_columns.sql` (أعمدة التكرار — آمنة، النتائج "skipping") ثم `20260908000200_add_tags_tables.sql`.
- التحقق: الجداول السبع حاضرة في `information_schema`، RLS مفعّل (`relrowsecurity = true`)، 4 سياسات لكل جدول، وسجل `supabase_migrations.schema_migrations` يحتوي الترحيلات الأربعة كاملة.
- ملاحظة: تحذير Docker الظاهر أثناء push يخصّ كاش محلي للتخزين المؤقت فقط وليس فشل تطبيق.

**د) النتائج النهائية (بعد الإضافة):**

| الفحص | النتيجة |
| --- | --- |
| `flutter analyze` | No issues found (0 أخطاء / 0 تحذيرات) |
| `flutter test` | **109/109** اختباراً ناجحاً (أُضيف اختباران لمزامنة الروابط) |
| الجداول السحابية | areas, projects, tasks, subtasks, tags, task_tags, entity_shares |
| سجل الترحيلات | 20260907000100 / 20260907000200 / 20260908000100 / 20260908000200 |

---

## 10) ملحق: إصلاح روابط المشاركة العامة (تم التنفيذ بعد فحص رابط حقيقي)

**البلاغ:** الرابط `https://taskyw.vercel.app/#/share/41e94162` أظهر «الرابط غير صالح أو انتهت صلاحية مشاركته».

**التشخيص (من قاعدة السحابة):**
- جدول `tasks` يحوي رموز مشاركة مزامنة من التطبيق (`41e94162`, `32a6ae19`), بينما جدول `entity_shares` كان **فارغاً تماماً**.
- دالة `get_shared_entity` كانت تقرأ من `entity_shares` حصراً → رفضٌ دائم لروابط المشاركة التي يولّدها زر «مشاركة المهمة» (نمط offline-first يكتب `share_token` على `tasks` ثم يزامنه).

**الإصلاح (ترحيلان على مشروع yjcpevqahefzcpbvajcq فقط):**
1. `20260908000300_fix_public_share_lookup.sql`:
   - توسيع `get_shared_entity` بمسار تراجعي: عند غياب سجل في `entity_shares` تبحث المهمة مباشرة عبر `tasks.share_token` (قراءة عامة، `security definer`، دون تسريب صفوف المستخدم).
   - سياسة قراءة عامة لمهام المهام الفرعية لمهمة موسومة برابط (الإصدار الأول).
2. `20260908000400_fix_public_share_subtask_policy.sql`:
   - تصحيح سياسة `subtasks`: `EXISTS` المباشر على `tasks` يتأثر بـ RLS الخاصة بها مع المجهول → استُبدل بدالة مساعدة `task_is_public(text)` بسمة `security definer`.

**التحقق (مستخدم مجهول عبر REST):**
- `rpc/get_shared_entity` بالرمز `41e94162` → يعيد المهمة «اصلاحات محطه معالجه المياه» ✅
- جلب `subtasks` لمعرف المهمة → **2/2** مهاماً فرعية ✅
- رمز غير صحيح `deadbeef` → HTTP 400 ✅ (يُعرض منه «الرابط غير صالح» بنجاح)

**النتيجة النهائية للفصل:**

| الفحص | النتيجة |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | **113/113** اختباراً ناجحاً |
| روابط المشاركة العامة | تعمل (Fetches entity + children كمجموعة anon) |
| سجل الترحيلات | حتى `20260908000400` |