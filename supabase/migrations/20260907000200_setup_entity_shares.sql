-- Tasky 3.0 - جدول المشاركة والتعاون (على مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- 1) جدول المشاركات (هيراركي: area / project / task)
create table if not exists public.entity_shares (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid default auth.uid() references auth.users (id) on delete cascade,
  entity_type text not null check (entity_type in ('area', 'project', 'task')),
  entity_id   text not null,
  user_id     uuid references auth.users (id) on delete cascade,
  email       text,
  display_name text,
  permission  text not null default 'viewer' check (permission in ('viewer', 'editor', 'admin')),
  share_token text unique,
  is_public   boolean not null default false,
  created_at  text not null default to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'),
  updated_at  text not null default to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'),
  unique (entity_type, entity_id, user_id)
);

-- 2) فهارس الأداء
create index if not exists idx_entity_shares_entity on public.entity_shares (entity_type, entity_id);
create index if not exists idx_entity_shares_token on public.entity_shares (share_token);
create index if not exists idx_entity_shares_user on public.entity_shares (user_id);

-- 3) أمان مستوى الصف
alter table public.entity_shares enable row level security;

-- 4) سياسات الوصول: المالك أو المتعاون يرى سجلاته فقط
create policy "entity_shares_select_own" on public.entity_shares
  for select using (owner_id = auth.uid() or user_id = auth.uid());
create policy "entity_shares_insert_own" on public.entity_shares
  for insert with check (owner_id = auth.uid());
create policy "entity_shares_update_own" on public.entity_shares
  for update using (owner_id = auth.uid() or user_id = auth.uid());
create policy "entity_shares_delete_own" on public.entity_shares
  for delete using (owner_id = auth.uid());

-- 5) منح المتعاونين حق الوصول إلى بيانات المالك على الجداول الأصلية
-- (select لرابط القراءة العام عبر share_token تُعالج ضمنياً من وظيفة RPC)

-- دالة RPC لجلب كيان مشارك عبر رمز عام (لا يتطلب تسجيل دخول).
-- تُستخدم في href مشاركة القراءة العامة للمتدعوين غير المسجلين.
create or replace function public.get_shared_entity(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_share public.entity_shares%rowtype;
  v_row jsonb;
begin
  if p_token is null or length(trim(p_token)) = 0 then
    raise exception 'invalid token';
  end if;

  select * into v_share
  from public.entity_shares
  where share_token = p_token and is_public = true;

  if not found then
    raise exception 'share not found';
  end if;

  if v_share.entity_type = 'area' then
    select to_jsonb(r) into v_row
    from public.areas r
    where r.id = v_share.entity_id and r.deleted_at is null;
  elsif v_share.entity_type = 'project' then
    select to_jsonb(r) into v_row
    from public.projects r
    where r.id = v_share.entity_id and r.deleted_at is null;
  elsif v_share.entity_type = 'task' then
    select to_jsonb(r) into v_row
    from public.tasks r
    where r.id = v_share.entity_id and r.deleted_at is null;
  else
    raise exception 'unsupported entity type';
  end if;

  if v_row is null then
    raise exception 'entity not found';
  end if;

  return v_row;
end;
$$;

-- إبطال تنفيذ الوظيفة العامة للعموم (يُسمح فقط للمالك بدعوة المتعاونين)
revoke all on function public.get_shared_entity(text) from public;
grant execute on function public.get_shared_entity(text) to anon, authenticated;
