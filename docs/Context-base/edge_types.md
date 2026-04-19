# Edge Types

Direction: `from → to`. Tất cả edges **directed**; cần traverse ngược → dùng inverted index.

---

## Phase 1 edges (bắt buộc cho "Conversation → expand")

### `contains_vocab`
`Sentence → Vocab`
Một câu trong hội thoại/ví dụ chứa từ vựng.
- `span: {start, end}` — offset char trong `zh` để highlight.
- `weight: 1.0` (neutral).
- **Cardinality:** N-N. Một câu có nhiều từ, một từ xuất hiện trong nhiều câu.

### `uses_grammar`
`Sentence → Grammar`
Câu minh hoạ cho một grammar pattern.
- `span: {start, end}` optional — vị trí marker (vd vị trí `是` trong pattern SVO).
- **Source Phase 1:** thủ công, tag trong `grammar_hsk{L}.json` qua field mới:
```json
{ "id": "g_svo", "examples": ["conv_greeting_01#L1", "hsk1_0234#ex0", ...] }
```

### `belongs_to_conv`
`Sentence → Conversation`
Sentence là 1 line của 1 conversation (parent-child).
- Auto-derive từ `{conv_id}#L{idx}`.
- **Cardinality:** N-1.

### `has_topic`
`Conversation → Topic`
- Derive từ `conversation.category`.
- **Cardinality:** N-1.

---

## Phase 2 edges (reverse lookup — tap vocab → gợi ý hội thoại)

### `appears_in_conv` *(inverse of `contains_vocab` qua `belongs_to_conv`)*
`Vocab → Conversation`
- **Derived**, không lưu — sinh ra ở build-time trong `vocab_to_conv.json` với count:
```json
"hsk1_0234": [
  {"convId": "conv_greeting_01", "occurrences": 3, "firstLine": 1},
  {"convId": "conv_intro_02", "occurrences": 1, "firstLine": 4}
]
```

### `example_of_vocab`
`Sentence → Vocab` (stronger than `contains_vocab`)
- Câu được author chỉ định làm ví dụ chính (field `exampleSentences` trong vocab JSON).
- Phân biệt với `contains_vocab`: đây là **curated**, dùng ưu tiên khi show tooltip.

### `composed_of`
`Vocab → Character`
- `hsk1_0234 (你好) → [char_你, char_好]`.
- Đã có sẵn trong `vocab.characters[]`, chỉ cần reshape.

---

## Phase 3 edges (dynamic, Drift — chưa implement)

| Edge | Ý nghĩa | Lưu ở |
|---|---|---|
| `prereq_of` | A cần học trước B | static seed + user override |
| `reviewed_at` | user đã ôn node X lúc T | Drift `user_interactions` |
| `mastered` | user đã thuộc (SM-2 quality ≥ 4) | Drift `user_mastery` |

---

## Cardinality cheatsheet

| From → To | Typical fanout (HSK1) |
|---|---|
| Conversation → Sentence | ~6-10 |
| Sentence → Vocab | ~3-8 |
| Sentence → Grammar | ~0-2 |
| Vocab → Character | ~1-3 |
| Vocab → Conversation (reverse) | **median 2, max ~30** |
| Grammar → Sentence (reverse) | **median 5, max ~50** |

→ Edge count HSK1 ước tính ~15k. JSON ~400KB. OK cho web load một lần.

---

## Edge quality flag (optional Phase 2)

Thêm field `source` để debug và ưu tiên ranking:
- `"authored"` — tác giả chỉ định (trust cao).
- `"auto_tokenized"` — longest-match tokenizer (có thể sai).
- `"auto_regex"` — grammar pattern match (có thể noise).

Phase 1 chưa cần; Phase 2 bật để filter noise khi reverse lookup.
