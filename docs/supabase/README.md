# Supabase Setup

## Kiến trúc

Hanzify là app **offline-first**: local Drift DB là source of truth. Supabase chỉ dùng để:
1. **Auth** (Phase 1 ✅) — login/signup, email/password
2. **Sync user state + SRS** — progress tables, `user_srs_cards`, `user_srs_review_logs`

**Không sync** vocab content (hanzi/pinyin/meanings) — data tĩnh từ JSON asset, mọi device có bản local giống nhau.

---

## Migrations

Thư mục `migrations/` chứa SQL scripts theo thứ tự. Chạy từng file trên **Supabase Dashboard → SQL Editor** hoặc qua `psql`/Supabase CLI.

| File | Phase | Mô tả |
|---|---|---|
| `001_user_vocab_progress.sql` | 2 | Bảng SRS progress + RLS + trigger updated_at |
| `002_user_grammar_progress.sql` | 3 | Bảng grammar progress + RLS + trigger updated_at |
| `003_user_learning_unit_progress.sql` | 3 | Bảng learning path progress (lesson/checkpoint) + RLS + trigger updated_at |
| `004_database_v2.sql` | 4 | Schema v2 offline-first: user state, progress tables, FSRS-ready SRS cards/logs |
| `005_learning_engine_production.sql` | 5 | Additive hardening cho learning engine hiện tại: HSK2 default, profile/session fields, canonical vocab key, SRS constraints, idempotent review logs |

> Khuyến nghị cho dự án hiện tại: apply `004_database_v2.sql` trước, rồi apply `005_learning_engine_production.sql`. Các migration `001`-`003` là bản phase cũ và có thể bỏ qua nếu project Supabase chưa có production data.

---

## Database v2 + production hardening

Schema v2 giữ nguyên nguyên tắc **static content ở JSON assets**, Supabase chỉ lưu **user-specific state** để sync nhiều thiết bị. Migration `005` bổ sung các cột/constraint sát learning engine hiện tại mà không sync nội dung tĩnh.

### Bảng chính

| Table | Mục đích |
|---|---|
| `user_profiles` | Hồ sơ học tập cơ bản của user |
| `user_sync_state` | Trạng thái sync theo device + content hash/version |
| `user_vocab_progress` | Bookmark/mastery/trạng thái UI cho từ vựng |
| `user_grammar_progress` | Bookmark/mastery/confidence cho grammar |
| `user_character_progress` | Recognition/writing progress cho chữ Hán |
| `user_conversation_progress` | Tiến độ hội thoại, comprehension/speaking score |
| `user_learning_unit_progress` | Tiến độ lesson/checkpoint trong learning path |
| `user_srs_cards` | Card SRS dùng chung cho vocab/character/grammar/conversation |
| `user_srs_review_logs` | Lịch sử review, FSRS-ready analytics |

### Bổ sung từ migration 005

| Table | Bổ sung |
|---|---|
| `user_profiles` | default `current_hsk_level = 2`, `active_stage_id`, `session_size`, `request_retention`, `preferred_locale` |
| `user_sync_state` | `app_version`, `sync_status`, `last_error` |
| `user_vocab_progress` | `canonical_key`, `hsk_level` để map duplicate vocab xuyên HSK level |
| `user_learning_unit_progress` | `attempt_count`, `best_score`, `last_score` |
| `user_srs_cards` | constraint `card_type` theo app hiện tại: `recognition`, `recall`, `cloze`, `grammar_choice`, `sentence_build`, ... |
| `user_srs_review_logs` | `client_review_id`, `local_created_at`, `server_created_at`, default `algorithm = fsrs_local_v1` |

### Nguyên tắc SRS

- `user_srs_cards` lưu trạng thái hiện tại của card: `state`, `due_at`, `stability`, `difficulty`, `scheduled_days`, `reps`, `lapses`.
- `user_srs_review_logs` lưu mọi lượt review với `rating` từ 1 đến 4: Again, Hard, Good, Easy.
- Progress tables không chứa thuật toán SRS để tránh duplicate logic giữa vocab/character/grammar.
- Có thể implement thuật toán đơn giản ban đầu, nhưng schema đã sẵn sàng cho FSRS.

### Sync fields

- `local_updated_at`: thời điểm device local sửa record.
- `server_updated_at`: thời điểm Supabase nhận update, tự set bằng trigger.
- `deleted_at`: soft delete để sync offline an toàn.

---

## Cách apply schema v2 (Dashboard)

Nếu project Supabase còn mới/chưa có production data, apply trực tiếp `004_database_v2.sql`:

1. Mở Supabase Dashboard → project → **SQL Editor** → **New query**
2. Copy toàn bộ nội dung `docs/supabase/migrations/004_database_v2.sql` vào
3. Click **Run** (hoặc `Ctrl+Enter`)
4. Copy toàn bộ nội dung `docs/supabase/migrations/005_learning_engine_production.sql` vào query mới
5. Click **Run**
6. Verify ở tab **Table Editor** có đủ 9 bảng v2
7. Verify ở **Authentication → Policies** mỗi bảng có policy `own ...`

Nếu đã từng apply `001`-`003`, không chạy `004` như migration nối tiếp trên production vì các bảng cũ cùng tên sẽ không tự đổi schema. Hãy tạo project fresh hoặc viết migration chuyển đổi riêng.

## Cách apply (Supabase CLI)

```bash
# Link project (chỉ 1 lần)
supabase link --project-ref <your-project-ref>

# Apply schema v2 manually from docs/supabase/migrations/004_database_v2.sql
# then apply docs/supabase/migrations/005_learning_engine_production.sql.
# Or copy both into your Supabase CLI migrations folder before db push.
```

---

## Verify sau khi apply

Chạy test query trong SQL Editor:

```sql
-- 1. V2 tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'user_profiles',
    'user_sync_state',
    'user_vocab_progress',
    'user_grammar_progress',
    'user_character_progress',
    'user_conversation_progress',
    'user_learning_unit_progress',
    'user_srs_cards',
    'user_srs_review_logs'
  )
ORDER BY table_name;

-- 2. RLS enabled
SELECT relname, relrowsecurity
FROM pg_class
WHERE relname = 'user_vocab_progress';
-- Kỳ vọng: relrowsecurity = true

-- 3. Policies exist
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'user_vocab_progress';
-- Kỳ vọng: 4 policies (select/insert/update/delete)

-- 4. SRS due index exists
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'user_srs_cards'
  AND indexname = 'idx_user_srs_cards_user_due';

-- 5. Production hardening columns exist
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_profiles'
  AND column_name IN ('active_stage_id', 'session_size', 'request_retention');

-- 6. SRS review idempotency index exists
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'user_srs_review_logs'
  AND indexname = 'idx_user_srs_review_logs_user_client_review_unique';
```

---

## Schema reference

### `user_srs_cards`

| Column group | Notes |
|---|---|
| Identity | `user_id`, `card_id` composite primary key |
| Target | `target_type`, `target_id`, `card_type` map card về vocab/character/grammar/conversation |
| Scheduling | `state`, `due_at`, `stability`, `difficulty`, `elapsed_days`, `scheduled_days` |
| History summary | `reps`, `lapses`, `last_reviewed_at` |
| Sync | `local_updated_at`, `server_updated_at`, `deleted_at` |

### `user_srs_review_logs`

| Column group | Notes |
|---|---|
| Review identity | `id`, `user_id`, `card_id` |
| Target snapshot | `target_type`, `target_id`, `card_type` |
| Rating | `rating` từ 1 đến 4: Again, Hard, Good, Easy |
| Timing | `elapsed_days`, `scheduled_days`, `review_duration_ms`, `reviewed_at` |
| Algorithm trace | `algorithm`, `stability_before`, `difficulty_before`, `stability_after`, `difficulty_after` |

### Progress tables

Các bảng `user_vocab_progress`, `user_grammar_progress`, `user_character_progress`, `user_conversation_progress`, `user_learning_unit_progress` chỉ lưu trạng thái học/UI. Lịch ôn tập nằm trong `user_srs_cards`.

### RLS

Tất cả bảng v2 bật Row Level Security và dùng policy dạng `auth.uid() = user_id`. Role `authenticated` có quyền `SELECT`, `INSERT`, `UPDATE`, `DELETE`; role `anon` không được grant quyền trực tiếp.
