-- ترحيل جدول العمليات المالية والتسويات والفواتير المعلقة (Financial Records & Cross-Account Settlements)
-- ملاحظة: محمي بـ RLS لمالك الصف فقط

CREATE TABLE IF NOT EXISTS public.financial_records (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL DEFAULT auth.uid(),
    type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    currency TEXT NOT NULL DEFAULT 'EGP',
    title TEXT NOT NULL,
    category TEXT,
    status TEXT NOT NULL DEFAULT 'completed',
    from_account TEXT,
    to_account TEXT,
    settlement_type TEXT NOT NULL DEFAULT 'none',
    settlement_status TEXT NOT NULL DEFAULT 'none',
    area_id TEXT,
    transaction_date TIMESTAMPTZ NOT NULL,
    notes TEXT,
    sync_status TEXT NOT NULL DEFAULT 'synced',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_financial_records_user ON public.financial_records (user_id);
CREATE INDEX IF NOT EXISTS idx_financial_records_status ON public.financial_records (status);
CREATE INDEX IF NOT EXISTS idx_financial_records_settlement ON public.financial_records (settlement_type, settlement_status);
CREATE INDEX IF NOT EXISTS idx_financial_records_date ON public.financial_records (transaction_date);
CREATE INDEX IF NOT EXISTS idx_financial_records_deleted ON public.financial_records (deleted_at);

ALTER TABLE public.financial_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own financial records"
    ON public.financial_records FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own financial records"
    ON public.financial_records FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own financial records"
    ON public.financial_records FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own financial records"
    ON public.financial_records FOR DELETE
    USING (auth.uid() = user_id);
