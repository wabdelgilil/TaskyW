-- Tasky 3.0 - تحسين مطابقة بريد Auto-Link (غير حساسة لحالة الأحرف) + ربط خلفي
-- مشروع yjcpevqahefzcpbvajcq فقط.
-- إعادة تعريف الدالتين بنفس الأسماء: الـ Trigger الحالي يستدعيهما مباشرة.

-- 1) دالة Trigger: مطابقة lower(collaborator_email) = lower(new.email)
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

-- 2) RPC تسجيل الدخول: مطابقة lower() أيضاً
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

-- 3) ربط خلفي لمرة واحدة: تفعيل أي دعوات pending مرتبطة بحسابات موجودة أصلاً
update public.entity_shares es
   set collaborator_id = u.id,
       status = 'active',
       updated_at = to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')
 from auth.users u
where lower(es.collaborator_email) = lower(u.email)
  and es.status = 'pending'
  and es.collaborator_id is null
  and es.deleted_at is null;