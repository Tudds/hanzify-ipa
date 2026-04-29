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
