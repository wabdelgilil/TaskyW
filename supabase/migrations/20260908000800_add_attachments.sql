-- Tasky 3.0 - File & Document Attachments (على مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- 1) جدول المرفقات (Attachments) — Offline-First بمزامنة عبر sync_status
create table if not exists public.attachments (
  id         text primary key,
  user_id    uuid default auth.uid() references auth.users (id) on delete cascade,
  task_id    text not null references public.tasks (id) on delete cascade,
  file_name  text not null,
  file_url   text,
  file_size  bigint not null default 0,
  mime_type  text,
  sync_status text not null default 'pending_insert',
  created_at text not null,
  updated_at text not null,
  deleted_at text
);

create index if not exists idx_attachments_task
  on public.attachments (task_id, deleted_at);

create index if not exists idx_attachments_user
  on public.attachments (user_id, deleted_at);

alter table public.attachments enable row level security;

-- الملكية الكاملة (المستخدم الذي ينشئ المرفق فقط)
create policy "attachments_select_own" on public.attachments
  for select using (user_id = auth.uid());
create policy "attachments_insert_own" on public.attachments
  for insert with check (user_id = auth.uid());
create policy "attachments_update_own" on public.attachments
  for update using (user_id = auth.uid());
create policy "attachments_delete_own" on public.attachments
  for delete using (user_id = auth.uid());

-- 2) باكت التخزين (Storage Bucket) للمرفقات
insert into storage.buckets (id, name, public)
values ('tasky-attachments', 'tasky-attachments', false)
on conflict (id) do nothing;

-- المسارات بالتنسيق: <user_id>/<attachment_id>/<file_name>
-- رفع/قراءة/حذف الكائنات حصرية داخل مجلد المستخدم ذاته
create policy "tasky_attachments_read_own" on storage.objects
  for select using (
    bucket_id = 'tasky-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "tasky_attachments_write_own" on storage.objects
  for insert with check (
    bucket_id = 'tasky-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "tasky_attachments_delete_own" on storage.objects
  for delete using (
    bucket_id = 'tasky-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );