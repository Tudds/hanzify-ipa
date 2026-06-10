# Repository Guidelines

## Project Structure & Module Organization

Hanzify is a Flutter Web-first learning game using Riverpod, Drift, Supabase, and Flutter-native motion. App code lives in `lib/`: shared infrastructure under `lib/core/`, feature UI/controllers under `lib/features/`, bootstrap under `lib/app/`, and shared widgets/providers under `lib/core/widgets/` and `lib/core/providers/`. Tests mirror source areas in `test/`, especially `test/core/learning/` and `test/core/learning_path/`. Static content lives in `assets/data/`, `assets/data/generated/`, `assets/data/learning_path/`, `assets/data/shorts/`, and `assets/images/`. Product notes and progress logs are in `docs/`; content/data scripts are in `tool/`.

## Build, Test, and Development Commands

- `flutter pub get` — install Dart and Flutter dependencies.
- `flutter run -d chrome` — run the web app locally.
- `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` — run with Supabase enabled.
- `flutter analyze` — run static analysis using `analysis_options.yaml`.
- `flutter test` — run the full test suite.
- `dart run build_runner build --delete-conflicting-outputs` — regenerate Drift/build artifacts when database definitions change.

## Coding Style & Naming Conventions

Follow `package:flutter_lints` from `analysis_options.yaml`. Use `dart format` defaults: two-space indentation, trailing commas where they improve formatting, and idiomatic Flutter widget composition. Name Dart files `snake_case.dart`, classes/widgets `PascalCase`, and methods/variables `camelCase`. Keep changes surgical: do not refactor, reformat, or reorder adjacent code unless required.

## Testing Guidelines

Use `flutter_test` for unit and widget tests. Place tests under the matching `test/` path and name files `*_test.dart`, for example `learning_path_repository_test.dart`. Prefer focused tests before the full suite. For Drift/database changes, include persistence tests when practical.

## Commit & Pull Request Guidelines

Recent history uses short Conventional Commit-style messages such as `feat: present lessons as dialogue story flow`, `fix: simplify lesson start flow`, `chore: update content tooling`, and `docs: add learning engine planning notes`. Keep commits scoped and imperative. Pull requests should include a summary, tests run, linked issues/docs, and screenshots or GIFs for UI changes.

## Security & Configuration Tips

Do not commit real Supabase keys, secrets, generated private audio credentials, or local environment files. Supabase config is passed through Dart defines and read by `lib/core/config/supabase_config.dart`. Keep offline-first behavior intact: local Drift data is the source of truth, while Supabase is for auth and user-state/SRS sync.
