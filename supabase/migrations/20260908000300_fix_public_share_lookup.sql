-- Tasky 3.0 - إصلاح روابط المشاركة العامة (مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- خلفية المشكلة: زر «مشاركة المهمة» في التطبيق يكتب share_token على صف tasks فقط
-- (نمط offline-first ويُزامَن لاحقاً)، بينما كانت get_shared_entity تقرأ من entity_shares
-- حصراً فتُرفض كل الروابط لأن entity_shares لا يحتويها.

-- 1) توسيع get_shared_entity بمسار تراجعي: إذا لم يوجد سجل في entity_shares
-- تُبحث المهمة مباشرة عبر share_token على جدول tasks نفسه (قراءة عامة فقط).
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

  if found then
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
  end if;

  -- المسار التراجعي لمشاركة المهام عبر tasks.share_token المزامن محلياً
  if v_row is null then
    select to_jsonb(r) into v_row
    from public.tasks r
    where r.share_token = p_token
      and r.deleted_at is null;
  end if;

  if v_row is null then
    raise exception 'share not found';
  end if;

  return v_row;
end;
$$;

-- إعادة ضبط التفويض (فوظيفة القراءة العامة تبقى متاحة للمجهول والمصادق)
revoke all on function public.get_shared_entity(text) from public;
grant execute on function public.get_shared_entity(text) to anon, authenticated;

-- 2) سياسة قراءة عامة لمهام المهام الفرعية التابعة لمهمة لها share_token
-- (حتى يعرض رابط المشاركة المهام الفرعية للزائر المجهول دون كشف بيانات أخرى).
create policy "subtasks_select_public_share" on public.subtasks
  for select using (
    exists (
      select 1 from public.tasks t
      where t.id = subtasks.task_id
        and t.share_token is not null
        and t.deleted_at is null
    )
  );