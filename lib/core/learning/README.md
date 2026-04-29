# Learning Core

Clean architecture layout for the offline learning engine.

## Layers

- `domain/`: pure learning entities and rules.
  - `collocation.dart`: normalized sentence/collocation item used by quizzes.
  - `fsrs.dart`: SRS card/log models and local FSRS scheduler.
  - `lesson_context.dart`: lesson-level filter context.
- `application/`: use-case logic that composes domain objects.
  - `quiz_generator.dart`: deterministic quiz generation from collocations.
  - `sentence_generator.dart`: on-demand sentence generation from CollocationsDB + FramesBank.
  - `session_builder.dart`: review/new session mix policy.
  - `study_session_controller.dart`: answer handling and SRS updates.
- `data/`: asset/persistence adapters.
  - `learning_asset_repository.dart`: loads generated assets and exposes session seeds.
  - `srs_serialization.dart`: JSON adapters for SRS models.
  - `study_session_store.dart`: SharedPreferences local persistence.

Root files in `lib/core/learning/*.dart` are compatibility exports. New code can import `learning.dart` or the specific layer file.
