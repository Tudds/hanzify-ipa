-- ============================================================================
-- Migration 001: user_vocab_progress
-- Lưu SRS progress của từng user cho từng vocab.
-- Offline-first: local Drift DB là source of truth, bảng này chỉ để sync.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.user_vocab_progress (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id       uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vocab_id      text        NOT NULL,
  repetitions   int         NOT NULL DEFAULT 0,
  ease_factor   float8      NOT NULL DEFAULT 2.5,
  interval      int         NOT NULL DEFAULT 0,
  next_review   timestamptz,
  is_bookmarked boolean     NOT NULL DEFAULT false,
  is_mastered   boolean     NOT NULL DEFAULT false,
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, vocab_id)
);

-- Index để query "due today" nhanh khi pull từ nhiều device
CREATE INDEX IF NOT EXISTS idx_user_vocab_progress_user_next_review
  ON public.user_vocab_progress (user_id, next_review);

-- Index để sync delta (chỉ pull record thay đổi sau lần sync trước)
CREATE INDEX IF NOT EXISTS idx_user_vocab_progress_user_updated
  ON public.user_vocab_progress (user_id, updated_at DESC);

-- ============================================================================
-- Auto-update `updated_at` on UPDATE — cần thiết cho Last-Write-Wins sync
-- ============================================================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_vocab_progress_updated_at
  ON public.user_vocab_progress;

CREATE TRIGGER trg_user_vocab_progress_updated_at
  BEFORE UPDATE ON public.user_vocab_progress
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- ============================================================================
-- Row Level Security — user chỉ thấy/sửa data của chính mình
-- ============================================================================
ALTER TABLE public.user_vocab_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own progress — select" ON public.user_vocab_progress;
DROP POLICY IF EXISTS "own progress — insert" ON public.user_vocab_progress;
DROP POLICY IF EXISTS "own progress — update" ON public.user_vocab_progress;
DROP POLICY IF EXISTS "own progress — delete" ON public.user_vocab_progress;

CREATE POLICY "own progress — select"
  ON public.user_vocab_progress
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "own progress — insert"
  ON public.user_vocab_progress
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own progress — update"
  ON public.user_vocab_progress
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own progress — delete"
  ON public.user_vocab_progress
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- Grants (chỉ cho role authenticated, không cho anon)
-- ============================================================================
GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.user_vocab_progress
  TO authenticated;
