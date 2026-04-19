# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hanzify is a Flutter app for learning Chinese (HSK vocabulary). Supports Web (WASM), Android, iOS, and Desktop. Offline-first: JSON seed data → local Drift/SQLite (native) or in-memory (web). Vietnamese is the primary UI language.

## Build & Development Commands

```bash
flutter pub get                                              # Install dependencies
dart run build_runner build --delete-conflicting-outputs    # Generate .g.dart files (Drift, Riverpod)
dart run build_runner watch                                  # Watch mode for code generation
flutter analyze                                              # Lint check
flutter run -d chrome                                        # Run on web
flutter run -d <device>                                      # Run on device
flutter build web --wasm                                     # Build for web (WASM)
flutter build apk                                            # Build for Android
flutter build ios --no-codesign                              # Build iOS (unsigned)
```

**After modifying any file with `part '*.g.dart'`**, re-run build_runner.

## Architecture

**Clean Architecture, feature-based:**
```
lib/core/           — shared: database, theme, navigation, platform, widgets, providers, utils
lib/features/
  auth/             — Supabase login/signup + guest mode
  vocab/            — vocabulary list, flashcard (SM-2), quiz
  character/        — Hanzi character detail
  grammar/          — grammar points
  conversation/     — conversation scenarios
  dashboard/        — home screen, progress screen
  profile/          — user profile
```

Each feature layer: `data/` (datasources, repositories) → `domain/` (entities, interfaces) → `presentation/` (screens, providers).

**No usecase layer.** Providers call repositories directly. Pure domain algorithms (SM-2 in `lib/features/vocab/domain/review_algorithm.dart`) are top-level functions, not classes.

## State Management (Riverpod)

- All long-lived providers use `@Riverpod(keepAlive: true)`.
- Code-generated providers: annotate with `@riverpod`/`@Riverpod(keepAlive: true)`, then run `build_runner`. Provider class name → `<ClassName>Provider` / `<ClassName>Notifier`.
- Entity equality uses `Equatable`, never Freezed.
- Async persistent state uses the `AsyncPrefsNotifier<T>` mixin (`lib/core/providers/async_prefs_notifier.dart`). Implement `prefsKey`, `defaultValue`, `fromPrefs()`, `toPrefs()`, `updateState()`. `initAsyncPrefs()` returns default immediately then loads async — no loading spinner. Used by `ThemeNotifier`, `GuestModeNotifier`, `PerformanceNotifier`.

**Key core providers:**
| Provider | Location | Purpose |
|---|---|---|
| `themeProvider` | `core/theme/theme_state.dart` | App theme (light/dark/sepia), persisted |
| `navigationProvider` | `core/providers/navigation_provider.dart` | Screen stack (custom router) |
| `navVisibilityProvider` | `core/providers/nav_visibility_provider.dart` | Tab bar show/hide on scroll |
| `authProvider` | `core/providers/auth_provider.dart` | Supabase auth stream |
| `guestModeProvider` | `core/providers/guest_mode_provider.dart` | Allow use without login, persisted |
| `performanceProvider` | `core/providers/performance_provider.dart` | Disable heavy animations, persisted |
| `appDatabaseProvider` | `core/providers/database_provider.dart` | Drift AppDatabase instance (native only) |

## Navigation

Custom router — no GoRouter or Navigator 2.0. Route constants in `lib/core/navigation/app_routes.dart`.

`NavigationNotifier` maintains a `_history` stack (`List<String>`). Methods: `navigate()`, `goBack()`, `navigateAndReplace()`, `goHome()`, `popUntil()`. Screens are wired in `main.dart`'s `buildScreen()` switch statement. Tab bar auto-hides on scroll via `NotificationListener<UserScrollNotification>`.

## Web vs Native Conditional Import Pattern

Three pairs of files, selected via `if (dart.library.io)` conditional imports:

| Import site | Native file | Web file |
|---|---|---|
| `main.dart` | `platform_native.dart` | `platform_web.dart` |
| `vocab_providers.dart` | `app_database.dart` | `app_database_stub.dart` |
| `vocab_providers.dart` | `vocab_providers_native.dart` | `vocab_providers_web.dart` |

On native, `appDatabaseProvider` is overridden in `ProviderScope` with a real `AppDatabase`. On web, `vocabLocalDataSourceProvider` is overridden with `VocabWebDataSourceImpl` (in-memory).

## Database (Drift)

Native only. Schema version managed manually in `app_database.dart`. `MigrationStrategy.onCreate` seeds all data on first run; `onUpgrade` drops tables and reseeds. `forceSeed()` reseeds both vocabs and characters.

Complex types use custom `TypeConverter` subclasses (e.g., `MeaningListConverter`). When adding new JSON data files, update the seed file lists in both `app_database.dart` (`_seedVocabs`, `_seedCharacters`) and `vocab_web_datasource_impl.dart` (`_seedFromAssets`).

Pinyin normalization (strip tone marks + whitespace) lives only in `lib/core/utils/pinyin_utils.dart`.

## Auth & Guest Mode

`AppRoot` in `main.dart` gates all screens: if no Supabase session **and** `guestModeProvider == false` → shows `AuthScreen`. Guest mode persists across restarts; local progress is preserved and can be synced after login. Guest mode is disabled on explicit logout.

## Design System

**Tokens** in `lib/core/theme/`:
- `typography.dart` — `AppSpacing`, `AppRadii`, `AppFontSizes`, `AppTypography` helper functions
- `colors.dart` — `AppColors` (raw constants) + `AppThemeColors` (semantic tokens for light/dark/sepia)
- `theme_state.dart` — `ThemeNotifier` produces `ThemeData`; exposes `AppThemeExtension` (accessed via `Theme.of(context).extension<AppThemeExtension>()?.colors`)

**Font roles**: Inter/Manrope for Latin UI, Noto Sans SC for Hanzi (UI), Noto Serif SC for Hanzi (display/study card). Pinyin uses Inter w600.

**Performance mode**: `performanceProvider == true` disables `BackdropFilter`, heavy animations, and blur. All animated widgets must check this provider before applying expensive effects.

**Shared widgets** (`lib/core/widgets/`):
- `HanzifyCard` — tap-scale micro-interaction, variants: `solid`/`glass`/`outlined`
- `HanzifyFilterChip` — animated active state, tap scale
- `HanzifyGradientFab` — tap scale, defaults to solid primary (gradient optional)
- `HanzifyScreenHeader` — `SliverAppBar` with expand/collapse, variants: `primary`/`detail`
- `HanzifyAppBar` — `PreferredSizeWidget`, variants: `standard`/`centered`/`backOnly`/`titleOnly`
- `BottomTabBarWidget` — floating pill nav, no BackdropFilter, per-tab tap scale + AnimatedSwitcher icon

## Key Conventions

- `analysis_options.yaml` excludes `**/*.g.dart` and `**/*.freezed.dart` from analysis.
- Haptic feedback via `HanzifyHaptic` utility (wraps `HapticFeedback`).
- Snackbars via `HanzifySnack.success()` / `.error()` (wraps `awesome_snackbar_content`).
- HSK level colors and part-of-speech colors are defined in `AppThemeColors.hskColors` / `.posColors` — always use these, never hardcode.
- `themeColorsOf(context)` helper in `lib/core/theme/app_theme_helper.dart` is the short form of `Theme.of(context).extension<AppThemeExtension>()!.colors`.
