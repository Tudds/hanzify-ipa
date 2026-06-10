# Hanzify Code Map

Bản đồ nhanh để đọc codebase. Cập nhật 2026-05-18.

---

## 1. Boot flow

```
lib/main.dart
  └─ runApp(ProviderScope(HanzifyApp))
      └─ lib/app/hanzify_app.dart
          └─ lib/app/app_router.dart
              └─ lib/core/widgets/root_scaffold.dart  ── 5-tab IndexedStack
                  ├─ ShortsFeedScreen  (tab 0, `/`)
                  ├─ DictionaryScreen  (tab 1, `/dictionary`)
                  ├─ QuizScreen        (tab 2, `/quiz`)
                  ├─ ChatScreen        (tab 3, `/chat`)
                  └─ DueReviewScreen   (tab 4, `/review`)
```

Khởi tạo phụ trong `main()`:
- Supabase chỉ init khi `SupabaseConfig.isConfigured`, tức là có `SUPABASE_URL` và `SUPABASE_ANON_KEY` qua `--dart-define`.
- Khi Supabase đã init và có auth user, `LearningSyncTrigger` sync local progress/SRS với Supabase khi auth state đổi.
- Bottom nav dùng `BottomTabBarWidget`, ẩn/hiện qua `navVisibilityProvider`.

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

---

## 5. Shorts

```
ShortsFeedScreen
  → ShortsFeedRepository.loadHskFeed(...)
  → ShortsSessionBuilder.build(...)
  → PageView of ShortCard
  → ShortQuizView / ShortVocabContextView / ShortGrammarContextView / ShortDialogueView
```

Shorts CTAs open dictionary detail sheets via `features/dictionary` repository/widgets.

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
- `SuggestionActionsBlock`

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
