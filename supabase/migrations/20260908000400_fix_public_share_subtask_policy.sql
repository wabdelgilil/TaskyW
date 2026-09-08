-- Tasky 3.0 - إصلاح قراءة المهام الفرعية للروابط العامة (مشروع yjcpevqahefzcpbvajcq فقط)
-- يسري هذا الترحيل حصرياً على قاعدة TaskyDatabase. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- مشكلة السياسة السابقة: EXISTS على tasks يتأثر بسياسة RLS الخاصة بـ tasks
-- (user_id = auth.uid()) فيُفضي للصفر مع المستخدم المجهول.
-- الحل: دالة مساعدة security definer (تجاوز RLS) يفحصها اعتماداً على share_token فقط.

create or replace function public.task_is_public(p_task_id text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.tasks t
    where t.id = p_task_id
      and t.share_token is not null
      and t.deleted_at is null
  );
$$;

-- قراءة عامة للمهام الفرعية التابعة لمهمة لها share_token (تُستخدم في السياق العامة)
drop policy if exists "subtasks_select_public_share" on public.subtasks;
create policy "subtasks_select_public_share" on public.subtasks
  for select using (public.task_is_public(subtasks.task_id));