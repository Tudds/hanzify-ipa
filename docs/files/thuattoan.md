# Thuật toán học HSK — Source of Truth

**Version**: 1.0
**Last updated**: 2026-04-27
**Scope**: Tài liệu duy nhất mô tả toàn bộ thuật toán học cho app HSK1-4. Nếu có file khác mâu thuẫn với doc này, doc này thắng.

---

## 0. TL;DR cho người implement

Bạn cần biết 5 thứ trước khi code:

1. **Không AI runtime**. Toàn bộ thuật toán dùng deterministic logic + dataset có sẵn. AI chỉ dùng offline để generate content (nếu cần) hoặc curate.
2. **5 cấp nội dung**: `Learning Path → Module → Lesson → Activity → Challenge → SRS Card`. Mỗi cấp có scheduler/selector riêng.
3. **4 tầng thuật toán**: `Enrichment → Composition → Selection → Packaging`. Mỗi tầng implement riêng, test riêng.
4. **SRS v1 dùng `hanzify_v1`** (interval đơn giản 1-4), không phải FSRS thật. Schema FSRS-ready để Phase 7 swap không phải migrate.
5. **Combinatorial collocations** đã có pipeline chạy (xem section 6) → giải bài toán "đa dạng câu" mà không cần slot-filling tự do.

---

## 1. Mục tiêu & Non-goals

### 1.1. Mục tiêu

- Học vocab HSK1-4 với **active recall** (không passive reading)
- Spaced Repetition System dựa trên rating người dùng
- Đa dạng ngữ cảnh và câu (qua Combinatorial collocations)
- Tích hợp grammar points HSK1-4 vào quiz, không chỉ vocab
- Hoạt động **offline-first**, sync Supabase khi online
- Scheduler thông minh phân biệt review debt vs new content

### 1.2. Non-goals (v1)

- KHÔNG generate câu mới bằng AI runtime
- KHÔNG dùng FSRS thật cho v1 (lùi Phase 7)
- KHÔNG dùng slot-filling tự do (lùi Phase 7)
- KHÔNG pre-generate hàng vạn câu (lùi Phase 5)
- KHÔNG pronunciation scoring trong v1 (riêng track Azure Speech)
- KHÔNG personalize theo sở thích user trong v1

---

## 2. Inventory dữ liệu thực tế

### 2.1. Dataset đã có

| Loại | Số lượng | File | Note |
|---|---|---|---|
| Vocab HSK1 | 509 | `hsk1.json` | có pinyin, vi, en, 1 example sentence/từ |
| Vocab HSK2 | 936 | `hsk2.json` | |
| Vocab HSK3 | 1.153 | `hsk3.json` | |
| Vocab HSK4 | 995 | `hsk4.json` | |
| Grammar HSK1 | 24 điểm | `grammar_hsk1.json` | có structure, examples, related |
| Grammar HSK2 | 31 điểm | `grammar_hsk2.json` | |
| Grammar HSK3 | 25 điểm | `grammar_hsk3.json` | |
| Grammar HSK4 | 29 điểm | `grammar_hsk4.json` | |
| Conversations | 29 hội thoại | `conversation.json` | HSK1: 10, HSK2: 8, HSK3: 3, HSK4: 8 |
| **Tổng vocab** | **3.593 entries** | | nhưng 366 trùng mặt chữ giữa các level |
| **Tổng grammar** | **109 điểm** | | sạch, không trùng |
| **Tổng câu validated** | **~4.500** | | examples + grammar + conversations |

### 2.2. Vấn đề phải xử lý ngay (Tầng 1)

#### 2.2.1. Trùng mặt chữ (366 cases)

Có 366 mặt chữ xuất hiện ở nhiều HSK level với nghĩa/pinyin khác nhau. Ví dụ: `好` HSK1 (`hǎo` - tốt) vs `好` HSK4 (`hào` - thích).

**Giải pháp**: Tạo `canonical_key` = `{hanzi}_{pinyin}`. SRS card và progress phải gắn vào canonical_key, KHÔNG phải vocab id.

```
hsk1_好 → canonical: 好_hǎo
hsk4_好 → canonical: 好_hào
```

Hai entries trên là 2 SRS card riêng biệt, user phải học cả hai.

#### 2.2.2. Conversation HSK3 quá ít (3 hội thoại)

**Giải pháp**: Bridge modules. Khi user vào HSK3, tạm thời:
- Reuse conversation HSK2, ghép vocab HSK3 mới
- Dùng `examples` trong grammar HSK3 (~100 câu) thay cho conversation
- Đánh dấu UI rõ "Bridge content"
- Backlog: ưu tiên bổ sung conversation HSK3

#### 2.2.3. Vocab thiếu metadata

Vocab hiện chỉ có 1 example sentence. Để pipeline đa dạng hóa hoạt động, cần enrich:

| Field cần thêm | Cách build | Khi nào cần |
|---|---|---|
| `canonical_key` | Script tạo từ `{hanzi}_{pinyin}` | Phase 1 |
| `frequency_rank` | Đếm xuất hiện trong conversation + grammar | Phase 2 |
| `slot_compatibility` | Auto từ `pos` + `tags` có sẵn | Phase 3 |
| `prereq_vocab` | Manual cho top 200 từ trừu tượng | Phase 5 |

### 2.3. Asset đã build (Combinatorial pipeline)

Đã có 2 file mới làm tài sản (xem chi tiết section 6):

- `collocations_db.json`: 1.434 cặp collocations (360 head verbs/adj). HSK4 verb coverage 52.4%
- `frames_bank.json`: 47 frames cover HSK1-4 grammar
- `sentence_generator.dart`: Code Generator ready cho Flutter
- `sample_output.json`: Test fixture

---

## 3. Mô hình 5 cấp phân rã nội dung

```
Learning Path
├── Module (chủ đề lớn, ~3-7 lesson)
│   ├── Lesson (một buổi học, ~10-15 phút)
│   │   ├── Activity (mục trong lesson)
│   │   │   └── Challenge (1 câu hỏi)
│   │   │       └── SRS Card (item ôn tập về sau)
```

### 3.1. Định nghĩa từng cấp

#### Learning Path
Đường học tổng thể, ví dụ: `path_hsk1`, `path_hsk1_to_hsk2`. Mỗi path có:
- `id`, `title`, `target_hsk_level`
- `modules: List<ModuleId>` theo thứ tự
- `entry_requirements`: prerequisite paths

#### Module
Chủ đề lớn (~30-60 phút học), ví dụ: `m_hsk1_greetings`, `m_hsk2_shopping`. Mỗi module có:
- `id`, `title`, `description`, `icon`
- `core_lessons: List<LessonId>` (bắt buộc)
- `optional_lessons: List<LessonId>`
- `checkpoint: CheckpointSpec` (test cuối module)
- `unlock_score: int = 70` (% để pass checkpoint)

#### Lesson
Một buổi học (~10-15 phút), ví dụ: `l_hsk1_pronouns`. Mỗi lesson có:
- `id`, `title`
- `activities: List<Activity>` theo thứ tự
- `vocab_introduced: List<VocabId>` (~5-10 từ mới)
- `grammar_introduced: List<GrammarId>` (0-2 điểm)
- `pass_score: int = 70`

#### Activity
Mục trong lesson, có 4 loại chính:
- `vocab_intro`: giới thiệu từ mới (hiển thị, không quiz)
- `vocab_practice`: drill từ vừa học
- `grammar_intro`: giới thiệu cấu trúc ngữ pháp
- `conversation_play`: nghe + xem hội thoại

Mỗi activity có:
- `type: ActivityType`
- `content_refs: List<ContentId>` (vocab/grammar IDs liên quan)
- `challenges: List<Challenge>`
- `is_required: bool`

#### Challenge
Một câu hỏi cụ thể, có schema:
- `id`, `type: ChallengeType` (xem section 5.2)
- `prompt: ChallengePrompt`
- `correct_answer: Answer`
- `distractors: List<Answer>` (cho multiple choice)
- `points: int` (mặc định 10)
- `hint: String?`

#### SRS Card
Item ôn tập độc lập với lesson, có schema:
- `id`, `canonical_key` (KHÔNG phải vocab_id)
- `card_type: SrsCardType` (vocab_recognition, vocab_recall, character_recognition, grammar_choice)
- `interval_days: int`
- `ease_factor: double`
- `due_date: DateTime`
- `last_rating: int?` (1-4)
- `repetitions: int`
- FSRS-ready fields: `stability`, `difficulty`, `elapsed_days`, `last_review` (chỉ ghi, không tính trong v1)

### 3.2. Quan hệ với Supabase schema v2

Mapping vào schema có sẵn:

```
learning_paths           → path_id, modules[]
modules                  → module_id, lessons[]
lessons                  → lesson_id, activities[]
user_lesson_progress     → đã xem activity nào, score
user_module_progress     → đã pass checkpoint chưa
user_srs_cards           → 1 row per card
user_srs_review_logs     → log mỗi lần review
```

---

## 4. Bốn tầng thuật toán

### Tầng 1 — Enrichment

**Vai trò**: Bổ sung metadata cho dataset có sẵn để các tầng sau hoạt động.

**Input**: Raw HSK1-4 JSON files
**Output**: Enriched JSON + auxiliary DBs

**Việc cần làm**:
1. Tạo `canonical_key` cho mỗi vocab entry
2. Build `frequency_rank` từ corpus (đếm xuất hiện trong examples + grammar + conversation)
3. Auto-tag `slot_compatibility` theo `pos` + `tags`
4. Build `vocab_grammar_links`: với mỗi grammar, list các vocab đáp ứng pattern
5. Build CollocationsDB + FramesBank (xem section 6)

**Tần suất chạy**: 1 lần khi setup, rerun khi dataset cập nhật.

### Tầng 2 — Content Composition

**Vai trò**: Tạo/chọn content cho từng challenge.

**Input**: target vocab/grammar + user state
**Output**: Câu hoặc nội dung bài tập

**2 strategy hoạt động song song**:

#### Strategy 2A — Static Reuse
Dùng nội dung tĩnh validated:
- `exampleSentences` của vocab
- `examples` trong grammar
- `lines` trong conversation

Pseudocode:
```
function getStaticSentence(target_vocab, count):
    pool = []
    pool.extend(target_vocab.exampleSentences)
    pool.extend(grammar_examples_containing(target_vocab))
    pool.extend(conversation_lines_containing(target_vocab))
    return shuffle(pool)[:count]
```

#### Strategy 2B — Combinatorial Collocations
Dùng pipeline ở section 6.
- Dùng khi Strategy 2A không đủ count
- Hoặc khi user explicit yêu cầu "more practice"

**Quy tắc kết hợp**: Lấy từ 2A trước, nếu thiếu mới fallback 2B. KHÔNG mix output 2A + 2B trong cùng challenge.

#### KHÔNG dùng trong v1
- Slot-filling tự do (Phase 7)
- LLM-generated content (Phase 7+)

### Tầng 3 — Lesson Selection

**Vai trò**: Quyết định "hôm nay học gì". Có 3 component:

#### 3.1. LearningPathSelector
```
function selectNextLesson(user):
    path = user.current_path
    in_progress = path.modules.find(not_completed)
    next_lesson = in_progress.lessons.find(not_completed_or_failed)
    return next_lesson
```

#### 3.2. SessionBuilder (review debt aware)

Xác định tỷ lệ review/new theo review debt:

```
function calcMix(user):
    debt = countOverdueCards(user)

    if debt > 100:  return (0.9, 0.1)  // 90% review, cảnh báo user
    if debt > 30:   return (0.7, 0.3)  // 70% review (default)
    if debt > 0:    return (0.5, 0.5)
    return (0.3, 0.7)                  // debt=0: 70% new

function buildSession(user, target_minutes=15):
    review_ratio, new_ratio = calcMix(user)
    target_challenges = target_minutes * 4  // ~4 challenges/phút

    review_count = round(target_challenges * review_ratio)
    new_count = target_challenges - review_count

    review_items = SrsScheduler.dueNow(user, limit=review_count)
    new_items = LearningPathSelector.next(user).getChallenges(new_count)

    return interleave(review_items, new_items)
```

#### 3.3. Interleaving rules
Khi `interleave()`, không xếp 2 challenge cùng `tag` chính liền nhau:

```
function interleave(review, new):
    result = []
    review_q = queue(review)
    new_q = queue(new)

    while not (review_q.empty and new_q.empty):
        candidate = pickByRatio(review_q, new_q)
        last_tag = result[-1].primary_tag if result else None

        if candidate.primary_tag == last_tag:
            // try the other queue
            candidate = pickFromOther(candidate.source)
        result.append(candidate)

    return result
```

### Tầng 4 — Lesson Packaging

**Vai trò**: Đóng gói content thành dạng challenge phù hợp.

#### 4.1. Quy tắc unlock dạng challenge

Mỗi vocab card mới chỉ khởi đầu với 1 dạng challenge:

```
Lần 1 gặp vocab:    chỉ tạo card vocab_recognition (Hán → Việt)
                    interval khởi đầu = 1 day

Sau interval ≥ 7 ngày + rating ≥ 3:
                    unlock card vocab_recall (Việt → Hán)

Sau interval ≥ 14 ngày + rating ≥ 3 + multi-character:
                    unlock card character_recognition (cho từ ghép)
```

→ Mục đích: tránh user mở app thấy 200 card review từ ngày đầu.

#### 4.2. Challenge formats theo activity type

| Activity type | Challenge formats v1 |
|---|---|
| `vocab_intro` | Không có challenge, chỉ display |
| `vocab_practice` | `vocab_match`, `pinyin_choice`, `meaning_choice`, `sentence_order` |
| `grammar_intro` | `grammar_choice`, `sentence_order` |
| `conversation_play` | `comprehension_q` (phase sau) |
| `srs_review` | `vocab_recognition`, `vocab_recall`, `character_recognition`, `grammar_choice` |

Schema chi tiết từng format ở section 5.2.

---

## 5. Algorithm spec chi tiết

### 5.1. SrsScheduler — `hanzify_v1`

**Note**: Đây là scheduler v1 đơn giản. Schema FSRS-ready để Phase 7 swap.

```typescript
// hanzify_v1 - simple ease-factor based

const INITIAL_INTERVAL = 1;  // ngày
const INITIAL_EASE = 2.5;
const MIN_EASE = 1.3;
const MAX_EASE = 2.8;

function review(card: SrsCard, rating: int /* 1-4 */): SrsCard {
  let { interval, ease, repetitions } = card;

  switch (rating) {
    case 1: // Again
      interval = INITIAL_INTERVAL;
      ease = max(MIN_EASE, ease - 0.20);
      repetitions = 0;
      break;
    case 2: // Hard
      interval = max(INITIAL_INTERVAL, interval * 1.2);
      ease = max(MIN_EASE, ease - 0.15);
      repetitions += 1;
      break;
    case 3: // Good
      if (repetitions === 0) interval = 1;
      else if (repetitions === 1) interval = 4;
      else interval = round(interval * ease);
      // ease unchanged
      repetitions += 1;
      break;
    case 4: // Easy
      if (repetitions === 0) interval = 4;
      else interval = round(interval * ease * 1.3);
      ease = min(MAX_EASE, ease + 0.15);
      repetitions += 1;
      break;
  }

  return {
    ...card,
    interval_days: interval,
    ease_factor: ease,
    repetitions,
    due_date: now() + interval * 86400000,
    last_rating: rating,
    last_review: now(),
  };
}

function dueNow(user: User, limit: int): SrsCard[] {
  return SrsCardRepo.query(`
    SELECT * FROM user_srs_cards
    WHERE user_id = $1 AND due_date <= NOW()
    ORDER BY due_date ASC
    LIMIT $2
  `, [user.id, limit]);
}
```

**Tham số mặc định** chuẩn cho tiếng Trung. Có thể tune sau nhưng v1 giữ nguyên để comparable cross-user.

### 5.2. ChallengeGenerator — quiz formats

#### vocab_recognition (Hán → Việt)
```json
{
  "type": "vocab_recognition",
  "prompt": { "hanzi": "考虑", "pinyin": "kǎolǜ" },
  "correct_answer": "suy nghĩ",
  "distractors": ["giải quyết", "chuẩn bị", "yêu cầu"]
}
```

Distractors: 3 từ cùng `pos`, cùng `level ± 1`, KHÔNG cùng `tags` (tránh quá dễ).

#### vocab_recall (Việt → Hán)
```json
{
  "type": "vocab_recall",
  "prompt": { "vi": "suy nghĩ" },
  "correct_answer": "考虑",
  "distractors": ["考试", "考察", "考察"]
}
```

Distractors: ưu tiên hán tự CÓ ký tự chung với answer (`考` xuất hiện trong cả `考虑/考试/考察`).

#### pinyin_choice (Hán → pinyin)
```json
{
  "type": "pinyin_choice",
  "prompt": { "hanzi": "考虑" },
  "correct_answer": "kǎolǜ",
  "distractors": ["kǎoshì", "kǎochá", "kǎolì"]
}
```

#### sentence_order (sắp xếp câu)
```json
{
  "type": "sentence_order",
  "prompt": {
    "shuffled_tokens": ["问题", "考虑", "我", "在"],
    "vi_translation": "Tôi đang cân nhắc vấn đề"
  },
  "correct_answer": "我在考虑问题"
}
```

Câu source: lấy từ Strategy 2A (vocab examples) hoặc 2B (combinatorial).

#### grammar_choice (chọn pattern đúng)
```json
{
  "type": "grammar_choice",
  "prompt": {
    "vi": "Tôi đang cân nhắc vấn đề",
    "options": [
      "我在考虑问题",
      "我考虑在问题",
      "我考虑问题在",
      "在我考虑问题"
    ]
  },
  "correct_answer_index": 0,
  "grammar_focus": "aspect_正在"
}
```

#### sentence_build (điền chỗ trống)
```json
{
  "type": "sentence_build",
  "prompt": {
    "template_zh": "我___考虑这个问题",
    "vi_hint": "Tôi đang cân nhắc vấn đề này",
    "options": ["在", "了", "过", "要"]
  },
  "correct_answer": "在"
}
```

### 5.3. Distractor generation rules

Quy tắc chung khi sinh distractors (cho mọi multiple choice):

1. **Cùng difficulty**: distractors lấy từ vocab cùng level hoặc level - 1
2. **Cùng POS**: cùng loại từ (verb không pair với noun)
3. **Khác semantic**: distractors KHÔNG cùng `primary_tag` để tránh quá dễ confused
4. **Confusable target**: với character_recognition, ưu tiên distractors có ký tự chung
5. **Số lượng**: mặc định 3 distractors + 1 correct = 4 options

```typescript
function generateDistractors(target: Vocab, count: 3): Vocab[] {
  const pool = vocabRepo.query(`
    WHERE pos = $1
      AND level BETWEEN $2 AND $3
      AND id != $4
      AND NOT (tags && $5::text[])  // NOT overlap với target tags
  `, [target.pos, target.level - 1, target.level, target.id, target.tags]);

  return shuffle(pool).take(count);
}
```

---

## 6. Combinatorial Collocations Pipeline (asset đã build)

### 6.1. Architecture

```
CollocationsDB (1.434 pairs)  ──┐
                                 ├──> SentenceGenerator ──> 8 câu/từ với metadata
FramesBank (47 frames)         ──┘                          + DiversityScorer
```

### 6.2. CollocationsDB schema

File: `collocations_db.json`

```typescript
interface CollocationsDb {
  version: string;
  verb_object: { [verb_hanzi: string]: CollocationEntry };
  adj_noun: { [adj_hanzi: string]: CollocationEntry };
  measure_noun: { [mw_hanzi: string]: CollocationEntry };
}

interface CollocationEntry {
  head_hanzi: string;
  head_pinyin: string;
  head_vi: string;
  head_level: int;
  head_pos: 'v' | 'adj' | 'mw';
  collocations: CollocationPartner[];
}

interface CollocationPartner {
  object_hanzi: string;
  object_pinyin: string;
  object_vi: string;
  object_level: int;
  frequency: int;        // cao = tự nhiên hơn
  sources: ('mined' | 'example' | 'curated')[];
  scenario: string;      // 'work' | 'study' | 'food' | etc.
}
```

### 6.3. FramesBank schema

File: `frames_bank.json`

```typescript
interface FramesBank {
  version: string;
  frames: SentenceFrame[];
}

interface SentenceFrame {
  id: string;                          // 'F-H2-15'
  zh: string;                          // '我正在{VO}。'
  vi: string;                          // 'Tôi đang {VVO}.'
  slot_types: SlotType[];              // ['VO']
  time: string;                        // 'now' | 'past' | 'future' | 'habitual'
  mood: string;                        // 'progressive' | 'statement' | etc.
  grammar_focus: string;               // 'aspect_正在'
  hsk_level_min: int;
  complexity: int;                     // 1-5
  scenario_blacklist?: string[];       // ['health']
}
```

### 6.4. Generator algorithm

```typescript
function generate(target: string, userLevel: int, count: int): GeneratedSentence[] {
  const vocab = vocabIndex[target];
  const pos = vocab.pos;

  // Get filtered collocations
  let partners = pos === 'v'
    ? collocationsDb.verb_object[target]?.collocations
    : collocationsDb.adj_noun[target]?.collocations;
  partners = filterPartners(partners);  // remove blacklisted, garbage

  // Compatible frames
  const frames = framesBank.frames.filter(f =>
    f.hsk_level_min <= userLevel && f.acceptsTargetPos(pos)
  );

  // Generate with DiversityScorer
  const output = [];
  const usedCombos = new Set<string>();

  while (output.length < count && attempts < count * 8) {
    const frame = randomChoice(frames);
    const partner = randomChoice(partners);

    const combo = `${frame.id}|${partner.scenario}|${frame.time}|${frame.mood}`;
    if (usedCombos.has(combo)) continue;
    usedCombos.add(combo);

    if (frame.scenario_blacklist?.includes(partner.scenario)) continue;

    const sentence = fillFrame(frame, target, partner);
    if (sentence.zh.includes('{')) continue;  // unfilled slots, skip

    output.push(sentence);
  }

  return output;
}
```

### 6.5. DiversityScorer

Dùng key `(frame_id, scenario, time, mood)` làm dedup:
- 1 batch không lặp combo này
- Mỗi tham số đảm bảo phân bố trên ≥ 4 giá trị khác nhau

### 6.6. Stats hiện tại (v1.0)

| Metric | Value |
|---|---|
| Total collocation pairs | 1.434 |
| Verb head words | 287 (49 HSK1, 60 HSK2, 104 HSK3, 145 HSK4) |
| Adj head words | 134 |
| HSK4 verb coverage | 144/275 = 52.4% |
| Total frames | 47 |
| Frames by level | HSK1: 10, HSK2: 15, HSK3: 10, HSK4: 12 |
| Time frames covered | 9 |
| Mood types covered | 37 |

### 6.7. Khi nào fallback Static (2A) vs Combinatorial (2B)

```typescript
function getSentencesForChallenge(target: Vocab, count: int = 4): Sentence[] {
  // Try 2A first (validated static content)
  const static = strategy2A(target, count);
  if (static.length >= count) return static;

  // Fallback 2B (combinatorial)
  const combinatorial = sentenceGenerator.generate({
    targetWord: target.hanzi,
    userHskLevel: user.current_level,
    count: count - static.length,
  });

  // KHÔNG mix - ưu tiên trả về 1 trong 2 nếu cả 2 đều enough
  return static.length > 0 ? static : combinatorial;
}
```

---

## 7. Quy tắc Unlock & Remediation

### 7.1. Lesson complete

Lesson được mark `completed` khi:
- User xem hết các activity `is_required = true`
- Score quiz cuối lesson ≥ 70

Nếu fail (score < 70):
- KHÔNG block, cho phép thử lại immediately
- Nếu fail 3 lần liên tiếp → tạo `remediation_lesson` (xem 7.3)

### 7.2. Module complete

Module được mark `completed` khi:
- Tất cả `core_lessons` complete
- Pass `checkpoint` (test cuối module) score ≥ 70

Nếu fail checkpoint:
- Tạo `remediation_lesson` chứa các item user sai trong checkpoint
- User làm xong remediation → retry checkpoint
- KHÔNG hard-block module sau

### 7.3. Remediation lesson

Khi sinh remediation:
```typescript
function buildRemediation(failedItems: ChallengeAttempt[]): Lesson {
  // Nhóm theo skill type
  const byType = groupBy(failedItems, item => item.challenge.type);

  const activities = [];
  for (const [type, items] of byType) {
    activities.push({
      type: 'remediation_drill',
      content_refs: items.map(i => i.target_id),
      challenges: items.flatMap(i =>
        // Sinh 2-3 challenge cùng type cho mỗi item sai
        challengeGenerator.create(i.target, type, count=3)
      ),
      is_required: true,
    });
  }

  return { id: uuid(), title: 'Ôn tập', activities, pass_score: 70 };
}
```

### 7.4. Path complete

Path được mark `completed` khi tất cả `modules` complete.
Trigger unlock path tiếp theo (nếu có `entry_requirements`).

---

## 8. Roadmap triển khai

### Phase 1 — Setup & Documentation ✓
- [x] Standardize `docs/thuattoan.md` (tài liệu này)
- [x] Define schema CollocationsDB + FramesBank
- [x] Define 5-cấp content model
- [x] Define 4-tầng algorithm

### Phase 2 — Content Loader
- [ ] Implement Tầng 1 Enrichment script
  - [ ] canonical_key generator
  - [ ] frequency_rank calculator
  - [ ] vocab_grammar_links builder
- [ ] Repository layer cho vocab/grammar/conversation
- [ ] Unit tests

### Phase 3 — Deterministic Challenge Generator
- [ ] ChallengeGenerator implementation
- [ ] Distractor generator
- [ ] Strategy 2A (Static reuse) implementation
- [ ] Test với 50 vocab samples

### Phase 3.5 — Combinatorial Collocations ✓
- [x] CollocationsDB built (1.434 pairs)
- [x] FramesBank built (47 frames)
- [x] SentenceGenerator (Dart + Python ref)
- [x] DiversityScorer integrated
- [ ] **TODO**: Augment để cover 80%+ HSK4 verbs (hiện 52.4%)
- [ ] **TODO**: Bổ sung 30+ frames HSK4 advanced

### Phase 4 — Local SRS
- [ ] `hanzify_v1` scheduler implementation
- [ ] SrsCard model + Drift/SQLite migration
- [ ] Card unlock progression (recognition → recall → character)
- [ ] dueNow query optimization

### Phase 5 — Unlock & Progress
- [ ] LearningPathSelector
- [ ] SessionBuilder với review debt logic
- [ ] Module/Lesson completion tracking
- [ ] Remediation lesson generator

### Phase 6 — Supabase Sync
- [ ] Sync user_srs_cards
- [ ] Sync user_lesson_progress
- [ ] Sync user_module_progress
- [ ] Conflict resolution (last-write-wins for v1)

### Phase 7 — Advanced (future)
- [ ] FSRS thật replace `hanzify_v1`
- [ ] Slot-filling tự do với constraint engine
- [ ] LLM-augmented content generation
- [ ] Pre-generation batch (10K+ câu) lưu Supabase
- [ ] Pronunciation scoring (Azure Speech)
- [ ] Cross-user analytics

---

## 9. Decision log

### Quyết định lớn

| Quyết định | Khi nào | Tại sao |
|---|---|---|
| Không AI runtime | Phase 1 | Cost + latency + offline-first |
| Combinatorial thay slot-filling | Phase 1 | Slot-filling rủi ro câu sai ngữ pháp |
| `hanzify_v1` thay FSRS thật | Phase 1 | FSRS calibration cần data, v1 chưa có |
| 1 SRS card/từ ban đầu | Phase 1 | Tránh user mới quá tải review |
| Canonical key thay vocab_id cho SRS | Phase 1 | 366 vocab trùng mặt chữ giữa các level |
| Dùng dataset có sẵn, không pre-generate | Phase 1 | Tận dụng 4.500 câu validated |
| 70/30 review/new (debt-aware) | Phase 1 | Cân bằng SRS effectiveness vs progression |

### Mâu thuẫn cũ đã giải quyết

| Mâu thuẫn cũ | Giải pháp final |
|---|---|
| FSRS từ đầu vs hanzify_v1 | hanzify_v1, schema FSRS-ready |
| Slot-filling vs combinatorial | Combinatorial cho v1, slot-filling Phase 7 |
| Pre-generate 9000 câu vs on-demand | On-demand qua Generator + Static reuse |
| Tạo nhiều SRS card/vocab vs 1 | 1 card → unlock thêm theo progression |
| Hard-block fail vs remediation | Remediation, không block |

---

## 10. Glossary

| Term | Định nghĩa |
|---|---|
| **Canonical key** | Key duy nhất identify 1 vocab unit. Format: `{hanzi}_{pinyin}` |
| **Collocation** | Cụm từ thường đi cùng nhau (`喝水`, `打电话`) |
| **Frame** | Câu khung đã validate ngữ pháp với slot rỗng (`今天我{VO}`) |
| **Chunk** | Cụm từ validated được nhét vào slot của frame |
| **Review debt** | Số card SRS quá hạn chưa review |
| **Remediation** | Lesson sinh ra khi user fail, ôn tập các item sai |
| **Bridge module** | Module dùng tạm khi content chưa đủ (vd HSK3 conversation) |
| **Diversity score** | Metric đo độ đa dạng output của Generator |
| **hanzify_v1** | Scheduler SRS đơn giản v1 của project |
| **FSRS-ready** | Schema lưu fields stability/difficulty để Phase 7 swap dễ |

---

## Appendix A — File mapping

```
docs/
  thuattoan.md                    ← THIS FILE (source of truth)

assets/
  collocations_db.json            ← Combinatorial DB
  frames_bank.json                ← Frame templates
  hsk1.json ... hsk4.json         ← Original vocab
  grammar_hsk1.json ... hsk4.json ← Original grammar
  conversation.json               ← Original hội thoại

lib/
  algorithms/
    sentence_generator.dart       ← Combinatorial Generator
    srs_scheduler.dart            ← hanzify_v1 implementation
    challenge_generator.dart      ← Quiz format builder
    session_builder.dart          ← 70/30 review/new mixer
    learning_path_selector.dart   ← Next lesson chooser
  models/
    canonical_key.dart
    srs_card.dart
    challenge.dart
    sentence_frame.dart
    collocation.dart
```

## Appendix B — Test plan (cho mỗi component)

| Component | Test cases bắt buộc |
|---|---|
| `canonical_key generator` | 366 trùng → 366 cặp keys distinct |
| `SrsScheduler.review` | Mỗi rating 1-4: interval/ease change đúng |
| `SrsScheduler.dueNow` | Trả đúng cards quá hạn, sort ASC by due_date |
| `SessionBuilder` | debt=0 → 30/70, debt>30 → 70/30, debt>100 → 90/10 |
| `Interleaving` | Không 2 challenge cùng tag liền nhau |
| `DistractorGenerator` | 3 distractors cùng pos, khác tags, khác answer |
| `SentenceGenerator` | 8 câu/từ với 5+ unique frames + 3+ scenarios |
| `Remediation builder` | Nhóm theo type, sinh 2-3 challenge/item sai |
