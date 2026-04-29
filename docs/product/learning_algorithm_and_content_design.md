# Hanzify Learning Algorithm & Content Design

## Assumptions

- Hanzify is a web-first Flutter learning game.
- Static learning content stays in JSON assets: vocab, characters, grammar, conversations, graph, learning path.
- Supabase stores user state and SRS sync only.
- The first implementation should be simple, deterministic, and testable before adding personalization or AI.
- SRS should be FSRS-ready, but the first production algorithm can use a smaller rule set.

---

## Product Goal

Hanzify should not feel like a raw flashcard app. The core loop is:

1. Learn through a conversation or mission.
2. Extract useful vocab, characters, and grammar from that context.
3. Practice with short interactive challenges.
4. Schedule durable review through SRS cards.
5. Unlock the next lesson/module only when the learner has enough readiness.

The learning system should answer three questions:

- What should the learner study next?
- What should the learner review now?
- When is a lesson considered complete enough to unlock the next one?

---

## Content Hierarchy

```text
Stage HSK1-HSK4
  Module
    Lesson
      Activity
        Challenge
          SRS Card candidates
```

### Stage

A stage maps roughly to an HSK level.

Example:

- `HSK1`
- `HSK2`
- `HSK3`
- `HSK4`

Stage owns:

- learning goal
- module list
- checkpoint list
- unlock progress

### Module

A module is the main learning unit. It should be anchored by a communication goal, not a grammar list.

Examples:

- Chào hỏi và giới thiệu bản thân
- Gọi món và thanh toán
- Hỏi đường
- Nói về thói quen

Module owns:

- `sourceConversationIds`
- `primaryGrammarIds`
- target vocab derived from conversations and graph
- lesson sequence
- checkpoint requirement

### Lesson

A lesson is one short session, ideally 5-10 minutes.

Recommended lesson types:

| Type | Purpose |
|---|---|
| `preview` | Introduce can-do goal, key vocab, key characters |
| `input` | Read/listen to anchor conversation |
| `pattern_a` | Teach first grammar cluster |
| `pattern_b` | Teach second grammar cluster or contrast |
| `guided_practice` | Controlled drills and sentence building |
| `output_review` | Production task + review quiz |
| `checkpoint` | Integrated test for module/stage unlock |

### Activity

An activity is a UI block inside a lesson.

Recommended activity types:

| Type | Description |
|---|---|
| `dialogue_read` | Read conversation line by line |
| `dialogue_listen` | Listening or simulated audio task |
| `vocab_match` | Match Hanzi/Pinyin/meaning |
| `character_recognition` | Identify character meaning or reading |
| `grammar_explain` | Short explanation with examples |
| `grammar_choose` | Choose correct structure/particle/order |
| `sentence_build` | Build sentence from tokens |
| `translation_vi_zh` | Vietnamese prompt to Chinese output |
| `roleplay` | Guided output based on conversation |
| `mixed_review` | Combined review challenge |

### Challenge

A challenge is the smallest assessable unit.

Minimum fields:

```json
{
  "id": "challenge_id",
  "type": "vocab_match",
  "targetType": "vocab",
  "targetId": "hsk1_你好",
  "prompt": "你好",
  "choices": ["Xin chào", "Cảm ơn", "Tạm biệt"],
  "answer": "Xin chào",
  "explanation": "你好 dùng để chào hỏi cơ bản."
}
```

Challenges should be generated from existing content where possible, not manually authored first.

---

## Learning Flow

### Lesson Flow

Each lesson should follow this rhythm:

1. Context: show goal and conversation snippet.
2. Notice: highlight new vocab/grammar in context.
3. Understand: short explanation and examples.
4. Practice: 3-8 challenges.
5. Produce: one output-style task.
6. Review seed: create or update SRS cards for learned targets.

### Daily Session Flow

Daily study should mix new learning and review:

```text
1. Due review cards
2. Current lesson continuation
3. New lesson if review load is healthy
4. Optional bonus/game challenge
```

Default balance:

| Bucket | Share |
|---|---:|
| Due SRS reviews | 50% |
| Current lesson activities | 35% |
| New content preview | 10% |
| Bonus/game challenges | 5% |

If due reviews are too high, pause new content.

---

## Readiness Algorithm

The app should rank what to do next with a simple score.

### Next Lesson Selection

A lesson is available when:

- previous required lesson is completed
- required module is unlocked
- prerequisite grammar is introduced
- review debt is below threshold

Recommended rule:

```text
available = prerequisites_met && due_review_count <= daily_review_limit * 2
```

If review debt is high, route the learner to review first.

### Module Completion

A module is completed when:

- all required lessons completed
- module checkpoint score >= 70
- at least 70% of primary grammar has status `learning` or better
- at least 70% of target vocab has at least one active SRS card

### Stage Completion

A stage is completed when:

- all core modules completed
- all checkpoints completed
- stage checkpoint average >= 75
- no critical prerequisite module is incomplete

---

## SRS Design

SRS is card-based, not item-based.

One vocab item can produce multiple cards:

| Target | Card Type | Example |
|---|---|---|
| vocab | `recognition` | 你好 → Xin chào |
| vocab | `recall` | Xin chào → 你好 |
| vocab | `listening` | Audio/Pinyin → meaning |
| character | `recognition` | 好 → tốt |
| character | `writing` | Prompt meaning/reading → write character |
| grammar | `grammar_choice` | Pick correct particle/order |
| grammar | `sentence_build` | Arrange words into valid sentence |
| conversation | `comprehension` | Answer question about dialogue |

### Card Creation Rules

Create SRS cards only after the learner has encountered the target in context.

Recommended defaults:

- vocab: create `recognition` first, create `recall` after recognition succeeds twice
- character: create `recognition` first, create `writing` only for high-value characters
- grammar: create `grammar_choice` first, create `sentence_build` after explanation activity
- conversation: create `comprehension` cards only for anchor conversations

This avoids overwhelming beginners.

### Rating Scale

Use a 4-point rating compatible with FSRS:

| Rating | Label | Meaning |
|---:|---|---|
| 1 | Again | Forgot or wrong |
| 2 | Hard | Correct but slow/uncertain |
| 3 | Good | Correct with normal effort |
| 4 | Easy | Correct and effortless |

For multiple-choice questions, map automatically:

```text
wrong -> Again
correct but slow -> Hard
correct normal -> Good
correct very fast on mature card -> Easy
```

Learner can optionally override rating later.

### First Algorithm

Use a simple FSRS-ready scheduler first.

Initial card:

```text
state = new
due_at = now
stability = null
difficulty = null
reps = 0
lapses = 0
scheduled_days = 0
```

After review:

| Current State | Again | Hard | Good | Easy |
|---|---|---|---|---|
| `new` | 5 min | 10 min | 1 day | 3 days |
| `learning` | 5 min | 15 min | 1 day | 3 days |
| `review` | 10 min + lapse | 0.5x interval | 1.8x interval | 2.5x interval |
| `relearning` | 5 min | 15 min | 1 day | 3 days |

Clamp intervals:

```text
min review interval = 1 day
max review interval = 365 days
```

State transition:

```text
Again on review -> relearning, lapses += 1
Good/Easy after learning -> review
Suspended/buried -> excluded from due queue
```

Store FSRS fields now:

```text
stability_after = estimated interval strength
difficulty_after = simple 1-10 difficulty estimate
algorithm = "hanzify_v1"
```

Later, the scheduling function can be replaced by true FSRS without changing database shape.

---

## Challenge Generation

### Vocab Challenges

From `hsk*.json`:

- Hanzi → Vietnamese meaning
- Vietnamese meaning → Hanzi
- Pinyin → Hanzi
- Hanzi → Pinyin
- sentence cloze using `exampleSentences`

Distractors should come from same HSK level and similar word type when possible.

### Character Challenges

From `char_hsk*.json`:

- character → meaning
- character → pinyin
- component/radical recognition if data supports it
- writing prompt later

### Grammar Challenges

From `grammar_hsk*.json`:

- choose correct structure
- choose correct particle
- sentence order
- identify grammar pattern in example
- transform sentence when examples support it

### Conversation Challenges

From `conversation.json`:

- line comprehension
- speaker identification
- missing line selection
- roleplay response
- vocab-in-context selection

### Graph-Based Reinforcement

Use graph data to connect review and learning:

- if a learner fails grammar, queue vocab/conversation examples that use it
- if a learner fails vocab, show conversation lines containing it
- if a module introduces grammar, preview connected vocab before output task

Simple ranking:

```text
score = edge_weight + due_bonus + lesson_relevance_bonus - recent_seen_penalty
```

---

## Unlocking Rules

### Lesson Unlock

Unlock next lesson when current lesson has:

- completion status `completed`
- score >= 70, if scored
- no blocking challenge failed more than 2 times

### Module Unlock

Unlock next module when previous module has:

- all core lessons complete
- checkpoint complete
- checkpoint score >= 70

### Remediation

If checkpoint fails:

- do not hard-block forever
- generate a short remediation set from failed targets
- allow retry after remediation

---

## Data Responsibilities

### Existing JSON Assets

| Asset | Role |
|---|---|
| `hsk*.json` | canonical vocab content |
| `char_hsk*.json` | character content |
| `grammar_hsk*.json` | grammar explanations/examples |
| `conversation.json` | anchor communication content |
| `graph/nodes.json` | content index |
| `graph/edges.json` | relationship map |
| `learning_path/hsk_learning_path_v1.json` | canonical lesson/module order |

### New Generated Runtime Models

The app should derive these in memory first:

- `LearningStage`
- `LearningModule`
- `LearningLesson`
- `LearningActivity`
- `ReviewChallenge`
- `SrsCardSeed`

Do not create new persisted content tables until the in-memory model is proven.

---

## Implementation Phases

### Phase 1: Content Loader

- Load `hsk_learning_path_v1.json`.
- Parse stages, modules, lessons, checkpoints.
- Show learning path in UI.
- No SRS yet.

### Phase 2: Challenge Generator

- Generate vocab and grammar challenges from JSON assets.
- Replace hardcoded `你好` demo challenge.
- Keep generation deterministic for tests.

### Phase 3: Local SRS Engine

- Implement `SrsCard` and review scheduling in Dart.
- Use the simple `hanzify_v1` interval rules.
- Store state locally first.

### Phase 4: Progress & Unlocks

- Track lesson completion.
- Unlock next lessons/modules.
- Add checkpoint scoring.

### Phase 5: Supabase Sync

- Sync progress tables, SRS cards, and review logs.
- Use schema v2.
- Resolve conflicts with `local_updated_at` and `server_updated_at`.

### Phase 6: True FSRS Upgrade

- Replace `hanzify_v1` scheduler with FSRS.
- Keep existing `user_srs_cards` and `user_srs_review_logs`.
- Use review logs for parameter tuning later.

---

## Minimal Vertical Slice

The smallest useful version should be:

1. Show HSK1 modules from learning path.
2. Open first lesson.
3. Show conversation preview.
4. Generate 5 vocab/grammar challenges.
5. Convert completed targets into SRS cards.
6. Schedule reviews with `hanzify_v1`.
7. Mark lesson complete and unlock next lesson.

This proves the learning system before investing in auth, sync, or advanced game mechanics.
