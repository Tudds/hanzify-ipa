# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hanzify is a Flutter app for learning Chinese (HSK vocabulary). It supports Web (WASM), Android, iOS, and Desktop platforms. The app uses an offline-first approach with JSON data files seeded into a local database.

## Build & Development Commands

```bash
flutter pub get                          # Install dependencies
dart run build_runner build --delete-conflicting-outputs  # Generate .g.dart files (Drift, Riverpod)
dart run build_runner watch              # Watch mode for code generation
flutter analyze                          # Lint check
flutter build web --wasm                 # Build for web (WASM)
flutter build apk                        # Build for Android
flutter run -d chrome                    # Run on web
flutter run -d <device>                  # Run on device
```

**After modifying any file with `part '*.g.dart'`**, you must re-run build_runner to regenerate code.

## Architecture

**Clean Architecture with feature-based organization:**
- `lib/core/` — shared infrastructure (database, theme, platform, widgets)
- `lib/features/<feature>/data/` — datasources, repositories impl
- `lib/features/<feature>/domain/` — entities, repository interfaces, usecases
- `lib/features/<feature>/presentation/` — screens, widgets, Riverpod providers

**State management:** Riverpod with `@Riverpod(keepAlive: true)` annotation pattern + riverpod_generator for `.g.dart` files.

**Database:** Drift (SQLite ORM) on native platforms only. Web uses an in-memory datasource (`VocabWebDataSourceImpl`).

## Web vs Native Conditional Import Pattern

The app uses `if (dart.library.io)` conditional imports to separate native (Drift/SQLite) from web (in-memory) implementations. Three pairs of files follow this pattern:

| Import site | Web file | Native file |
|---|---|---|
| `main.dart` | `platform_web.dart` | `platform_native.dart` |
| `vocab_providers.dart` | `app_database_stub.dart` | `app_database.dart` |
| `vocab_providers.dart` | `vocab_providers_web.dart` | `vocab_providers_native.dart` |

The `ProviderScope` in each platform file overrides the appropriate providers. On native, `appDatabaseProvider` is overridden with a real `AppDatabase`. On web, `vocabLocalDataSourceProvider` is overridden with `VocabWebDataSourceImpl`.

## Database Seeding

Vocab and character data lives in `assets/data/` as JSON files (hsk1-3.json, char_hsk1-3.json). On native, `AppDatabase` seeds on first creation via `MigrationStrategy.onCreate`. If schema version changes, `onUpgrade` drops and reseeds. The `forceSeed()` method reseeds both vocabs and characters.

When adding new JSON data files, update the file lists in both:
- `app_database.dart` (`_seedVocabs` and `_seedCharacters` methods)
- `vocab_web_datasource_impl.dart` (`_seedFromAssets` method)

## Key Conventions

- Entity equality uses `Equatable` (not Freezed)
- Complex types in Drift use custom `TypeConverter` classes (e.g., `MeaningListConverter`)
- Pinyin normalization strips tone marks and whitespace — single source in `lib/core/utils/pinyin_utils.dart` (imported by `app_database.dart`)
- No usecase layer: providers call repositories directly. Pure domain algorithms (e.g. SM-2 in `lib/features/vocab/domain/review_algorithm.dart`) are top-level functions, not classes.
- Vietnamese is the primary UI language for meanings
- `analysis_options.yaml` excludes `**/*.g.dart` and `**/*.freezed.dart` from analysis
