# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hanzify is a Flutter app for learning Chinese (HSK1–HSK4 vocabulary, characters, grammar). Web-first (Flutter Web WASM); also runs on Android, iOS, and Desktop. Offline-first: JSON seed data → local Drift/SQLite. Vietnamese is the primary UI language.

The app is organized around **5 tabs**: `Shorts`, `Từ điển` (Dictionary), `Quiz`, `Chat` (local GenUI), and `Ôn tập` (FSRS review).

> For a deeper, file-level map of the codebase, see `docs/code_map.md`. Keep it in sync when structure changes.

## Build & Development Commands

```bash
flutter pub get                                              # Install dependencies
dart run build_runner build --delete-conflicting-outputs    # Generate .g.dart files (Drift)
dart run build_runner watch                                  # Watch mode for code generation
flutter analyze                                              # Lint check
flutter test                                                # Run test suite
flutter run -d chrome                                        # Run on web
flutter build web                                            # Build for web (JS); WASM dry-run runs automatically
flutter build web --wasm                                     # Build for web (WASM)
flutter build apk                                            # Build for Android
```

**After modifying any file with `part '*.g.dart'`** (Drift tables), re-run build_runner.

## Architecture

**Feature-based, layered:**
```
lib/app/            — MaterialApp.router shell + GoRouter (hanzify_app.dart, app_router.dart)
lib/core/           — shared infra: audio, config, constants, database, learning, learning_path,
                      motion, providers, sync, theme, utils, widgets
lib/features/
  shorts/           — vertical Shorts learning feed (vocab/grammar/dialogue/quiz cards + remediation)
  dictionary/       — vocab/grammar search + detail sheets (the "library")
  quiz/             — quiz launcher + drills (multiple choice, flashcard, cloze, word match, sentence arrange)
  chat/             — local GenUI chat (renders UI blocks; no remote LLM wired yet)
  review_session/   — FSRS due-card review tab + reusable review panel
  character/        — Hanzi stroke-order widget used by dictionary detail sheets
lib/main.dart       — bootstrap (URL strategy, optional Supabase init, runApp)
```

A feature may have `data/`, `domain/`, `application/`, `presentation/` — not all four are required.

**No usecase layer.** Providers/controllers call repositories directly. Pure domain algorithms (e.g. FSRS in `lib/core/learning/domain/fsrs.dart`) are plain functions/classes.

**Core learning engine** lives in `lib/core/learning/`:
- `domain/` — pure models: collocation, dialogue_scene, fsrs, lesson_context
- `application/` — quiz generation, sentence generation, session builder/controller
- `data/` — JSON repositories, SRS serialization, web/native study-session stores
- barrel files at the root re-export for compatibility

## Navigation

Uses **GoRouter** (`lib/app/app_router.dart`). The 5 tabs are an `AppTab` enum in `lib/core/providers/tab_provider.dart` (path/order/labels). They live under a single **`StatefulShellRoute`** (one branch per tab) so the shell + bottom bar are built **once** — no rebuild/animation replay on tab switch. The shell's `navigatorContainerBuilder` returns `RootScaffold` (`lib/core/widgets/root_scaffold.dart`), which hosts the branch navigators in a **horizontal `PageView`** (swipe between tabs, content follows finger) with a floating `BottomTabBarWidget`. Tabs are lazily built on first visit then kept alive (`_activated` gate + `AutomaticKeepAliveClientMixin`), preserving the deferred-chunk loading. Bottom-bar taps / swipes both drive `navigationShell.goBranch`; the bottom bar shows the active tab as an icon+label pill and inactive tabs as icon-only. The bottom nav auto-hides on **vertical** content scroll via `navVisibilityProvider`.

Routes: `/` (shorts), `/dictionary`, `/quiz`, `/chat`, `/review`.

## State Management (Riverpod)

- Riverpod v3 (`flutter_riverpod`). Long-lived providers use `keepAlive`.
- Entity equality uses `Equatable`, never Freezed.

**Key core providers:**
| Provider | Location | Purpose |
|---|---|---|
| `AppTab` enum | `core/providers/tab_provider.dart` | Tab order + route paths (active tab is owned by the shell's `StatefulNavigationShell`) |
| `navVisibilityProvider` | `core/providers/nav_visibility_provider.dart` | Tab bar show/hide on scroll |
| `performanceProvider` | `core/providers/performance_provider.dart` | Disable heavy animations/blur, persisted |
| `dialogueSceneProvider` | `core/providers/dialogue_scene_provider.dart` | Dialogue scenes for chat/shorts |
| `quizPoolProvider` | `features/quiz/application/quiz_pool.dart` | Vocab pool for quiz drills (from dictionary library) |
| `vocabLibraryProvider` / `grammarLibraryProvider` | `features/dictionary/application/library_state.dart` | Loaded vocab/grammar from `libraryRepositoryProvider` |

## Database (Drift)

`lib/core/database/`. The connection is selected via conditional export in `database_connection.dart`: `database_connection_web.dart` (WASM sqlite) on web, `database_connection_io.dart` on native (`if (dart.library.io)`). `app_database_stub.dart` exists for platforms without a real DB.

Schema version is managed manually in `app_database.dart`. Complex columns use custom `TypeConverter` subclasses. When adding new JSON data files, update the relevant seed lists in the database layer.

Pinyin normalization (strip tone marks + whitespace) lives in `lib/core/utils/` — keep it in one place.

## Sync (optional)

`lib/core/sync/`. Supabase is only initialized when `SupabaseConfig.isConfigured` (i.e. `SUPABASE_URL` + `SUPABASE_ANON_KEY` passed via `--dart-define`). When configured and a user is signed in, `LearningSyncTrigger` debounces and `LearningSyncService` pulls remote → merges → pushes local progress/SRS on auth-state changes. Without those defines, the app runs fully local-only — there is no login/guest gate on the UI.

## Web vs Native Conditional Import Pattern

Selected via `if (dart.library.io)` conditional import. The main one is the database connection (`database_connection.dart` → web/io variants). Follow this same pattern if adding platform-specific implementations.

## Content / Assets

`assets/data/`: `hsk{1..4}.json`, `char_hsk{1..4}.json`, `grammar_hsk{1..4}.json`, `conversation.json`, plus `learning_path/`, `graph/`, `generated/` (LLM-generated collocations, sentence frames, quality rules), and `shorts/`. Audio is served as MP3 (TTS pipeline; see `docs/audio_setup.md`).

Content/data generation scripts live in `tool/`. Normal feature work should **not** hand-edit `assets/data/generated/` unless the task is explicitly content/data maintenance.

## Design System

Theo skill **`.claude/skills/flutter-ui`** (Premium Dark, M3 seed-based). `AppTheme.dark` / `AppTheme.light` trong `lib/core/theme/app_theme.dart` đều sinh từ `ColorScheme.fromSeed(kSeedColor, DynamicSchemeVariant.fidelity)`. Mặc định dark (`themeModeProvider`, persisted); light đã build sẵn nhưng chưa expose cho user đến khi audit xong từng màn hình.
- `colors.dart` — `kSeedColor` (Royal Purple 0xFF7C5CFF) + `AppSemanticColors` ThemeExtension (success/warning/danger, dark+light). KHÔNG còn class AppColors.
- `typography.dart` — `AppSpacing` (thang 4pt), `AppRadii` (chip 8 / button 12 / card 16 / sheet 24), `AppTypography` (type scale + `hanziDisplay`/`pinyin`). Default UI font là **Inter** (self-host subset, đủ glyph Việt + pinyin — không dùng google_fonts vì COEP); Hanzi dùng Noto Serif/Sans SC cục bộ.
- Đọc token qua extension `UITokens` (`app_theme.dart`): `context.colors.*`, `context.text.*`, `context.semantic.success/warning/danger`. Không hardcode hex/`Colors.white/black` cho content (shadow/scrim đen được phép).

**Performance mode**: when `performanceProvider == true`, disable `BackdropFilter`, heavy `flutter_animate` effects, and blur. Animated widgets must check it (`readPerformance(ref)`) before applying expensive effects.

Motion uses `flutter_animate` (short entrance/micro-interaction timings) and `lib/core/motion/`. Rive was removed in favor of Flutter-native motion.

**Shared widgets** (`lib/core/widgets/`): `root_scaffold.dart`, `bottom_tab_bar_widget.dart`, `sliver_page_scaffold.dart` (shared native-sliver scaffold for Dictionary/Quiz/Chat/Review; Shorts keeps its own vertical `PageView`), and `learning/` (e.g. `quiz_victory_celebration.dart`).

## Key Conventions

- `analysis_options.yaml` excludes `**/*.g.dart` and `**/*.freezed.dart` from analysis. Use `.withValues(alpha: x)` (not the deprecated `.withOpacity`).
- Haptic feedback via `HanzifyHaptic` utility (`lib/core/widgets/hanzify_haptic.dart`).
- Color tokens come from `AppColors` / the `ColorScheme` — never hardcode hex in feature code.
- Widget tests live under `test/features/` and `test/core/`; assert against the actual Vietnamese UI strings (they are the contract). `flutter test` should stay green.
