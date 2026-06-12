-- ============================================================================
-- Hanzify — Phase 4: đưa schema remote về v2 hoàn chỉnh (an toàn, additive)
-- Chạy nguyên file này trong Supabase Dashboard → SQL Editor → Run.
-- Gồm: (A) hòa giải 2 bảng v1 trống → đủ cột v2; (B) 004_database_v2;
-- (C) 005_learning_engine_production.
-- ============================================================================

-- (A) Hòa giải bảng v1 (0 rows) — thêm cột v2 còn thiếu, không drop gì.
ALTER TABLE public.user_vocab_progress
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'new',
  ADD COLUMN IF NOT EXISTS last_opened_at timestamptz,
  ADD COLUMN IF NOT EXISTS local_updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS server_updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

ALTER TABLE public.user_grammar_progress
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'new',
  ADD COLUMN IF NOT EXISTS confidence int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS practiced_count int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_practiced_at timestamptz,
  ADD COLUMN IF NOT EXISTS local_updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS server_updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- (B) 004_database_v2.sql
-- ============================================================================
-- Migration 004: database_v2
-- Offline-first user state schema with FSRS-ready SRS cards.
-- Static learning content stays in Flutter JSON assets.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.set_server_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.server_updated_at = now();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS public.user_profiles (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  current_hsk_level int NOT NULL DEFAULT 1 CHECK (current_hsk_level BETWEEN 1 AND 9),
  daily_goal int NOT NULL DEFAULT 20 CHECK (daily_goal > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_sync_state (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  device_id text NOT NULL,
  content_version text,
  content_hash text,
  last_pulled_at timestamptz,
  last_pushed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, device_id)
);

CREATE TABLE IF NOT EXISTS public.user_vocab_progress (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vocab_id text NOT NULL,
  status text NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'learning', 'review', 'mastered')),
  is_bookmarked boolean NOT NULL DEFAULT false,
  is_mastered boolean NOT NULL DEFAULT false,
  last_opened_at timestamptz,
  local_updated_at timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  PRIMARY KEY (user_id, vocab_id)
);

CREATE TABLE IF NOT EXISTS public.user_grammar_progress (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  grammar_id text NOT NULL,
  status text NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'learning', 'review', 'mastered')),
  confidence int NOT NULL DEFAULT 0 CHECK (confidence BETWEEN 0 AND 5),
  practiced_count int NOT NULL DEFAULT 0 CHECK (practiced_count >= 0),
  is_bookmarked boolean NOT NULL DEFAULT false,
  is_mastered boolean NOT NULL DEFAULT false,
  last_practiced_at timestamptz,
  local_updated_at timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  PRIMARY KEY (user_id, grammar_id)
);

CREATE TABLE IF NOT EXISTS public.user_character_progress (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id text NOT NULL,
  recognition_status text NOT NULL DEFAULT 'new' CHECK (recognition_status IN ('new', 'learning', 'review', 'mastered')),
  writing_status text NOT NULL DEFAULT 'new' CHECK (writing_status IN ('new', 'learning', 'review', 'mastered')),
  stroke_practice_count int NOT NULL DEFAULT 0 CHECK (stroke_practice_count >= 0),
  is_bookmarked boolean NOT NULL DEFAULT false,
  is_mastered boolean NOT NULL DEFAULT false,
  last_practiced_at timestamptz,
  local_updated_at timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  PRIMARY KEY (user_id, character_id)
);

CREATE TABLE IF NOT EXISTS public.user_conversation_progress (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id text NOT NULL,
  status text NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'started', 'completed', 'mastered')),
  comprehension_score int CHECK (comprehension_score BETWEEN 0 AND 100),
  speaking_score int CHECK (speaking_score BETWEEN 0 AND 100),
  is_bookmarked boolean NOT NULL DEFAULT false,
  completed_at timestamptz,
  last_opened_at timestamptz,
  local_updated_at timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  PRIMARY KEY (user_id, conversation_id)
);

CREATE TABLE IF NOT EXISTS public.user_learning_unit_progress (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  unit_id text NOT NULL,
  unit_kind text NOT NULL CHECK (unit_kind IN ('lesson', 'checkpoint')),
  stage_id text NOT NULL,
  module_id text NOT NULL,
  status text NOT NULL DEFAULT 'locked' CHECK (status IN ('locked', 'available', 'started', 'completed')),
  score int CHECK (score BETWEEN 0 AND 100),
  started_at timestamptz,
  completed_at timestamptz,
  last_opened_at timestamptz,
  local_updated_at timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  PRIMARY KEY (user_id, unit_id)
);

CREATE TABLE IF NOT EXISTS public.user_srs_cards (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  card_id text NOT NULL,
  target_type text NOT NULL CHECK (target_type IN ('vocab', 'character', 'grammar', 'conversation')),
  target_id text NOT NULL,
  card_type text NOT NULL,
  state text NOT NULL DEFAULT 'new' CHECK (state IN ('new', 'learning', 'review', 'relearning', 'suspended', 'buried')),
  due_at timestamptz,
  stability float8,
  difficulty float8,
  elapsed_days int NOT NULL DEFAULT 0 CHECK (elapsed_days >= 0),
  scheduled_days int NOT NULL DEFAULT 0 CHECK (scheduled_days >= 0),
  reps int NOT NULL DEFAULT 0 CHECK (reps >= 0),
  lapses int NOT NULL DEFAULT 0 CHECK (lapses >= 0),
  last_reviewed_at timestamptz,
  local_updated_at timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  PRIMARY KEY (user_id, card_id)
);

CREATE TABLE IF NOT EXISTS public.user_srs_review_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  card_id text NOT NULL,
  target_type text NOT NULL CHECK (target_type IN ('vocab', 'character', 'grammar', 'conversation')),
  target_id text NOT NULL,
  card_type text NOT NULL,
  rating int NOT NULL CHECK (rating BETWEEN 1 AND 4),
  elapsed_days int NOT NULL DEFAULT 0 CHECK (elapsed_days >= 0),
  scheduled_days int NOT NULL DEFAULT 0 CHECK (scheduled_days >= 0),
  review_duration_ms int CHECK (review_duration_ms >= 0),
  reviewed_at timestamptz NOT NULL DEFAULT now(),
  source text NOT NULL DEFAULT 'unknown',
  algorithm text NOT NULL DEFAULT 'fsrs',
  stability_before float8,
  difficulty_before float8,
  stability_after float8,
  difficulty_after float8
);

CREATE INDEX IF NOT EXISTS idx_user_sync_state_user_updated
  ON public.user_sync_state (user_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_vocab_progress_user_server_updated
  ON public.user_vocab_progress (user_id, server_updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_grammar_progress_user_server_updated
  ON public.user_grammar_progress (user_id, server_updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_character_progress_user_server_updated
  ON public.user_character_progress (user_id, server_updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_conversation_progress_user_server_updated
  ON public.user_conversation_progress (user_id, server_updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_learning_unit_progress_user_server_updated
  ON public.user_learning_unit_progress (user_id, server_updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_learning_unit_progress_user_stage
  ON public.user_learning_unit_progress (user_id, stage_id);
CREATE INDEX IF NOT EXISTS idx_user_learning_unit_progress_user_module
  ON public.user_learning_unit_progress (user_id, module_id);

CREATE INDEX IF NOT EXISTS idx_user_srs_cards_user_due
  ON public.user_srs_cards (user_id, due_at)
  WHERE deleted_at IS NULL AND state IN ('new', 'learning', 'review', 'relearning');
CREATE INDEX IF NOT EXISTS idx_user_srs_cards_user_target
  ON public.user_srs_cards (user_id, target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_user_srs_cards_user_server_updated
  ON public.user_srs_cards (user_id, server_updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_srs_review_logs_user_reviewed
  ON public.user_srs_review_logs (user_id, reviewed_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_srs_review_logs_user_card
  ON public.user_srs_review_logs (user_id, card_id, reviewed_at DESC);

DROP TRIGGER IF EXISTS trg_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER trg_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_user_sync_state_updated_at ON public.user_sync_state;
CREATE TRIGGER trg_user_sync_state_updated_at
  BEFORE UPDATE ON public.user_sync_state
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_user_vocab_progress_server_updated_at ON public.user_vocab_progress;
CREATE TRIGGER trg_user_vocab_progress_server_updated_at
  BEFORE UPDATE ON public.user_vocab_progress
  FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at();

DROP TRIGGER IF EXISTS trg_user_grammar_progress_server_updated_at ON public.user_grammar_progress;
CREATE TRIGGER trg_user_grammar_progress_server_updated_at
  BEFORE UPDATE ON public.user_grammar_progress
  FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at();

DROP TRIGGER IF EXISTS trg_user_character_progress_server_updated_at ON public.user_character_progress;
CREATE TRIGGER trg_user_character_progress_server_updated_at
  BEFORE UPDATE ON public.user_character_progress
  FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at();

DROP TRIGGER IF EXISTS trg_user_conversation_progress_server_updated_at ON public.user_conversation_progress;
CREATE TRIGGER trg_user_conversation_progress_server_updated_at
  BEFORE UPDATE ON public.user_conversation_progress
  FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at();

DROP TRIGGER IF EXISTS trg_user_learning_unit_progress_server_updated_at ON public.user_learning_unit_progress;
CREATE TRIGGER trg_user_learning_unit_progress_server_updated_at
  BEFORE UPDATE ON public.user_learning_unit_progress
  FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at();

DROP TRIGGER IF EXISTS trg_user_srs_cards_server_updated_at ON public.user_srs_cards;
CREATE TRIGGER trg_user_srs_cards_server_updated_at
  BEFORE UPDATE ON public.user_srs_cards
  FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at();

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sync_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_vocab_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_grammar_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_character_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_conversation_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_learning_unit_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_srs_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_srs_review_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own profile" ON public.user_profiles;
CREATE POLICY "own profile" ON public.user_profiles
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own sync state" ON public.user_sync_state;
CREATE POLICY "own sync state" ON public.user_sync_state
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own vocab progress" ON public.user_vocab_progress;
CREATE POLICY "own vocab progress" ON public.user_vocab_progress
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own grammar progress" ON public.user_grammar_progress;
CREATE POLICY "own grammar progress" ON public.user_grammar_progress
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own character progress" ON public.user_character_progress;
CREATE POLICY "own character progress" ON public.user_character_progress
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own conversation progress" ON public.user_conversation_progress;
CREATE POLICY "own conversation progress" ON public.user_conversation_progress
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own learning unit progress" ON public.user_learning_unit_progress;
CREATE POLICY "own learning unit progress" ON public.user_learning_unit_progress
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own srs cards" ON public.user_srs_cards;
CREATE POLICY "own srs cards" ON public.user_srs_cards
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "own srs review logs" ON public.user_srs_review_logs;
CREATE POLICY "own srs review logs" ON public.user_srs_review_logs
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_sync_state TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_vocab_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_grammar_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_character_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_conversation_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_learning_unit_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_srs_cards TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_srs_review_logs TO authenticated;

-- (C) 005_learning_engine_production.sql
-- ============================================================================
-- Migration 005: learning_engine_production
-- Additive production hardening for the current Hanzify learning engine.
-- Base schema: 004_database_v2.sql
-- Static learning content remains in Flutter JSON assets; Supabase stores user state only.
-- ============================================================================

ALTER TABLE public.user_profiles
  ALTER COLUMN current_hsk_level SET DEFAULT 2;

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS active_stage_id text NOT NULL DEFAULT 'HSK2',
  ADD COLUMN IF NOT EXISTS session_size int NOT NULL DEFAULT 20 CHECK (session_size > 0),
  ADD COLUMN IF NOT EXISTS request_retention numeric(4, 3) NOT NULL DEFAULT 0.900 CHECK (request_retention > 0 AND request_retention < 1),
  ADD COLUMN IF NOT EXISTS preferred_locale text NOT NULL DEFAULT 'vi-VN';

ALTER TABLE public.user_sync_state
  ADD COLUMN IF NOT EXISTS app_version text,
  ADD COLUMN IF NOT EXISTS sync_status text NOT NULL DEFAULT 'idle' CHECK (sync_status IN ('idle', 'pulling', 'pushing', 'error')),
  ADD COLUMN IF NOT EXISTS last_error text;

ALTER TABLE public.user_vocab_progress
  ADD COLUMN IF NOT EXISTS canonical_key text,
  ADD COLUMN IF NOT EXISTS hsk_level int CHECK (hsk_level BETWEEN 1 AND 9);

CREATE INDEX IF NOT EXISTS idx_user_vocab_progress_user_canonical_key
  ON public.user_vocab_progress (user_id, canonical_key)
  WHERE canonical_key IS NOT NULL AND deleted_at IS NULL;

ALTER TABLE public.user_learning_unit_progress
  ADD COLUMN IF NOT EXISTS attempt_count int NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  ADD COLUMN IF NOT EXISTS best_score int CHECK (best_score BETWEEN 0 AND 100),
  ADD COLUMN IF NOT EXISTS last_score int CHECK (last_score BETWEEN 0 AND 100);

CREATE INDEX IF NOT EXISTS idx_user_learning_unit_progress_user_status
  ON public.user_learning_unit_progress (user_id, status)
  WHERE deleted_at IS NULL;

ALTER TABLE public.user_srs_cards
  ALTER COLUMN card_type SET DEFAULT 'recognition';

ALTER TABLE public.user_srs_cards
  DROP CONSTRAINT IF EXISTS user_srs_cards_card_type_check;

ALTER TABLE public.user_srs_cards
  ADD CONSTRAINT user_srs_cards_card_type_check
  CHECK (card_type IN (
    'recognition',
    'recall',
    'cloze',
    'grammar_choice',
    'sentence_build',
    'character_recognition',
    'character_writing',
    'conversation_comprehension'
  ));

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_srs_cards_user_target_card_type_unique
  ON public.user_srs_cards (user_id, target_type, target_id, card_type)
  WHERE deleted_at IS NULL;

ALTER TABLE public.user_srs_review_logs
  ALTER COLUMN source SET DEFAULT 'learning_session',
  ALTER COLUMN algorithm SET DEFAULT 'fsrs_local_v1';

ALTER TABLE public.user_srs_review_logs
  ADD COLUMN IF NOT EXISTS client_review_id text,
  ADD COLUMN IF NOT EXISTS local_created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS server_created_at timestamptz NOT NULL DEFAULT now();

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_srs_review_logs_user_client_review_unique
  ON public.user_srs_review_logs (user_id, client_review_id)
  WHERE client_review_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.set_review_log_server_created_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.server_created_at = now();
  RETURN NEW;
END;
$$;

CREATE INDEX IF NOT EXISTS idx_user_srs_review_logs_user_target_reviewed
  ON public.user_srs_review_logs (user_id, target_type, target_id, reviewed_at DESC);

DROP TRIGGER IF EXISTS trg_user_srs_review_logs_server_created_at ON public.user_srs_review_logs;
CREATE TRIGGER trg_user_srs_review_logs_server_created_at
  BEFORE INSERT ON public.user_srs_review_logs
  FOR EACH ROW EXECUTE FUNCTION public.set_review_log_server_created_at();
