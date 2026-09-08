-- Tasky 3.0 - جداول الوسوم ومزامنتها مع السحابة (مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- 1) جدول الوسوم (tags)
create table if not exists public.tags (
  id          text primary key,
  user_id     uuid default auth.uid() references auth.users (id) on delete cascade,
  name        text not null,
  color_hex   text not null default '#64748B',
  order_index integer not null default 0,
  sync_status text not null default 'pending_insert',
  created_at  text not null,
  updated_at  text not null,
  deleted_at  text
);

-- 2) جدول ربط المهام بالوسوم (task_tags) - edge مع المعرّف الأحادي للمزامنة
create table if not exists public.task_tags (
  id         text primary key,
  user_id    uuid default auth.uid() references auth.users (id) on delete cascade,
  task_id    text not null references public.tasks (id) on delete cascade,
  tag_id     text not null references public.tags (id) on delete cascade,
  created_at text not null,
  updated_at text,
  deleted_at text,
  unique (task_id, tag_id)
);

-- 3) فهارس الأداء
create index if not exists idx_tags_deleted on public.tags (deleted_at);
create index if not exists idx_task_tags_task on public.task_tags (task_id, deleted_at);
create index if not exists idx_task_tags_tag on public.task_tags (tag_id);

-- 4) أمان مستوى الصف
alter table public.tags enable row level security;
alter table public.task_tags enable row level security;

-- 5) سياسات الوصول: المستخدم يرى صفوفه فقط
create policy "tags_select_own" on public.tags for select using (user_id = auth.uid());
create policy "tags_insert_own" on public.tags for insert with check (user_id = auth.uid());
create policy "tags_update_own" on public.tags for update using (user_id = auth.uid());
create policy "tags_delete_own" on public.tags for delete using (user_id = auth.uid());

create policy "task_tags_select_own" on public.task_tags for select using (user_id = auth.uid());
create policy "task_tags_insert_own" on public.task_tags for insert with check (user_id = auth.uid());
create policy "task_tags_update_own" on public.task_tags for update using (user_id = auth.uid());
create policy "task_tags_delete_own" on public.task_tags for delete using (user_id = auth.uid());