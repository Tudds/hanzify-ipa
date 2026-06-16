# Hanzify Code Map

Bản đồ nhanh để đọc codebase. Cập nhật 2026-06-11.

---

## 1. Boot flow

```
lib/main.dart
  └─ runApp(ProviderScope(overrides: [sharedPreferencesProvider], HanzifyApp))
      └─ lib/app/hanzify_app.dart
          └─ lib/app/app_router.dart  ── appRouterProvider + onboarding redirect
              ├─ OnboardingScreen (`/onboarding`, lần chạy đầu)
              └─ StatefulShellRoute (5 branches) ─ deferred tab imports sống ở đây
                  └─ lib/core/widgets/root_scaffold.dart  ── 5-tab PageView ngang (vuốt + keepAlive)
                  ├─ ShortsFeedScreen  (tab 0, `/`)
                  ├─ DictionaryScreen  (tab 1, `/dictionary`)
                  ├─ QuizScreen        (tab 2, `/quiz`)
                  ├─ ChatScreen        (tab 3, `/chat`)
                  └─ DueReviewScreen   (tab 4, `/review`)
```

Khởi tạo phụ trong `main()`:
- `SharedPreferences.getInstance()` được await trước `runApp` và override vào `sharedPreferencesProvider` để các provider đọc prefs đồng bộ.
- Supabase chỉ init khi `SupabaseConfig.isConfigured`, tức là có `SUPABASE_URL` và `SUPABASE_ANON_KEY` qua `--dart-define`.
- Khi Supabase đã init và có auth user, `LearningSyncTrigger` sync local progress/SRS với Supabase khi auth state đổi.
- Bottom nav dùng `BottomTabBarWidget`, ẩn/hiện qua `navVisibilityProvider`.

### User profile & onboarding

- `lib/core/profile/user_profile.dart` — `UserProfile {activeLevel, dailyMinutes, priority, onboardingComplete}` + `LearningPriority`; `sessionSize` suy ra từ `dailyMinutes`.
- `lib/core/providers/user_profile_provider.dart` — `Notifier<UserProfile>` đọc/ghi SharedPreferences (keys `profile_*`).
- `lib/features/onboarding/presentation/onboarding_screen.dart` — flow 3 bước (trình độ / thời lượng / ưu tiên); `appRouterProvider` redirect tới đây khi `onboardingComplete == false`.
- Consumers: Shorts loaders (`activeLevel`), `quizLevelProvider` (default level), `DueReviewScreen` (cap phiên theo `sessionSize`).

---

## 2. Top-level tree

```
lib/
├── app/                 ── MaterialApp + GoRouter shell
├── core/                ── shared infra: database, learning, sync, audio, theme, widgets
├── features/            ── feature UI/application folders
│   ├── shorts/          ── active Shorts feed, quiz/remediation flow
│   ├── dictionary/      ── active vocab/grammar search + detail sheets
│   ├── quiz/            ── active quiz launcher + drills
│   ├── chat/            ── active local GenUI chat + responder interface
│   ├── review_session/  ── active due review tab + reusable review panel
│   ├── onboarding/      ── first-run welcome flow (level / daily time / priority)
│   └── character/       ── stroke order widget used by vocab detail sheets
└── main.dart
```

Removed legacy feature UI: `features/home`, `features/hub`, `features/learning_path`, `features/lesson_session`, `features/lookup`, old `features/path`, and old `features/practice`.

Convention: feature có thể có `data/`, `domain/`, `application/`, `presentation/`; không ép đủ 4 layer.

---

## 3. Active UI entry points

```
RootScaffold
  ├─ Tab 0: ShortsFeedScreen
  │    ├─ ShortsFeedRepository loads curated/generated feed items
  │    ├─ ShortsSessionBuilder orders cards and inserts mini tests
  │    └─ ShortsSessionController tracks answers and inserts remediation
  ├─ Tab 1: DictionaryScreen
  │    └─ LibraryView → vocab/grammar cards + detail sheets
  ├─ Tab 2: QuizScreen
  │    └─ Multiple choice, flashcard, cloze, word match, sentence arrange
  ├─ Tab 3: ChatScreen
  │    └─ GenUiChatController → GenUiChatResponder → LocalGenUiChatResponder
  └─ Tab 4: DueReviewScreen
       └─ FSRS due-card review from StudySessionStore
```

Routes are defined by `AppTab.path`: `/`, `/dictionary`, `/quiz`, `/chat`, `/review`.

---

## 4. Shared UI

```
lib/core/widgets/
├── root_scaffold.dart
├── bottom_tab_bar_widget.dart
├── sliver_page_scaffold.dart
└── learning/
```

`SliverPageScaffold` is the shared native-sliver scaffold for Dictionary, Quiz, Chat, and Review. Shorts intentionally keeps its vertical `PageView`.

Motion uses `flutter_animate` with short entrance/micro-interaction timings and `performanceProvider` as a low-motion/performance escape hatch.

### Theme (skill flutter-ui)

- `lib/core/theme/app_theme.dart` — `AppTheme.dark`/`AppTheme.light` từ `ColorScheme.fromSeed(kSeedColor, fidelity)` + `UITokens` context extension (`context.colors/text/semantic/isDark`).
- `lib/core/theme/colors.dart` — `kSeedColor` + `AppSemanticColors` ThemeExtension (fallback theo brightness khi theme không đăng ký extension — test pump MaterialApp trần vẫn chạy).
- `lib/core/providers/theme_mode_provider.dart` — `themeModeProvider` persisted (key `theme_mode`), default dark.
- Font UI: Inter self-host subset (đủ glyph Việt + pinyin tones); Manrope vẫn bundle nhưng không còn là default.

---

## 5. Shorts

```
ShortsFeedScreen
  → ShortsFeedRepository.loadHskFeed(...)        (local HSK + RemoteShortsRepository khi includeRemote)
  → ShortsSessionBuilder.build(...)
  → PageView of ShortCard
  → ShortQuizView / ShortVocabContextView / ShortGrammarContextView
    / ShortDialogueView / ShortSceneView / ShortReaderView
```

Shorts CTAs open dictionary detail sheets via `features/dictionary` repository/widgets.

### Nguồn nội dung "rich" (live, online-only)

- `data/remote_shorts_repository.dart` — `RemoteShortsRepository.fetchRemote()` GET một `manifest.json`
  trên CDN (R2, env `SHORTS_CONTENT_URL`) rồi parse `ShortFeedItem`. Resilient: lỗi/offline/parse hỏng → `[]`
  (feed vẫn build từ HSK offline). Nhận `{items:[...]}` hoặc list trần.
- `ShortsFeedRepository.loadHskFeed(options.includeRemote)` merge remote (lọc theo level). Startup = tắt
  (offline-first/nhanh); `shortsHydratedSessionLoaderProvider` = bật.
- Card type mới trong `domain/short_feed_item.dart`:
  - `dialogue` nâng cấp: `audioUrl` track liền mạch + `startMs/endMs` mỗi dòng → `hasSyncedSubtitles`
    (phụ đề chạy theo audio: `ShortDialogueView` nghe `AudioPlayerService.positionStream`, highlight + auto-scroll).
  - `scene` (`ShortScene`): ảnh + caption Hán + nhãn từ vựng (`ShortSceneView`).
  - `reader` (`ShortReader`, kind `story|article|poem`): văn bản song ngữ + glossary + sub sync tùy chọn
    (`ShortReaderView`).
- Pipeline biên soạn + schema mẫu: `tool/shorts_content/` (`sample_manifest.json` + `README.md`).
  Media (audio/ảnh) host cùng bucket R2 audio → không vướng COEP, không cần proxy.
  Podcast/tin tức bên thứ ba (cần Cloudflare Worker proxy) là phase sau.

---

## 6. Dictionary

```
DictionaryScreen
  → LibraryView
  → libraryRepositoryProvider
  → hsk{1..4}.json + grammar_hsk{1..4}.json
  → VocabDetailSheet / GrammarDetailSheet
```

`VocabDetailSheet` uses `StrokeOrderWidget` for character stroke data when available. Current learning data is primarily HSK1-HSK4.

`libraryFilterProvider` mặc định lọc theo `profile.activeLevel` (dùng đường lazy `vocabLibraryForLevelProvider`); chip "Tất cả" bỏ lọc.

---

## 7. Quiz

```
QuizScreen
  → quizPoolProvider
  → MultipleChoiceDrillScreen
  → FlashcardDrillScreen
  → ClozeDrillScreen
  → WordMatchDrillScreen
  → SentenceArrangeDrillScreen
```

Quiz uses local dictionary assets through `QuizPool`. It does not change FSRS persistence directly.

Level: `quizLevelProvider` persist key `quiz_level` (SharedPreferences), fallback = `profile.activeLevel`. Flashcard drill có chip "HSK n" đổi level ngay trong drill (đồng bộ ngược về `quizLevelProvider`).

---

## 8. Chat GenUI

```
ChatScreen
  → genUiChatControllerProvider
  → GenUiChatResponder
  → LocalGenUiChatResponder
  → LibraryRepository + DialogueSceneRepository
```

Rendered GenUI blocks:
- `ChatBubbleBlock`
- `VocabCardBlock`
- `GrammarCardBlock`
- `QuickQuizBlock`
- `SentenceArrangeBlock`
- `DictationBlock` — luyện nghe-viết / dịch Việt→Trung
- `SuggestionActionsBlock`

### Dictation (nghe viết / dịch)

- `domain/dictation.dart` — `DictationMode {listen, readVi}` + `DictationExercise`.
- `application/dictation_exercise_service.dart` — chọn câu từ collocation pool theo level (listen cần `audioUrl`, nguồn `conversation_line` có audio CDN thật); fallback ví dụ vocab (`vocab/{id}_E0.mp3`). Câu ≤ 16 chữ.
- `presentation/widgets/dictation_block_view.dart` — TextField gõ tự do (IME hệ thống, không validate trong onChanged để an toàn composition trên web); nút Kiểm tra / Gợi ý pinyin / Hiện đáp án; chấm bằng `normalizeHanziAnswer` + `diffHanzi` (`lib/core/utils/hanzi_text_compare.dart`) hiển thị đối chiếu match/wrong/missing/extra.
- Responder intent: "luyện nghe"/"chép chính tả"/"nghe viết" → listen; "luyện dịch"/"dịch việt"/"việt-trung" → readVi (check TRƯỚC quiz vì chứa từ khóa "luyện").
- Greeting chips xếp theo `profile.priority`.

No remote LLM call is wired. `GenUiChatResponder` is the extension point for a future remote responder.

---

## 9. Core learning

```
lib/core/learning/
├── domain/       ── pure models: collocation, dialogue_scene, fsrs, lesson_context
├── application/  ── quiz generation, sentence generation, session builder/controller
├── data/         ── JSON repositories, SRS serialization, web/native stores
└── *.dart        ── barrel exports for compatibility
```

Main active paths:
- Shorts uses vocab/grammar/collocation assets to build feed cards and quiz cards.
- Quiz uses dictionary vocab assets for drill pools.
- Chat uses dictionary/grammar/dialogue assets for local GenUI blocks.
- Review uses `FsrsScheduler`, `StudySessionStore`, and local SRS cards/logs.

FSRS notes:
- `FsrsScheduler` là FSRS v4 (weights mặc định, `_initDifficulty` dạng tuyến tính D0(G) = w4 − (G−3)·w5). `requestRetention` lấy từ `profile.targetRetention` (default 0.9, key `profile_target_retention`, chưa expose UI).
- `SessionBuilder` 70/30 + pause-new + backfill (nguồn thiếu thẻ thì nhường quota); `DueReviewScreen` đưa thẻ đến hạn qua builder với `sessionSize` từ profile.
- Regression pins: `test/core/learning/fsrs_reference_test.dart`; content QA: `test/core/learning/content_conventions_test.dart`; audio CDN spot-check (chạy tay): `tool/check_audio_urls.py`.

### Nguồn tạo thẻ SRS (vòng học khép kín)

- `StudySessionController.recordAnswer({targetType, targetId, cardType='recognition', rating})` — tạo/cập nhật thẻ id `targetType:targetId:cardType` qua FSRS. `answer(LearningQuiz, choice)` gọi nội bộ.
- `application/study_session_recorder.dart` — `StudySessionRecorder.record(...)`: **load snapshot → hydrate → recordAnswer → save** (vì `DriftStudySessionStore.save` full-replace, phải load-merge để không xóa thẻ tab Ôn tập); tuần tự hóa bằng `_lock`. Provider `studySessionRecorderProvider` (scheduler theo `profile.targetRetention`).
- Wired: 5 quiz drill (`_pick`/`_grade`/`_check`/`_onPickVi`, dùng `vocab:{VocabItem.id}:recognition`; flashcard có 4 nút FSRS Quên/Khó/Được/Dễ) + `ShortsSessionController.selectQuizAnswer` (dùng `quiz.targetVocabId`). Đúng=Good, sai=Again. **Thẻ chung theo từ** nên mọi nguồn (Quiz/Shorts/Ôn tập) cùng đẩy một lịch FSRS.

---

## 10. Learning path core status

```
lib/core/learning_path/
├── learning_path_models.dart
├── learning_path_repository.dart
├── learning_path_unlocks.dart
├── learning_progress.dart
├── learning_progress_store.dart
└── continue_target.dart
```

Core learning path data/store logic remains because sync/progress code depends on it. The old learning path feature screen is no longer mounted or present under `lib/features`.

---

## 11. Sync

```
lib/core/sync/
├── learning_sync_models.dart
├── learning_sync_data_source.dart
├── learning_sync_service.dart
└── learning_sync_trigger.dart
```

Sync flow when configured: auth/session event → debounced trigger → pull remote → merge local/remote → push pending records. Without Dart defines for Supabase, sync is inactive and the app runs local-only.

---

## 12. Assets and tools

```
assets/data/
├── hsk{1..4}.json
├── char_hsk{1..4}.json
├── grammar_hsk{1..4}.json
├── conversation.json
├── learning_path/
├── graph/
├── generated/
└── shorts/
```

Content/data scripts live in `tool/`. Normal Flutter feature work should not hand-edit generated data unless the task is explicitly content/data maintenance.
