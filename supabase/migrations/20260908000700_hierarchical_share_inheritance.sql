-- Tasky 3.0 - الميراث الهرمي للمشاركة (Hierarchical Share Inheritance)
-- مشروع yjcpevqahefzcpbvajcq فقط.
-- توسيع سياسات RLS بحيث تورّث المشاركة من المجال → المشاريع التابعة → مهامها،
-- ومن المشروع → مهامه، ومن المهمة → مهامها الفرعية.

-- 1) مشاريع المجال المشترك (Projects inherit Area shares)
drop policy if exists "projects_select_collaborator" on public.projects;
create policy "projects_select_collaborator" on public.projects
  for select using (
    -- مشاركة المشروع مباشرة
    exists (
      select 1 from public.entity_shares es
      where es.entity_type = 'project' and es.entity_id = projects.id
        and es.status = 'active' and es.deleted_at is null
        and (es.collaborator_id = auth.uid() or lower(es.collaborator_email) = lower(auth.jwt()->>'email'))
    )
    -- أو مشاركة المجال التابع له المشروع
    or exists (
      select 1 from public.entity_shares es
      where es.entity_type = 'area' and es.entity_id = projects.area_id
        and es.status = 'active' and es.deleted_at is null
        and (es.collaborator_id = auth.uid() or lower(es.collaborator_email) = lower(auth.jwt()->>'email'))
    )
  );

-- 2) مهام المشروع المشترك أو المجال المشترك (Tasks inherit Project & Area shares)
drop policy if exists "tasks_select_collaborator" on public.tasks;
create policy "tasks_select_collaborator" on public.tasks
  for select using (
    -- مشاركة المهمة مباشرة
    exists (
      select 1 from public.entity_shares es
      where es.entity_type = 'task' and es.entity_id = tasks.id
        and es.status = 'active' and es.deleted_at is null
        and (es.collaborator_id = auth.uid() or lower(es.collaborator_email) = lower(auth.jwt()->>'email'))
    )
    -- أو مشاركة المشروع التابعة له المهمة
    or exists (
      select 1 from public.entity_shares es
      where es.entity_type = 'project' and es.entity_id = tasks.project_id
        and es.status = 'active' and es.deleted_at is null
        and (es.collaborator_id = auth.uid() or lower(es.collaborator_email) = lower(auth.jwt()->>'email'))
    )
    -- أو مشاركة المجال التابعة له المهمة (سواء عبر area_id مباشرة أو عبر مشروعها)
    or exists (
      select 1 from public.entity_shares es
      where es.entity_type = 'area' and (es.entity_id = tasks.area_id or es.entity_id in (select p.area_id from public.projects p where p.id = tasks.project_id))
        and es.status = 'active' and es.deleted_at is null
        and (es.collaborator_id = auth.uid() or lower(es.collaborator_email) = lower(auth.jwt()->>'email'))
    )
  );

-- 3) تعديل المهام (Update) لورثة الصلاحية
drop policy if exists "tasks_update_collaborator" on public.tasks;
create policy "tasks_update_collaborator" on public.tasks
  for update using (
    exists (
      select 1 from public.entity_shares es
      where es.status = 'active' and es.deleted_at is null
        and es.permission_level in ('editor', 'admin')
        and (es.collaborator_id = auth.uid() or lower(es.collaborator_email) = lower(auth.jwt()->>'email'))
        and (
          (es.entity_type = 'task' and es.entity_id = tasks.id)
          or (es.entity_type = 'project' and es.entity_id = tasks.project_id)
          or (es.entity_type = 'area' and (es.entity_id = tasks.area_id or es.entity_id in (select p.area_id from public.projects p where p.id = tasks.project_id)))
        )
    )
  );

-- 4) المهام الفرعية (Subtasks inherit Task/Project/Area)
drop policy if exists "subtasks_select_collaborator" on public.subtasks;
create policy "subtasks_select_collaborator" on public.subtasks
  for select using (
    exists (
      select 1 from public.tasks t
      where t.id = subtasks.task_id
        and (
          -- عبر مهمة موروثة أو مباشرة
          exists (
            select 1 from public.entity_shares es
            where es.status = 'active' and es.deleted_at is null
              and (es.collaborator_id = auth.uid() or lower(es.collaborator_email) = lower(auth.jwt()->>'email'))
              and (
                (es.entity_type = 'task' and es.entity_id = t.id)
                or (es.entity_type = 'project' and es.entity_id = t.project_id)
                or (es.entity_type = 'area' and (es.entity_id = t.area_id or es.entity_id in (select p.area_id from public.projects p where p.id = t.project_id)))
              )
          )
        )
    )
  );