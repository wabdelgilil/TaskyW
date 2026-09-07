-- Tasky 3.0 - Supabase Cloud Schema (على مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- 1) تفريغ الجداول القديمة (مشروع سابق)
drop table if exists public.resources_expenses cascade;
drop table if exists public.task_dependencies cascade;
drop table if exists public.task_collaborators cascade;
drop table if exists public.tasks cascade;

-- 2) مجالات (Areas)
create table if not exists public.areas (
  id         text primary key,
  user_id    uuid default auth.uid() references auth.users (id) on delete cascade,
  name       text not null,
  icon_emoji text not null default '📁',
  color_hex  text not null default '#3B82F6',
  order_index integer not null default 0,
  sync_status text not null default 'pending_insert',
  created_at text not null,
  updated_at text not null,
  deleted_at text
);

-- 3) مشاريع (Projects)
create table if not exists public.projects (
  id          text primary key,
  user_id     uuid default auth.uid() references auth.users (id) on delete cascade,
  area_id     text not null references public.areas (id) on delete cascade,
  name        text not null,
  description text,
  icon_emoji  text not null default '📋',
  color_hex   text not null default '#10B981',
  status      text not null default 'active', -- active, on_hold, completed
  target_date text,
  order_index integer not null default 0,
  sync_status text not null default 'pending_insert',
  created_at  text not null,
  updated_at  text not null,
  deleted_at  text
);

-- 4) مهام (Tasks)
create table if not exists public.tasks (
  id           text primary key,
  user_id      uuid default auth.uid() references auth.users (id) on delete cascade,
  area_id      text not null references public.areas (id) on delete cascade,
  project_id   text references public.projects (id) on delete cascade,
  title        text not null,
  description  text,
  status       text not null default 'todo', -- todo, in_progress, waiting, review, completed
  priority     text not null default 'medium', -- low, medium, high, urgent
  color_hex    text,
  due_date     text,
  reminder_time text,
  share_token  text unique,
  order_index  integer not null default 0,
  sync_status  text not null default 'pending_insert',
  created_at   text not null,
  updated_at   text not null,
  deleted_at   text
);

-- 5) مهام فرعية (Subtasks)
create table if not exists public.subtasks (
  id           text primary key,
  user_id      uuid default auth.uid() references auth.users (id) on delete cascade,
  task_id      text not null references public.tasks (id) on delete cascade,
  title        text not null,
  is_completed integer not null default 0,
  order_index  integer not null default 0,
  sync_status  text not null default 'pending_insert',
  created_at   text not null,
  updated_at   text not null,
  deleted_at   text
);

-- 6) فهارس الأداء والبحث (Indexes)
create index if not exists idx_areas_deleted on public.areas (deleted_at);
create index if not exists idx_projects_area on public.projects (area_id, deleted_at);
create index if not exists idx_tasks_project on public.tasks (project_id, deleted_at);
create index if not exists idx_tasks_area on public.tasks (area_id, deleted_at);
create index if not exists idx_tasks_status on public.tasks (status);
create index if not exists idx_tasks_due_date on public.tasks (due_date);
create index if not exists idx_subtasks_task on public.subtasks (task_id, deleted_at);

-- 7) أمان مستوى الصف (Row Level Security)
alter table public.areas enable row level security;
alter table public.projects enable row level security;
alter table public.tasks enable row level security;
alter table public.subtasks enable row level security;

-- 8) سياسات الوصول لكل جدول (المستخدم يرى صفوفه فقط)
create policy "areas_select_own" on public.areas for select using (user_id = auth.uid());
create policy "areas_insert_own" on public.areas for insert with check (user_id = auth.uid());
create policy "areas_update_own" on public.areas for update using (user_id = auth.uid());
create policy "areas_delete_own" on public.areas for delete using (user_id = auth.uid());

create policy "projects_select_own" on public.projects for select using (user_id = auth.uid());
create policy "projects_insert_own" on public.projects for insert with check (user_id = auth.uid());
create policy "projects_update_own" on public.projects for update using (user_id = auth.uid());
create policy "projects_delete_own" on public.projects for delete using (user_id = auth.uid());

create policy "tasks_select_own" on public.tasks for select using (user_id = auth.uid());
create policy "tasks_insert_own" on public.tasks for insert with check (user_id = auth.uid());
create policy "tasks_update_own" on public.tasks for update using (user_id = auth.uid());
create policy "tasks_delete_own" on public.tasks for delete using (user_id = auth.uid());

create policy "subtasks_select_own" on public.subtasks for select using (user_id = auth.uid());
create policy "subtasks_insert_own" on public.subtasks for insert with check (user_id = auth.uid());
create policy "subtasks_update_own" on public.subtasks for update using (user_id = auth.uid());
create policy "subtasks_delete_own" on public.subtasks for delete using (user_id = auth.uid());