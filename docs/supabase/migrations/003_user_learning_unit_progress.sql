-- Migration 003: user_learning_unit_progress
-- Luu progress learning path (lesson/checkpoint) cua tung user.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.user_learning_unit_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  unit_id text NOT NULL,
  unit_kind text NOT NULL CHECK (unit_kind IN ('lesson', 'checkpoint')),
  module_id text NOT NULL,
  stage_id text NOT NULL,
  started_at timestamptz NULL,
  completed_at timestamptz NULL,
  last_opened_at timestamptz NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, unit_id)
);

CREATE INDEX IF NOT EXISTS idx_user_learning_progress_user_updated
  ON public.user_learning_unit_progress (user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_learning_progress_user_stage
  ON public.user_learning_unit_progress (user_id, stage_id);
CREATE INDEX IF NOT EXISTS idx_user_learning_progress_user_module
  ON public.user_learning_unit_progress (user_id, module_id);

CREATE OR REPLACE FUNCTION public.set_learning_progress_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_learning_unit_progress_updated_at
  ON public.user_learning_unit_progress;

CREATE TRIGGER trg_user_learning_unit_progress_updated_at
  BEFORE UPDATE ON public.user_learning_unit_progress
  FOR EACH ROW
  EXECUTE FUNCTION public.set_learning_progress_updated_at();

ALTER TABLE public.user_learning_unit_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own learning progress — select" ON public.user_learning_unit_progress;
DROP POLICY IF EXISTS "own learning progress — insert" ON public.user_learning_unit_progress;
DROP POLICY IF EXISTS "own learning progress — update" ON public.user_learning_unit_progress;
DROP POLICY IF EXISTS "own learning progress — delete" ON public.user_learning_unit_progress;

CREATE POLICY "own learning progress — select"
  ON public.user_learning_unit_progress
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "own learning progress — insert"
  ON public.user_learning_unit_progress
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own learning progress — update"
  ON public.user_learning_unit_progress
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own learning progress — delete"
  ON public.user_learning_unit_progress
  FOR DELETE
  USING (auth.uid() = user_id);
