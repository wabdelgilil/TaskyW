-- Tasky 3.0 - ترقية مزامنة المشاريع (مشروع yjcpevqahefzcpbvajcq فقط)
-- لا يُنفذ أبداً على pioxojsrrewskptxezll (قاعدة مشروع آخر).
--
-- ضبط جدول projects السحابي ليطابق SQLite المحلي (ترحيل DB v9):
-- خاصية كتم إشعارات المشروع (Project Notification Toggle) أُضيفت محلياً
-- لاحقاً دون أن تُضاف للجدول السحابي، الأمر الذي كسر مزامنة المشاريع
-- (PGRST204: Could not find the 'notifications_enabled' column).

alter table public.projects
  add column if not exists notifications_enabled boolean not null default true;

-- تحديث فهرس sync_status إن وُجد (اختياري — للتأكد من تغطية الصفوف القديمة).
-- العمود جديد بقيمة تلقائية true، لذا لا حاجة لتحديث الصفوف الموجودة.