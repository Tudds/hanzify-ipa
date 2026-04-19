# Ranking Algorithm

Dùng để **xếp hạng các node sinh ra từ graph expansion** — vd user mở conversation `conv_greeting_01`, expand ra 40 vocab + 6 grammar → show top N trong panel "Context".

---

## Phase 1 — Static-only (no user data)

```
score(node) = w_freq · freq_norm
            + w_novelty · novelty
            + w_coverage · coverage_gap
            + w_level · level_match
```

### Components

**`freq_norm`** — độ phổ biến của node trong toàn dataset, `log(1+count) / log(1+maxCount)`. Precomputed ở build, stored in `nodes.json`.

**`novelty`** — tần suất xuất hiện trong **conversation hiện tại**. Từ xuất hiện 3 lần trong 1 hội thoại thì đáng học hơn từ chỉ lướt qua 1 lần.
```
novelty = occurrences_in_current_context / total_occurrences_dataset-wide
```
(Normalize 0-1. Lưu sẵn trong `conv_to_vocab.json` qua field `occurrences`.)

**`coverage_gap`** — HSK level của node so với level conversation. Match level → cao; cao hơn level conversation → penalize (out of scope).
```
coverage_gap = 1.0 if node.level == ctx.level
             = 0.6 if node.level < ctx.level
             = 0.3 if node.level == ctx.level + 1
             = 0.0 otherwise
```

**`level_match`** — binary flag: node có HSK level ≤ level hiện tại user đang học không. Phase 1 default 1.0 (chưa track user level).

### Trọng số mặc định (Phase 1)

| Weight | Value | Lý do |
|---|---|---|
| `w_novelty` | 0.5 | Tín hiệu mạnh nhất cho "đáng học trong context này" |
| `w_coverage` | 0.3 | Tránh show từ quá khó |
| `w_freq` | 0.15 | Tần suất toàn dataset — tie-breaker |
| `w_level` | 0.05 | Placeholder, bump lên khi có user level tracking |

**Tổng = 1.0.** Tune bằng A/B sau.

---

## Phase 2 — Thêm reverse lookup context

Khi user tap vào 1 vocab `V` → show "các hội thoại dùng từ này" + "các câu ví dụ" → rank conversations/sentences:

```
score(conv | tapped V) = w_density · density
                       + w_level · coverage_gap(conv.level)
                       + w_familiarity · familiarity
```

- `density` = `occurrences(V in conv) / total_lines(conv)` — hội thoại mà V xuất hiện nhiều thì là context tốt để thấy V "sống".
- `familiarity` (Phase 1 skip, Phase 2 optional) — % vocab trong conv này user đã gặp ở nơi khác. Cần mastery data → Phase 3.

---

## Phase 3 — Thêm dynamic signals (Drift)

```
score += w_due · sm2_due_pressure
       + w_err · recent_error_rate
       + w_recency · (-log recency)
```

- `sm2_due_pressure`: các node đang due theo SM-2 → bump lên top.
- `recent_error_rate`: nodes user vừa sai → show lại.
- `-log recency`: node lâu không gặp → bonus nhẹ.

Weights sẽ **không** học tự động ở Phase 3; fix-tune thủ công. EMA/Bayesian update chỉ động đến Phase 4.

---

## Tie-breaking

1. Higher `freq_norm` (phổ biến → ưu tiên).
2. Lower HSK level (dễ trước).
3. Stable sort theo ID để reproducible.

---

## Implementation notes (Flutter)

- Thuật toán là **pure function** trong `lib/core/graph/ranking.dart`, không phụ thuộc Flutter.
- Đầu vào: `List<NodeWithContext>` + `RankingContext { currentLevel, currentConvId, ... }` + `RankingWeights`.
- Đầu ra: `List<ScoredNode>` sorted desc.
- Test dễ: cho fixture đầu vào, assert thứ tự.

Không viết as class; hàm top-level theo convention dự án (xem `lib/features/vocab/domain/review_algorithm.dart`).

---

## Khi nào **không** dùng ranking?

- Flashcard queue — vẫn dùng SM-2 thuần, không trộn context graph.
- Vocab list toàn app — dùng sort theo level + alphabet, không qua ranker.

Ranker chỉ active trên **context surfaces**: conversation detail, vocab detail (related), grammar detail (examples).
