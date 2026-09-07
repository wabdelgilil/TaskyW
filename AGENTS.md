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