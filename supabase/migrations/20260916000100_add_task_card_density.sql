-- إضافة عمود كثافة كروت المهام إلى إعدادات المستخدم
ALTER TABLE public.user_settings
ADD COLUMN IF NOT EXISTS task_card_density TEXT NOT NULL DEFAULT 'comfortable';
