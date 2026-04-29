#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS = ROOT / 'docs' / 'supabase' / 'migrations'

REQUIRED_004 = [
    'CREATE TABLE IF NOT EXISTS public.user_profiles',
    'CREATE TABLE IF NOT EXISTS public.user_sync_state',
    'CREATE TABLE IF NOT EXISTS public.user_vocab_progress',
    'CREATE TABLE IF NOT EXISTS public.user_grammar_progress',
    'CREATE TABLE IF NOT EXISTS public.user_character_progress',
    'CREATE TABLE IF NOT EXISTS public.user_conversation_progress',
    'CREATE TABLE IF NOT EXISTS public.user_learning_unit_progress',
    'CREATE TABLE IF NOT EXISTS public.user_srs_cards',
    'CREATE TABLE IF NOT EXISTS public.user_srs_review_logs',
    'ALTER TABLE public.user_srs_cards ENABLE ROW LEVEL SECURITY',
    'CREATE POLICY "own srs cards"',
    'idx_user_srs_cards_user_due',
]

REQUIRED_005 = [
    'ALTER COLUMN current_hsk_level SET DEFAULT 2',
    'ADD COLUMN IF NOT EXISTS active_stage_id',
    'ADD COLUMN IF NOT EXISTS canonical_key',
    'ADD COLUMN IF NOT EXISTS attempt_count',
    'user_srs_cards_card_type_check',
    'idx_user_srs_cards_user_target_card_type_unique',
    'ADD COLUMN IF NOT EXISTS client_review_id',
    'idx_user_srs_review_logs_user_client_review_unique',
    'set_review_log_server_created_at',
]


def assert_contains(path: Path, needles: list[str]) -> list[str]:
    text = path.read_text(encoding='utf-8')
    return [needle for needle in needles if needle not in text]


def main() -> None:
    failures = []
    for filename, needles in {
        '004_database_v2.sql': REQUIRED_004,
        '005_learning_engine_production.sql': REQUIRED_005,
    }.items():
        path = MIGRATIONS / filename
        if not path.exists():
            failures.append(f'missing migration: {filename}')
            continue
        missing = assert_contains(path, needles)
        failures.extend(f'{filename}: missing `{needle}`' for needle in missing)

    if failures:
        print('\n'.join(failures))
        raise SystemExit(1)
    print('Supabase migrations check passed.')


if __name__ == '__main__':
    main()
