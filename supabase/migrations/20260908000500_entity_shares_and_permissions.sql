-- Tasky 3.0 - منظومة المشاركة المتقدمة وتحديد الصلاحيات (مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.
-- الهدف: توسيع entity_shares القائمة (غير مدمر) بدعم:
--   • collaborator_id / collaborator_email
--   • permission_level ('viewer','editor','admin')
--   • status ('pending','active','revoked') + deleted_at
--   • سياسات RLS على الكيانات الأربعة للمتعاونين
--   • دالة / Trigger لربط الدعوات المعلقة ببريد المستخدم عند التسجيل أو الدخول.

-- ─── 1) توسيع الأعمدة (غير مدمر إطلاقاً) ─────────────────────────────
alter table public.entity_shares add column if not exists collaborator_id uuid references auth.users (id) on delete cascade;
alter table public.entity_shares add column if not exists collaborator_email text;
alter table public.entity_shares add column if not exists permission_level text;
alter table public.entity_shares add column if not exists status text not null default 'active';
alter table public.entity_shares add column if not exists deleted_at timestamptz;

-- قيود CHECK (بلا IF NOT EXISTS مدعوم) عبر كتلة DO آمنة
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'entity_shares_permission_level_check'
      and conrelid = 'public.entity_shares'::regclass
  ) then
    alter table public.entity_shares
      add constraint entity_shares_permission_level_check
      check (permission_level in ('viewer', 'editor', 'admin'));
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'entity_shares_status_check'
      and conrelid = 'public.entity_shares'::regclass
  ) then
    alter table public.entity_shares
      add constraint entity_shares_status_check
      check (status in ('pending', 'active', 'revoked'));
  end if;
end $$;

-- تفرد بريد المتعاون الواحد لكل كيان؛ إن وُجدت بيانات مكررة تُترك القاعدة دون فشل.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'entity_shares_entity_collaborator_uniq'
      and conrelid = 'public.entity_shares'::regclass
  ) and not exists (
    select 1 from public.entity_shares
    where collaborator_email is not null
    group by entity_type, entity_id, collaborator_email
    having count(*) > 1
  ) then
    alter table public.entity_shares
      add constraint entity_shares_entity_collaborator_uniq
      unique (entity_type, entity_id, collaborator_email);
  end if;
end $$;

-- ─── 2) فهارس الأداء للمشاركة والتعاون ───────────────────────────────
create index if not exists idx_entity_shares_collab_email
  on public.entity_shares (collaborator_email, status);
create index if not exists idx_entity_shares_collab_user
  on public.entity_shares (collaborator_id, status);

-- ─── 3) سياسات RLS على entity_shares (بالإضافة إلى سياسات المالك القائمة) ──
-- المتعاون يرى سجلاته (بمعرّفه أو بريده) لل- active/revoked.
create policy "entity_shares_select_collaborator" on public.entity_shares
  for select using (
    (collaborator_id = auth.uid())
    or (collaborator_email = auth.jwt()->>'email')
  );

-- ─── 4) سياسات RLS على الكيانات الأربعة للمتعاونين ───────────────────
-- (تبقى سياسات *_own لمالك الصف كما هي؛ هذه إضافات قراءة/تعديل/حذف)

-- areas
create policy "areas_select_collaborator" on public.areas
  for select using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'area' and es.entity_id = areas.id
              and es.status = 'active' and es.deleted_at is null
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "areas_update_collaborator" on public.areas
  for update using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'area' and es.entity_id = areas.id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level in ('editor', 'admin')
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "areas_delete_collaborator" on public.areas
  for delete using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'area' and es.entity_id = areas.id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level = 'admin'
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );

-- projects
create policy "projects_select_collaborator" on public.projects
  for select using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'project' and es.entity_id = projects.id
              and es.status = 'active' and es.deleted_at is null
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "projects_update_collaborator" on public.projects
  for update using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'project' and es.entity_id = projects.id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level in ('editor', 'admin')
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "projects_delete_collaborator" on public.projects
  for delete using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'project' and es.entity_id = projects.id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level = 'admin'
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );

-- tasks
create policy "tasks_select_collaborator" on public.tasks
  for select using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'task' and es.entity_id = tasks.id
              and es.status = 'active' and es.deleted_at is null
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "tasks_update_collaborator" on public.tasks
  for update using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'task' and es.entity_id = tasks.id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level in ('editor', 'admin')
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "tasks_delete_collaborator" on public.tasks
  for delete using (
    exists (select 1 from public.entity_shares es
            where es.entity_type = 'task' and es.entity_id = tasks.id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level = 'admin'
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );

-- subtasks
create policy "subtasks_select_collaborator" on public.subtasks
  for select using (
    exists (select 1 from public.tasks t
            join public.entity_shares es on es.entity_type = 'task' and es.entity_id = t.id
            where t.id = subtasks.task_id
              and es.status = 'active' and es.deleted_at is null
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "subtasks_update_collaborator" on public.subtasks
  for update using (
    exists (select 1 from public.tasks t
            join public.entity_shares es on es.entity_type = 'task' and es.entity_id = t.id
            where t.id = subtasks.task_id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level in ('editor', 'admin')
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );
create policy "subtasks_delete_collaborator" on public.subtasks
  for delete using (
    exists (select 1 from public.tasks t
            join public.entity_shares es on es.entity_type = 'task' and es.entity_id = t.id
            where t.id = subtasks.task_id
              and es.status = 'active' and es.deleted_at is null
              and es.permission_level = 'admin'
              and (es.collaborator_id = auth.uid()
                   or es.collaborator_email = auth.jwt()->>'email'))
  );

-- ─── 5) ربط البريد بالحساب تلقائياً (Auto-Link) ───────────────────────
-- 5.1) Trigger: عند إنشاء حساب new (أو تغيير بريده) تُربط الدعوات المعلقة بالحساب
create or replace function public.auto_link_collaborators()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email is not null then
    update public.entity_shares es
       set collaborator_id = new.id,
           status = case when es.status = 'pending' then 'active' else es.status end,
           updated_at = to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')
     where lower(es.collaborator_email) = lower(new.email)
       and es.collaborator_id is null
       and es.deleted_at is null;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_auto_link_collaborators on auth.users;
create trigger trg_auto_link_collaborators
  after insert or update of email on auth.users
  for each row execute function public.auto_link_collaborators();

-- 5.2) RPC للربط لحظة تسجيل الدخول (للمستخدمين القائمين قبل التفعيل)
create or replace function public.auto_link_collaborator_current()
returns void
language sql
security definer
set search_path = public
as $$
  update public.entity_shares es
     set collaborator_id = auth.uid(),
         status = case when es.status = 'pending' then 'active' else es.status end,
         updated_at = to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')
   where lower(es.collaborator_email) = lower(auth.jwt()->>'email')
     and es.collaborator_id is null
     and es.deleted_at is null
     and auth.uid() is not null;
$$;

grant execute on function public.auto_link_collaborator_current() to authenticated;
revoke all on function public.auto_link_collaborators() from public;
revoke all on function public.auto_link_collaborator_current() from anon, public;

-- ─── 6) ربط خلفي لسجلات pending الموجودة مسبقاً بحسابات قائمة (تعبئة مرة واحدة) ──
update public.entity_shares es
   set collaborator_id = u.id,
       status = 'active',
       updated_at = to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')
 from auth.users u
where lower(es.collaborator_email) = lower(u.email)
  and es.status = 'pending'
  and es.collaborator_id is null
  and es.deleted_at is null;