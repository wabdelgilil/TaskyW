# Tasky 3.0 — قواعد العمل (Agent Rules)

هذا المستند للوكلاء (Agents) الذين يعملون على مشروع Tasky 3.0.

## ⛔ قواعد العمل الصارمة (Strict Rules)

### 1. لا ترفع على GitHub أو تنشر على Vercel إلا بموافقة صريحة
- **ممنوع منعاً باتاً** تشغيل أي أمر نشر أو بناء للإنتاج على Vercel (`vercel`, `vercel --prod`) أو دفع التغييرات إلى GitHub (`git push`) **إلا بعد طلب وأخذ الموافقة الصريحة المباشرة من المستخدم**.
- التطوير والاختبار يتم محلياً أولاً، وعند الرغبة في النشر يتم إخطار المستخدم وانتظار تأكيده.

### 2. لا تتعامل مع قاعدة بيانات المشروع الآخر نهائياً

- مشروع Supabase **الوحيد** الخاص بنا: **`yjcpevqahefzcpbvajcq`** (اسمه TaskyDatabase) — الرابط: `https://yjcpevqahefzcpbvajcq.supabase.co`
- **ممنوع منعاً باتاً** تنفيذ أي إجراء (قراءة / كتابة / حذف / ترحيل / RPC) على المشروع الآخر: **`pioxojsrrewskptxezll`** — الرابط: `https://pioxojsrrewskptxezll.supabase.co`
  - هذا المشروع قاعدة بيانات لمشروع مختلف تماماً (نظام صيانة/أصول CMMS) — لا علاقة له بـ Tasky.

### لماذا هذه القاعدة حرجة؟
أدوات MCP الخاصة بـ Supabase (apply_migration / execute_sql / list_tables / create_branch ...) **موصولة حالياً بالمشروع الآخر `pioxojsrrewskptxezll` وليس بمشروعنا**. لذلك:

1. **لا تستخدم أدوات MCP لتعديل سكيما أو بيانات Tasky إطلاقاً** — أي استخدام لها سيصيب قاعدة المشروع الخطأ.
2. أدوات MCP للقراءة فقط (list_tables/query_logs) قد تُستخدم لفهم المشروع الآخر، لكن **بدون أي كتابة أو حذف**.
3. كل تعديلات سكيما/بيانات Tasky تمر **حصرياً** عبر Supreme CLI بعد ربط المشروع الصحيح من جذر المشروع:
   ```
   supabase link --project-ref yjcpevqahefzcpbvajcq
   supabase db query --linked "<SQL>"
   supabase db push
   ```
4. **قبل أي إجراء مدمر** (حذف جدول/بيانات/تعديل) تأكد دائماً من أن الاستعلام يعمل على قاعدة Tasky:
   ```
   supabase db query --linked "select current_database();"
   ```
   وأن الناتج يشير إلى المشروع `yjcpevqahefzcpbvajcq` وليس الآخر.

---

### 3. تقسيم الأدوار والمسؤوليات بين الوكلاء (Agent Specialization & Division of Labor)
يعتمد تطوير Tasky 3.0 على نموذج العمل المزدوج المتخصص:

* **الوكيل الرئيسي (Main Agent) — مسؤول الواجهات وتجربة المستخدم (Frontend Lead)**:
  - هو قائد التطوير والمخاطب المباشر للمستخدم.
  - مسؤول حصرياً عن طبقة العرض والواجهات (Presentation Layer / Flutter UI & Widgets).
  - تصميم الشاشات، استجابة الموبايل والديسكتوب (Responsive Layouts)، النوافذ السفلية (BottomSheets)، والحوارات التفاعلية (Dialogs).
  - ربط الواجهات بالمتحكمات وتوجيه استدعاءات المستخدم وتناسق الألوان والثيم.
  - تنسيق خطط العمل الشاملة وتحديث وثائق المشروع (`MASTER_PLAN.md` و `COMPLETED_WORK.md`).

* **الوكيل الفرعي (Sub Agent) — مسؤول المنطق والبيانات (Backend & Logic Specialist)**:
  - يُستدعى بواسطة الوكيل الرئيسي لتنفيذ مهام المنطق والبيانات المعزولة.
  - مسؤول عن طبقات البيانات والمجال (Data & Domain Layers).
  - بنية وتحديثات قواعد البيانات المحلية (SQLite / Drift / Migrations) والترتيب السحابي (Supabase Schemas).
  - خدمات المنطق والخدمات الخلفية (Services مثل `NotificationService`, `SettingsService`, `SyncService`).
  - نماذج البيانات (Models)، المستودعات (Repositories)، والمتحكمات المنطقية (Controllers).
  - كتابة اختبارات الوحدة (Unit & Repository Tests) وضمان سلامة معالجة البيانات دون التداخل مع ملفات الواجهات.

---

### 4. إدارة إصدارات المشروع ورسائل الكوميت (Automated Project Versioning & Commit Protocol)
- **ملفات الإصدار المعتمدة**:
  1. ملف تهيئة Flutter الأساسي: `pubspec.yaml` (سطر `version: X.Y.Z+B`).
  2. ملف الثوابت المباشر للتطبيق: `lib/core/constants/app_version.dart`.
- **بروتوكول الترقية الإلزامي**:
  - عند كل إضافة خاصية جديدة (Feature) أو تعديل جوهري (Fix/Refactor)، **يتم رفع رقم الإصدار تلقائياً** (`Patch` للتعديلات والتحسينات، و `Minor` للميزات والوحدات الجديدة).
  - يجب مزامنة رقم الإصدار في كلا الملفين `pubspec.yaml` و `app_version.dart`.
- **بروتوكول رسائل الكوميت (Git Commit Message Format)**:
  - يجب دائماً أن تبدأ رسالة الكوميت برقم الإصدار المعتمد بين قوسين أو مسبوقاً بـ `v`:
    ```
    v3.0.1: [Feature] Add project notification toggle and mobile task bottomsheet
    ```
    أو:
    ```
    v3.0.2: [Fix] Resolve notification scheduling on project mute
    ```
  - يُمنع عمل أي كوميت بدون تضمين رقم الإصدار في بداية العنوان.
  - يُعرض رقم الإصدار دائماً في واجهات التطبيق (شاشة البروفايل، شاشة الإعدادات، وقسم حول التطبيق).

## أوامر تحقق مفيدة
- معرف الجداول العامة: `supabase db query --linked "select table_name from information_schema.tables where table_schema='public' order by table_name;"`
- الفهارس: `supabase db query --linked "select indexname, tablename from pg_indexes where schemaname='public' order by tablename;"`

## استكشاف الأخطاء (Troubleshooting)

### خطأ `cli_login_postgres` (permission denied to alter role)
أحياناً تعلق آلية تسجيل الدخول المؤقتة للـ CLI على جهة Supabase، ويظهر هذا الخطأ في كل أوامر `supabase db query/push`:
```
Failed to create login role: ERROR: 42501: permission denied to alter role "cli_login_postgres"
```
- هذا خلل **خادمي** (server-side) وليس في الكود المحلي، ولا يعني فشل أي ترحيل طُبّق سابقاً.
- الحل الأول: في **Dashboard → SQL Editor** شغّل:
  ```sql
  DROP ROLE IF EXISTS cli_login_postgres;
  ```
  ثم أعد المحاولة من CLI (عادةً تتظهّر آلية جديدة).
- الحل الثاني: استخدم اتصالاً مباشراً بـ `--db-url` مع باسورد قاعدة البيانات:
  ```
  supabase db query --linked ...  # بعد تعذرها
  supabase db query --db-url "postgresql://postgres.<ref>:<password>@aws-1-pooler.supabase.com:5432/postgres" "<SQL>"
  ```
- بخلاف ذلك، يتنظّف الدور المعلق تلقائياً بعد فترة من Supabase.