-- Tasky 3.0 - جلب أولاد الكيان المشارك برابط عام (قراءة فقط بلا حساب)
-- ينطبق حصرياً على مشروع yjcpevqahefzcpbvajcq. لا يُنفذ على pioxojsrrewskptxezll.
--
-- سبب هذا الترحيل: الكيان الأب يُجلب عبر get_shared_entity (security definer)
-- فيتجاوز RLS، لكن جلب الأولاد (tasks/projects/areas/subtasks) مباشرةً عبر
-- الجداول يفشل لأن RLS مفعّلة والزائر المجهول (anon) لا يملك أي مشاركة مطابقة.
-- لهذا نكشف دوالاً آمنة تتحقق من رمز المشاركة العام (share_token + is_public)
-- ثم تُعيد أولاد الكيان (jsonb) بعد تنفيذها بصلاحيات المالك (security definer).

-- 1) مهام المشروع (عند مشاركة مشروع برابط عام)
create or replace function public.get_shared_tasks(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_share public.entity_shares%rowtype;
  v_rows jsonb;
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

  if v_share.entity_type <> 'project' then
    raise exception 'not a project share';
  end if;

  select coalesce(jsonb_agg(to_jsonb(r) order by r.order_index nulls last, r.created_at), '[]'::jsonb)
    into v_rows
  from public.tasks r
  where r.project_id = v_share.entity_id and r.deleted_at is null;

  return v_rows;
end;
$$;

-- 2) مشاريع المجال (عند مشاركة مجال برابط عام)
create or replace function public.get_shared_projects(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_share public.entity_shares%rowtype;
  v_rows jsonb;
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

  if v_share.entity_type <> 'area' then
    raise exception 'not an area share';
  end if;

  select coalesce(jsonb_agg(to_jsonb(r) order by r.order_index nulls last, r.created_at), '[]'::jsonb)
    into v_rows
  from public.projects r
  where r.area_id = v_share.entity_id and r.deleted_at is null;

  return v_rows;
end;
$$;

-- 3) المهام الفرعية (عند مشاركة مهمة برابط عام)
create or replace function public.get_shared_subtasks(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_share public.entity_shares%rowtype;
  v_rows jsonb;
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

  if v_share.entity_type <> 'task' then
    raise exception 'not a task share';
  end if;

  select coalesce(jsonb_agg(to_jsonb(r) order by r.order_index nulls last, r.created_at), '[]'::jsonb)
    into v_rows
  from public.subtasks r
  where r.task_id = v_share.entity_id and r.deleted_at is null;

  return v_rows;
end;
$$;

-- أذونات التنفيذ: متاح للزائر المجهول (anon) كما في get_shared_entity
revoke all on function public.get_shared_tasks(text) from public;
revoke all on function public.get_shared_projects(text) from public;
revoke all on function public.get_shared_subtasks(text) from public;
grant execute on function public.get_shared_tasks(text) to anon, authenticated;
grant execute on function public.get_shared_projects(text) to anon, authenticated;
grant execute on function public.get_shared_subtasks(text) to anon, authenticated;