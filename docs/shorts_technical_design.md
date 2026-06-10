# Hanzify Shorts Technical Design

## Summary

Hanzify Shorts is part of the root Flutter app. It presents HSK content as a vertical micro-learning feed: contextual vocabulary, quick quizzes, short dialogues, listening prompts, mini tests, and summaries.

The implementation keeps one app/package at the repository root. Shorts-specific domain, data, and UI code live under `lib/features/shorts`, while shared audio and learning helpers stay under `lib/core`.

## Architecture

- `lib/features/shorts`
  - Owns Shorts domain types, feed repository, session controller, and presentation.
  - Uses `PageView.builder` with vertical scrolling for the feed.
- `lib/core`
  - Provides shared audio helpers and existing learning infrastructure.
- Root app
  - Hosts Shorts as the default tab alongside lookup and review.

## Public Types

- `ShortFeedItem`
  - `id`, `type`, `level`, `tags`, `payload`.
- `ShortCardType`
  - `vocabContext`, `quickQuiz`, `dialogue`, `listening`, `miniTest`, `summary`.
- Payloads
  - `ShortVocabContext`: situation, Hanzi sentence, pinyin, Vietnamese translation, target vocab id, optional audio URL.
  - `ShortQuickQuiz`: prompt, choices, answer, explanation, optional audio URL.
  - `ShortDialogue`: title, context, and dialogue lines.
  - `ShortMiniTest`: compact quiz group.
  - `ShortSummary`: end-of-session feedback text.
- Services
  - `ShortsFeedRepository`: loads curated HSK1 JSON and attempts to merge generated learning content.
  - `ShortsSessionBuilder`: creates a 10-15 item feed with mixed card rhythm.
  - `ShortsSessionController`: tracks current index, selected answers, and score.

## Content

The curated MVP seed lives in:

```text
assets/data/shorts/shorts_seed_hsk1.json
```

The repository loads this first, then tries to add generated cards from the existing learning asset pipeline. If generated assets are unavailable, the curated feed still works.

## Package Choices

- No third-party swiper package. Flutter `PageView.builder` is enough for vertical page snapping.
- Keep Riverpod for session state.
- Keep GoRouter for root app routes.
- Keep `just_audio` through the existing audio service.
- Do not add `video_player` until there is real video content.
- Do not add Drift/Supabase to Shorts MVP until progress/SRS behavior is ready.

## Test Plan

- Unit test `ShortsSessionBuilder` card rhythm and no duplicate item IDs.
- Unit test `ShortsSessionController` answer locking and score updates.
- Repository test confirms curated HSK1 feed loads and maps typed payloads.
- Widget test confirms the app renders the vertical feed and a quiz choice can be selected.

## Follow-Up

- Add richer curated HSK1 sessions before generating larger levels.
- Connect Shorts answers to SRS only after the feed interaction feels stable.
