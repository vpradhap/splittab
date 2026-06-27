-- ============================================================
--  SplitTab — Supabase Schema
--  Run this once in: Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- 1. USER DATA TABLE
--    Stores each user's full trips + categories as JSON blobs.
--    One row per user — mirrors what localStorage did, but in the cloud.
CREATE TABLE IF NOT EXISTS public.user_data (
  user_id     UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  trips       JSONB       NOT NULL DEFAULT '[]'::jsonb,
  categories  JSONB       NOT NULL DEFAULT '[]'::jsonb,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. ROW LEVEL SECURITY — each user sees ONLY their own row
ALTER TABLE public.user_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own data"
  ON public.user_data
  FOR ALL
  USING      (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 3. AUTO-CREATE ROW when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_data (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
--  SUPABASE DASHBOARD SETTINGS (do these manually):
--
--  Auth → Providers → Email
--    ✅ Enable email provider
--    ✅ Confirm email (recommended for production)
--       OR uncheck "Confirm email" for instant access during dev
--
--  Auth → URL Configuration
--    Site URL: https://your-domain.com   (or http://localhost for dev)
-- ============================================================
