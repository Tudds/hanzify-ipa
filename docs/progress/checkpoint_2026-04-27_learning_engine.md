# Checkpoint — Learning Engine

Ngày lưu: 2026-04-28

## Snapshot hiện tại

Vertical slice offline đã chạy được:

```text
Home Dashboard → Learning Path → Lesson/Checkpoint Intro → Quiz → FSRS → Drift/sqlite → Review due cards → Remediation grouped retry → Recap/Reward
```

Mức hoàn thành ước tính phần learning engine offline: **88-91%**.

## Đã xong, không cần làm lại

### Data & QA

- Thuật toán học production HSK1-HSK4 đã chốt trong `docs/thuattoan.md`.
- Runtime generate on-demand từ `collocations_db.json` + `frames_bank.json`.
- Collocation pool HSK1-HSK4 đã có **4104 items**.
- HSK3 conversation đã tăng lên **11 hội thoại**.
- `vi_short` và `slot_compatibility` đã curate lô ưu tiên.
- Production content QA pass: `docs/progress/production_content_qa_2026-04-27.md` = **0 errors / 0 warnings**.

### Core learning

- FSRS scheduler, SRS card/log, session controller đã có.
- Quiz answer tạo/update SRS card và review log.
- Lesson/checkpoint dùng `LessonContext` để filter theo level, conversation, grammar.
- Continue resolver ưu tiên: due review → lesson tiếp theo → checkpoint.
- Remediation đã có retry riêng các câu sai.
- Remediation đã group câu sai theo target vocab/grammar và gợi ý học lại theo lỗi.
- `LearningQuiz` đã carry `targetGrammarIds` để trace lỗi grammar từ generated collocation.

### Persistence

- Runtime đã swap sang **Drift + sqlite3**.
- Native/mobile/desktop dùng `hanzify.sqlite`.
- Web dùng `sqlite3.wasm` + `drift_worker.dart.js`.
- `StudySessionStore` và `LearningProgressStore` giữ API cũ, ưu tiên Drift, fallback SharedPreferences cho test/dev thiếu sqlite runtime.
- Code mới nên **không cần migration tiến độ cũ**.

### UI / Riverpod

- App root đã wrap `ProviderScope`.
- App home hiện là `HomeDashboardScreen`.
- Dashboard đã có due reviews, SRS cards, completed units, streak, mục tiêu ngày và progress bar.
- `GameWorldScreen` dùng Riverpod controller.
- `LearningPathScreen` đã Riverpod-backed qua `learningPathViewStateProvider`.
- `DueReviewScreen` đã Riverpod-backed qua `dueReviewSnapshotProvider`.
- Lesson detail UI đã có Goal/Can-do, Conversation context, Key vocab, Key grammar, Practice quiz, Summary.
- Lesson/checkpoint đã có intro trước quiz.
- Completion screen đã có recap sau lesson và reward message khi pass checkpoint.
- Review UI đã hiển thị prompt/answer theo card type, target ID, schedule và gợi ý chấm FSRS.
- UI dùng Material thuần.

## File chính cần nhớ

### UI

- `lib/features/home/presentation/home_dashboard_screen.dart`
- `lib/features/learning_path/presentation/learning_path_screen.dart`
- `lib/features/game_world/presentation/game_world_screen.dart`
- `lib/features/game_world/application/game_session_controller.dart`
- `lib/features/game_world/presentation/widgets/session_status_cards.dart`
- `lib/features/review_session/presentation/due_review_screen.dart`

### Core

- `lib/core/learning/application/study_session_controller.dart`
- `lib/core/learning/domain/fsrs.dart`
- `lib/core/learning/data/study_session_store.dart`
- `lib/core/learning_path/learning_progress_store.dart`
- `lib/core/learning_path/continue_target.dart`
- `lib/core/learning_path/learning_path_unlocks.dart`

### Local DB

- `lib/core/database/app_database.dart`
- `lib/core/database/database_connection.dart`
- `lib/core/database/database_connection_io.dart`
- `lib/core/database/database_connection_web.dart`
- `lib/core/learning/data/drift/drift_study_session_store.dart`
- `lib/core/learning_path/data/drift/drift_learning_progress_store.dart`
- `web/sqlite3.wasm`
- `web/drift_worker.dart`
- `web/drift_worker.dart.js`

## Còn lại cần làm

### P1 — Hoàn thiện trải nghiệm học ✅ xong 2026-04-28

1. **Checkpoint/remediation chi tiết hơn**
   - Group câu sai theo vocab/grammar
   - Gợi ý học lại theo lỗi
   - Retry riêng câu sai vẫn giữ nguyên flow cũ

2. **Lesson intro/reward screen**
   - Intro trước lesson/checkpoint
   - Recap sau lesson pass
   - Reward message khi pass checkpoint

### P2 — Sau UI core / polish

3. **Rive thật**
   - Learning Map
   - Quiz Practice
   - Checkpoint Boss

4. **Supabase sync/auth**
   - Auth UI
   - Sync learning progress
   - Sync SRS cards/logs
   - Profile

## Validation gần nhất

Đã chạy pass:

```bash
flutter analyze
flutter test test/features/game_world_screen_test.dart
```

Kết quả:

- `flutter analyze`: pass, no issues.
- `flutter test test/features/game_world_screen_test.dart`: pass, **2 passed**.
- Validation full gần nhất trước P1 vẫn pass: `flutter test` **24 passed / 2 skipped**, `flutter build web --no-pub` pass.
- Web build từng có warning dry-run WASM từ `rive_common`, không phải lỗi Drift/UI.

## Ghi chú tiếp tục

Nếu tiếp tục ngay, nên bắt đầu bằng:

```text
Polish P2 UI: replace Material placeholder with real Rive scenes for Learning Map, Quiz Practice, and Checkpoint Boss.
```
