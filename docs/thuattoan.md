# Thuật toán học Hanzify production HSK1-HSK4

## Mục tiêu

Hanzify dùng thuật toán học **không cần AI runtime**: app không sinh câu tự do khi người dùng học, mà chọn nội dung từ pool câu/collocation đã được sinh offline và kiểm soát trước. Mục tiêu là đủ chắc để học production tới HSK4, trong đó learner mặc định đang ở HSK2.

Core loop:

```text
Learning Path → Lesson → Activity → Challenge → SRS Card → FSRS Review
```

Nguyên tắc:

- `hsk_learning_path_v1.json` là trục điều hướng bài học.
- `collocation_pool_hsk1_4.json` là nguồn câu/cụm để sinh quiz và ôn tập.
- FSRS local quyết định lịch ôn cho từng card.
- Supabase chỉ sync state sau khi local engine ổn định.
- Không dùng Markov chain cho beginner/HSK4 vì dễ sinh câu sai.

## Data hiện có

| Nhóm | Nguồn | Trạng thái |
|---|---|---|
| Vocab | `hsk1.json`-`hsk4.json` | 3593 mục, đủ dùng HSK1-HSK4 |
| Grammar | `grammar_hsk1.json`-`grammar_hsk4.json` | 109 điểm, learning path dùng đủ |
| Conversation | `conversation.json` | 29 bài, HSK3 còn mỏng nhưng dùng bridge module |
| Graph | `graph/nodes.json`, `graph/edges.json` | map vocab/grammar/conversation |
| Learning path | `learning_path/hsk_learning_path_v1.json` | 4 stages, 27 modules, 131 lessons |

Data thiếu:

- Chưa có field `collocations` trong vocab.
- Chưa có pool câu/collocation chuẩn hóa để app query nhanh.

Giải pháp: sinh offline `assets/data/generated/collocation_pool_hsk1_4.json` từ:

- `exampleSentences` của vocab HSK1-HSK4
- `lines` của `conversation.json`
- `examples` của grammar HSK1-HSK4
- graph edges để bổ sung mapping vocab/grammar/conversation

## Collocation pool

Mỗi item trong pool là một câu/cụm đã có nguồn rõ ràng:

```json
{
  "id": "col_000001",
  "level": 2,
  "source": "vocab_example",
  "textCn": "他说中文说得很好。",
  "pinyin": "Tā shuō Zhōngwén shuō de hěn hǎo.",
  "textVi": "Anh ấy nói tiếng Trung rất giỏi.",
  "targetVocabIds": ["hsk2_中文"],
  "targetGrammarIds": ["g_de_comp"],
  "conversationIds": [],
  "tags": ["giao tiếp"],
  "difficulty": 2.3
}
```

Dedup theo `textCn`. Nếu nhiều nguồn trùng câu, merge IDs và tags.

Difficulty v1:

```text
difficulty = level + min(1.5, character_count / 20)
```

Mục tiêu production v1 không phải đạt 9000 câu ngay, mà là pool ổn định từ dữ liệu thật đang có. Sau này có thể enrich thêm câu/collocation batch offline.

## Learner mặc định HSK2

Profile mặc định:

```text
current_hsk_level = 2
session_size = 20
request_retention = 0.90
```

Level policy:

- HSK1: available for review/diagnostic.
- HSK2: active learning.
- HSK3-HSK4: locked cho new lesson tới khi unlock theo checkpoint/readiness.
- HSK3-HSK4 vẫn có thể xuất hiện rất ít như preview nếu graph chỉ ra prerequisite đã đủ.

Review debt gate:

```text
if due_review_count > session_size * 2:
  pause new lessons
  build review-first session
```

## Lesson content algorithm

Input:

- learner profile
- learning path progress
- due SRS cards
- collocation pool
- vocab/grammar/conversation indexes

Chọn lesson tiếp theo:

```text
1. Nếu review debt cao → route sang review session.
2. Nếu có lesson HSK2 đang started → tiếp tục lesson đó.
3. Nếu không → chọn lesson HSK2 available đầu tiên trong learning path.
4. Chỉ mở HSK3+ khi module/checkpoint trước đó đạt điều kiện unlock.
```

Với mỗi lesson/module:

- lấy `sourceConversationIds`
- lấy `primaryGrammarIds` / `focusGrammarIds`
- lấy vocab liên quan từ graph và collocation pool
- chọn câu/collocation phù hợp level, grammar, conversation

Layout lesson cố định:

```text
1. Goal / Can-do
2. Conversation context
3. Key vocab in context
4. Key grammar in context
5. Collocation practice
6. Quiz
7. Summary + SRS seed
```

## Quiz generation

Quiz không random thô từ vocab list. Tất cả quiz ưu tiên lấy từ collocation pool.

Quiz types v1:

| Type | Prompt | Answer |
|---|---|---|
| `vocab_recognition` | Hanzi/collocation | nghĩa tiếng Việt |
| `vocab_recall` | nghĩa tiếng Việt | Hanzi/cụm |
| `pinyin_choice` | Hanzi/câu | pinyin |
| `grammar_choice` | câu/collocation + grammar focus | cấu trúc đúng |
| `sentence_order` | tokens bị xáo trộn | câu đúng |
| `cloze_collocation` | câu bị khuyết target | target đúng |

Distractor policy:

- Ưu tiên cùng HSK level hoặc gần level.
- Không trùng answer.
- Với vocab, ưu tiên cùng `wordType` nếu có.
- Với grammar, ưu tiên cùng level/category nếu có.

HSK2 mix:

```text
active new content: HSK2
review content: HSK1 + HSK2 due cards
preview content: HSK3 rất ít và chỉ khi prerequisite đủ
```

## SRS card rules

SRS là card-based, không item-based.

| Target | Card tạo trước | Card mở sau |
|---|---|---|
| vocab | `recognition` | `recall` sau khi recognition ổn |
| character | `recognition` | `writing` để phase sau |
| grammar | `grammar_choice` | `sentence_build` sau khi học trong context |
| conversation | `comprehension` | roleplay để phase sau |

Card key ổn định:

```text
{targetType}:{targetId}:{cardType}
```

Ví dụ:

```text
vocab:hsk2_中文:recognition
grammar:g_de_comp:grammar_choice
```

## Full local FSRS

Dùng FSRS local ngay từ đầu. Schema local phải map được sang Supabase v2:

```text
target_type: vocab | character | grammar | conversation
card_type: recognition | recall | cloze | grammar_choice | sentence_build
rating: 1 Again, 2 Hard, 3 Good, 4 Easy
state: new | learning | review | relearning | suspended | buried
```

Mỗi review cập nhật:

- `due_at`
- `stability`
- `difficulty`
- `scheduled_days`
- `elapsed_days`
- `reps`
- `lapses`
- review log before/after

Session mặc định:

```text
review_count = floor(session_size * 0.7)
new_count = session_size - review_count
```

Order:

1. Due cards sorted by `due_at`.
2. New cards từ active lesson.
3. Interleave để tránh cùng type liên tục.

## Unlock và remediation

Lesson complete:

```text
required_activities_done && quiz_score >= 70
```

Module complete:

```text
all_core_lessons_done && checkpoint_score >= 70
```

Checkpoint fail:

- Không hard-block vĩnh viễn.
- Sinh remediation set từ failed vocab/grammar/collocations.
- Cho retry sau remediation.

## Implementation roadmap

1. Sinh offline collocation pool HSK1-HSK4.
2. Implement local data models cho collocation, quiz, SRS card, review log.
3. Implement FSRS local scheduler.
4. Implement quiz generator từ collocation pool.
5. Implement session builder 70% review / 30% new.
6. Nối learning path HSK2 active và HSK1 review.
7. Sau khi local ổn định mới sync Supabase v2.

## Acceptance criteria

- Collocation pool sinh được từ HSK1-HSK4 và không duplicate `textCn`.
- HSK2 learner chọn được HSK2 active lesson.
- HSK3-HSK4 không xuất hiện như new lesson khi chưa unlock.
- Quiz luôn có prompt, answer, distractors hợp lệ.
- `cloze_collocation` luôn có answer nằm trong câu gốc.
- FSRS rating 1-4 cập nhật due date, stability, difficulty.
- Review log lưu được before/after scheduling state.
