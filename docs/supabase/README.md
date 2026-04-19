# Supabase Setup

## Kiến trúc

Hanzify là app **offline-first**: local Drift DB là source of truth. Supabase chỉ dùng để:
1. **Auth** (Phase 1 ✅) — login/signup, email/password
2. **Sync SRS progress** (Phase 2-3) — user_vocab_progress table

**Không sync** vocab content (hanzi/pinyin/meanings) — data tĩnh từ JSON asset, mọi device có bản local giống nhau.

---

## Migrations

Thư mục `migrations/` chứa SQL scripts theo thứ tự. Chạy từng file trên **Supabase Dashboard → SQL Editor** hoặc qua `psql`/Supabase CLI.

| File | Phase | Mô tả |
|---|---|---|
| `001_user_vocab_progress.sql` | 2 | Bảng SRS progress + RLS + trigger updated_at |

---

## Cách apply migration (Dashboard)

1. Mở Supabase Dashboard → project → **SQL Editor** → **New query**
2. Copy toàn bộ nội dung file `.sql` vào
3. Click **Run** (hoặc `Ctrl+Enter`)
4. Verify ở tab **Table Editor** — bảng `user_vocab_progress` đã xuất hiện với 11 cột
5. Verify ở **Authentication → Policies** — 4 policies cho `user_vocab_progress`

## Cách apply (Supabase CLI)

```bash
# Link project (chỉ 1 lần)
supabase link --project-ref <your-project-ref>

# Apply
supabase db push migrations/001_user_vocab_progress.sql
```

---

## Verify sau khi apply

Chạy test query trong SQL Editor:

```sql
-- 1. Table exists với đúng columns
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'user_vocab_progress'
ORDER BY ordinal_position;

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

-- 4. Trigger exists
SELECT trigger_name, event_manipulation
FROM information_schema.triggers
WHERE event_object_table = 'user_vocab_progress';
-- Kỳ vọng: trg_user_vocab_progress_updated_at, BEFORE UPDATE
```

---

## Schema reference

### `user_vocab_progress`

| Column | Type | Default | Notes |
|---|---|---|---|
| `id` | uuid | gen_random_uuid() | PK |
| `user_id` | uuid | — | FK → auth.users.id, CASCADE DELETE |
| `vocab_id` | text | — | Khớp `Vocab.id` trong JSON seed data |
| `repetitions` | int | 0 | SM-2 — số lần review thành công |
| `ease_factor` | float8 | 2.5 | SM-2 — ease factor (1.3 → 2.5+) |
| `interval` | int | 0 | SM-2 — days đến review tiếp theo |
| `next_review` | timestamptz | null | Ngày due tiếp theo |
| `is_bookmarked` | boolean | false | User đánh dấu |
| `is_mastered` | boolean | false | User đánh dấu đã thuộc |
| `updated_at` | timestamptz | now() | Auto-update qua trigger, dùng cho LWW sync |

**Unique constraint:** `(user_id, vocab_id)` — mỗi user chỉ có 1 record per vocab.

**RLS:** User chỉ select/insert/update/delete record có `user_id = auth.uid()`.

---

## Next: Phase 3 — Sync Engine

Sau khi schema đã được apply thành công:
1. Tạo DTO `UserVocabProgressDto` trong `lib/features/vocab/data/models/`
2. Tạo `VocabRemoteDataSource` wrapping Supabase client
3. Implement `SyncService` với pushPendingChanges/pullUserProgress
4. Thêm `needsSync` / `lastSyncAt` vào local Drift schema (v8 → v9)
5. Wire `connectivity_plus` để trigger sync khi online

Chi tiết trong memory `project_supabase_plan.md`.
