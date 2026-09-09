-- Tasky 3.0 - Resources & Knowledge Vault (General Notes) — على مشروع yjcpevqahefzcpbvajcq فقط
-- لا يُنفذ أبداً على pioxojsrrewskptxezll.

create table if not exists public.notes (
  id           text primary key,
  user_id      uuid default auth.uid() references auth.users (id) on delete cascade,
  title        text not null,
  content      text,
  color_hex    text,
  is_pinned    boolean not null default false,
  is_archived  boolean not null default false,
  area_id      text,
  sync_status  text not null default 'pending_insert',
  created_at   text not null,
  updated_at   text not null,
  deleted_at   text
);

create index if not exists idx_notes_pinned  on public.notes (is_pinned, updated_at);
create index if not exists idx_notes_area    on public.notes (area_id);
create index if not exists idx_notes_deleted on public.notes (deleted_at);

alter table public.notes enable row level security;

-- الملكية الكاملة (مستخدم الملاحظة فقط)
create policy "notes_select_own" on public.notes
  for select using (user_id = auth.uid());
create policy "notes_insert_own" on public.notes
  for insert with check (user_id = auth.uid());
create policy "notes_update_own" on public.notes
  for update using (user_id = auth.uid());
create policy "notes_delete_own" on public.notes
  for delete using (user_id = auth.uid());