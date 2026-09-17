-- Tasky 3.0 - Supabase: إضافة إعدادات الذكاء الاصطناعي والمفتاح الشخصي
-- على مشروع yjcpevqahefzcpbvajcq فقط. لا يُنفذ أبداً على pioxojsrrewskptxezll.

ALTER TABLE public.user_settings
ADD COLUMN IF NOT EXISTS gemini_api_key TEXT,
ADD COLUMN IF NOT EXISTS ai_enabled BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN IF NOT EXISTS ai_model TEXT NOT NULL DEFAULT 'gemini-2.5-flash',
ADD COLUMN IF NOT EXISTS ai_voice TEXT NOT NULL DEFAULT 'Puck';
