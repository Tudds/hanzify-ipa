-- ============================================================================
-- Migration 002: user_grammar_progress
-- Lưu bookmark/mastered progress của từng user cho grammar points.
-- Offline-first: local Drift DB là source of truth, bảng này chỉ để sync.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.user_grammar_progress (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id       uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  grammar_id    text        NOT NULL,
  is_bookmarked boolean     NOT NULL DEFAULT false,
  is_mastered   boolean     NOT NULL DEFAULT false,
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, grammar_id)
);

-- Index để sync delta (chỉ pull record thay đổi sau lần sync trước)
CREATE INDEX IF NOT EXISTS idx_user_grammar_progress_user_updated
  ON public.user_grammar_progress (user_id, updated_at DESC);

-- ============================================================================
-- Auto-update `updated_at` on UPDATE — cần thiết cho Last-Write-Wins sync
-- ============================================================================
DROP TRIGGER IF EXISTS trg_user_grammar_progress_updated_at
  ON public.user_grammar_progress;

CREATE TRIGGER trg_user_grammar_progress_updated_at
  BEFORE UPDATE ON public.user_grammar_progress
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- ============================================================================
-- Row Level Security — user chỉ thấy/sửa data của chính mình
-- ============================================================================
ALTER TABLE public.user_grammar_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own grammar progress — select" ON public.user_grammar_progress;
DROP POLICY IF EXISTS "own grammar progress — insert" ON public.user_grammar_progress;
DROP POLICY IF EXISTS "own grammar progress — update" ON public.user_grammar_progress;
DROP POLICY IF EXISTS "own grammar progress — delete" ON public.user_grammar_progress;

CREATE POLICY "own grammar progress — select"
  ON public.user_grammar_progress
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "own grammar progress — insert"
  ON public.user_grammar_progress
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own grammar progress — update"
  ON public.user_grammar_progress
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own grammar progress — delete"
  ON public.user_grammar_progress
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- Grants (chỉ cho role authenticated, không cho anon)
-- ============================================================================
GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.user_grammar_progress
  TO authenticated;
