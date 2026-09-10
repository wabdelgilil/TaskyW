-- Tasky 3.0 - Supabase: إعدادات المستخدم (User Settings) سطر واحد لكل مستخدم
-- على مشروع yjcpevqahefzcpbvajcq فقط. لا يُنفذ أبداً على pioxojsrrewskptxezll.

-- إعدادات التطبيق تُحفظ سحابياً لكل مستخدم (user_id مفتاح أساسي) بحيث تكون
-- الخيارات (اللغة / الاتجاه / الثيم / العملة / الإشعارات...) مفتكرة عبر الأجهزة.
create table if not exists public.user_settings (
  user_id                    uuid primary key references auth.users (id) on delete cascade,
  notifications_enabled      boolean not null default true,
  default_reminder_minutes   integer not null default 15,
  default_currency           text not null default 'SAR',
  default_view_mode          text not null default 'list',
  theme_mode                 text not null default 'light',
  language_code              text not null default 'system',
  layout_direction           text not null default 'ltr',
  updated_at                 text not null
);

alter table public.user_settings enable row level security;

-- سياسات الوصول: كل مستخدم يرى ويعدّل سطره فقط.
create policy "user_settings_select_own" on public.user_settings
  for select using (user_id = auth.uid());
create policy "user_settings_insert_own" on public.user_settings
  for insert with check (user_id = auth.uid());
create policy "user_settings_update_own" on public.user_settings
  for update using (user_id = auth.uid());
create policy "user_settings_delete_own" on public.user_settings
  for delete using (user_id = auth.uid());