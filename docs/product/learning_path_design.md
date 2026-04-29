# Hanzify Learning Path Design

## Mục tiêu

Learning Path là màn hình điều hướng chính của Hanzify. Nó biến dữ liệu `hsk_learning_path_v1.json` thành một lộ trình học rõ ràng từ HSK1 đến HSK4, đồng thời kết nối với collocation quiz và local FSRS hiện có.

Người học mặc định đang ở HSK2:

- HSK1: mở để review/diagnostic.
- HSK2: active learning.
- HSK3-HSK4: locked cho bài mới, chỉ mở dần theo checkpoint.

---

## Data hiện có

Nguồn chính: `assets/data/learning_path/hsk_learning_path_v1.json`.

Hiện có:

| Level | Modules | Checkpoints | Vai trò |
|---|---:|---:|---|
| HSK1 | 6 | 2 | Review/diagnostic |
| HSK2 | 6 | 2 | Active learning |
| HSK3 | 7 | 2 | Locked / future unlock |
| HSK4 | 8 | 2 | Locked / future unlock |

Tổng:

- 4 stages
- 27 modules
- 131 core lessons
- 8 checkpoints
- 139 total learning nodes

---

## Mô hình điều hướng

```text
LearningPathScreen
  StageSection HSK1-HSK4
    ModuleCard
      LessonNode
      CheckpointNode
```

### Stage

Stage đại diện cho một level HSK.

Hiển thị:

- tên level: `HSK1`, `HSK2`, `HSK3`, `HSK4`
- goal ngắn
- progress: completed modules / total modules
- trạng thái: `review`, `active`, `locked`, `completed`

### Module

Module là đơn vị học chính theo can-do goal.

Hiển thị:

- module id, ví dụ `H2-M1`
- title
- can-do
- số lessons
- số grammar trọng tâm
- số conversations
- progress ring hoặc progress bar
- trạng thái: locked / available / started / completed

### Lesson

Lesson là node có thể bấm vào để học.

Hiển thị:

- lesson index
- type: preview, input, pattern_a, pattern_b, output_review
- title
- trạng thái: locked / available / started / completed

### Checkpoint

Checkpoint là node đánh giá module/stage.

Hiển thị:

- checkpoint title
- required score
- current/best score nếu có
- trạng thái: locked / available / passed / retry

---

## State model

### Static content

Lấy từ JSON asset:

```text
LearningStage
LearningModule
LearningLesson
LearningCheckpoint
```

Không cần persist static content.

### User progress

Giai đoạn đầu dùng local persistence, sau này map sang Supabase v2.

```text
LearningUnitProgress
- unitId
- unitKind: lesson | checkpoint
- stageId
- moduleId
- status: locked | available | started | completed
- score
- startedAt
- completedAt
- lastOpenedAt
```

Mapping Supabase sau này: `user_learning_unit_progress`.

---

## Unlock rules v1

### Stage policy mặc định

```text
HSK1 = review
HSK2 = active
HSK3 = locked
HSK4 = locked
```

### Lesson unlock

Trong một module:

```text
lesson 1 available nếu module available/started
lesson N available nếu lesson N-1 completed
```

### Module unlock

```text
H2-M1 available mặc định
module N available nếu module N-1 completed
```

### Module complete

```text
all core lessons completed && checkpoint score >= 70
```

### Checkpoint unlock

```text
checkpoint available nếu all module lessons completed
```

### Remediation

Nếu checkpoint score < 70:

- checkpoint status = retry
- tạo remediation quiz từ failed vocab/grammar/collocations
- không mở module tiếp theo cho tới khi retry pass

---

## Learning flow khi bấm Lesson

Input từ lesson:

- `conversationIds`
- `focusGrammarIds`
- module `primaryGrammarIds`
- stage/module id

Flow:

```text
1. Mark lesson started
2. Load conversations by conversationIds
3. Query collocation pool by level + conversationIds + grammarIds
4. Generate lesson quizzes
5. User answers quizzes
6. StudySessionController updates FSRS cards/logs
7. If quiz score >= 70, mark lesson completed
8. Unlock next lesson or checkpoint
```

Giai đoạn đầu, nếu chưa có màn lesson riêng, `GameWorldScreen` có thể nhận selected lesson và render quiz tương ứng.

---

## UI layout đề xuất

### Desktop/Web rộng

```text
┌─────────────────────────────────────────────┐
│ Header: Hanzify Learning Path               │
│ Current: HSK2 · 2/6 modules · Due reviews   │
├─────────────────────────────────────────────┤
│ Stage tabs: HSK1 | HSK2 | HSK3 | HSK4       │
├─────────────────────────────────────────────┤
│ HSK2 Goal                                   │
│ ┌ Module H2-M1 ┐ ┌ Module H2-M2 ┐          │
│ │ Lessons      │ │ Locked/Next   │          │
│ └──────────────┘ └──────────────┘          │
└─────────────────────────────────────────────┘
```

### Mobile/Web hẹp

```text
Header
Current stage card
Vertical module list
Expandable lesson nodes
Bottom CTA: Continue
```

---

## Visual states

| State | Visual |
|---|---|
| locked | low opacity, lock icon |
| available | primary border, CTA enabled |
| started | progress indicator |
| completed | check icon, success color |
| retry | warning color, retry CTA |
| active stage | highlighted tab/card |

---

## Continue button logic

CTA chính: `Tiếp tục học`.

Priority:

```text
1. Nếu due FSRS review cao → Review Session
2. Nếu có lesson started chưa complete → lesson đó
3. Nếu có lesson available ở HSK2 → lesson đó
4. Nếu checkpoint available → checkpoint
5. Nếu HSK2 complete → unlock HSK3 intro
```

---

## Implementation phases

### Phase 1: Read-only learning path screen

- Parse `hsk_learning_path_v1.json`.
- Show HSK1-HSK4 stages.
- Show modules/lessons/checkpoints.
- Apply default policy: HSK1 review, HSK2 active, HSK3-HSK4 locked.

### Phase 2: Local progress

- Add local `LearningProgressStore`.
- Persist lesson/checkpoint status.
- Unlock next lesson/module.

### Phase 3: Lesson → quiz integration

- Selecting a lesson filters collocation pool by level/conversation/grammar.
- Reuse existing quiz generator and FSRS study controller.

### Phase 4: Checkpoint/remediation

- Generate checkpoint quiz from module grammar/vocab/collocations.
- Score >= 70 unlocks next module.
- Score < 70 creates remediation set.

### Phase 5: Supabase sync

- Sync local `LearningUnitProgress` to `user_learning_unit_progress`.
- Keep local source of truth for offline-first.

---

## Acceptance criteria

- HSK2 user sees HSK2 as active by default.
- HSK1 is visible and reviewable.
- HSK3-HSK4 are visible but locked.
- H2-M1 lesson 1 is available on fresh install.
- Completing lesson 1 unlocks lesson 2.
- Completing all module lessons unlocks module checkpoint.
- Passing checkpoint unlocks next module.
- Due review debt can route user to review before new lesson.
