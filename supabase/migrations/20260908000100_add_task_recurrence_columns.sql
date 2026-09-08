-- Tasky 3.0 - ترقية مزامنة المهام (مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- إضافة أعمدة التكرار وإسناد المتعاون لكل مهام السحابة لتحقيق التطابق مع SQLite المحلي.
-- (ALTER TABLE ADD COLUMN): إذا كررت التنفيذ فلن تضر؛ الأعمدة نفسها تُضاف مرة واحدة.
alter table public.tasks add column if not exists is_recurring integer not null default 0;
alter table public.tasks add column if not exists recurrence_pattern text;
alter table public.tasks add column if not exists recurrence_interval integer not null default 1;
alter table public.tasks add column if not exists recurrence_end_date text;
alter table public.tasks add column if not exists assigned_to text;

-- فهرس للإسناد (assigned_to)
create index if not exists idx_tasks_assigned_to on public.tasks (assigned_to) where assigned_to is not null;