# Graph Schema — Hanzify Context Graph

**Mô hình:** Hybrid Graph
- **Static layer (offline, JSON):** structural edges — precomputed ở build-time, ship kèm `assets/data/graph/`.
- **Dynamic layer (runtime, Drift):** user mastery, weight, due-date. Phase 3. Phase 1–2 **chưa dùng**.

Tất cả Phase 1–2 chỉ dựa vào static layer.

---

## 1. Node types

| Node | Nguồn ID | Ví dụ | File gốc |
|---|---|---|---|
| `vocab` | `hsk{L}_{idx}` | `hsk1_0000` | `hsk1.json`, `hsk2.json`, `hsk3.json` |
| `grammar` | `g_{slug}` | `g_svo` | `grammar_hsk{L}.json` |
| `conversation` | `conv_{topic}_{idx}` | `conv_greeting_01` | `conversation.json` |
| `sentence` | `{conv_id}#L{lineIdx}` hoặc `{vocab_id}#ex{idx}` | `conv_greeting_01#L0`, `hsk1_0000#ex0` | inline trong conversation/vocab |
| `character` | `char_{hanzi}` | `char_你` | `char_hsk{L}.json` |
| `topic` | `topic_{category}` | `topic_greeting` | suy ra từ `conversation.category` |

**Quy ước:** ID phải là **stable** — không đổi giữa các bản build, vì Drift dynamic layer reference vào.

---

## 2. Static artifact (precomputed)

Build script tạo ra:

```
assets/data/graph/
├── nodes.json          # thin index: {id, type, level, label}[]
├── edges.json          # tất cả structural edges
├── inverted/
│   ├── vocab_to_conv.json      # vocabId → [convId...]
│   ├── vocab_to_sentence.json  # vocabId → [sentenceId...]
│   ├── grammar_to_sentence.json
│   ├── conv_to_vocab.json      # convId → [vocabId...] (với span)
│   └── conv_to_grammar.json
└── meta.json           # version, generated_at, counts
```

**Lý do tách inverted index:** Phase 1 (conversation → expand) load 1 file `conv_to_vocab.json`, Phase 2 (tap vocab → reverse) load 1 file `vocab_to_conv.json`. Không cần parse toàn graph → web load nhanh.

---

## 3. Node payload

Node chỉ giữ **tối thiểu** trong `nodes.json` (label + level để hiển thị badge). Chi tiết đầy đủ vẫn đọc từ dataset gốc đã có (`hsk{L}.json`, ...).

```json
{
  "id": "hsk1_0000",
  "type": "vocab",
  "level": 1,
  "label": "爱"
}
```

→ tránh duplicate dữ liệu, graph chỉ là **index over existing data**.

---

## 4. Edge payload

```json
{
  "from": "conv_greeting_01#L1",
  "to": "hsk1_0234",
  "type": "contains_vocab",
  "span": { "start": 3, "end": 5 },
  "weight": 1.0
}
```

- `span`: byte-offset trong `zh` của sentence, dùng để **highlight** khi user tap.
- `weight`: static importance (tần suất xuất hiện toàn dataset, normalize 0-1). Phase 1 có thể bỏ qua, default 1.0.

Các edge type đầy đủ xem `edge_types.md`.

---

## 5. Build pipeline

```
scripts/build_graph.dart
  1. Load hsk{1,2,3}.json, grammar_hsk{1,2,3}.json, conversation.json
  2. Tokenize mỗi sentence (zh) → match longest-prefix với vocab trie
  3. Pattern-match grammar (regex hoặc structural rule) trên sentence
  4. Build inverted indices
  5. Compute weight = log(1 + freq) / max_log_freq
  6. Write assets/data/graph/*.json
```

**Tokenizer:** dùng longest-match trên từ điển vocab đã có. Phase 1 chấp nhận miss — không cần jieba. Word boundary sai 5-10% ổn với HSK1-3 vì câu ngắn.

**Grammar matching:** Phase 1 chỉ cần mapping thủ công trong metadata của grammar (vd `g_svo` → "mọi câu khẳng định có V"). Có thể bỏ qua auto-match, để grammar authors tag thủ công trong grammar JSON qua field mới `matches: [convId#line, ...]`.

---

## 6. Runtime loading

| Khi | Load gì |
|---|---|
| App init | `meta.json` (check version) |
| Mở màn Conversation detail | `conv_to_vocab.json`, `conv_to_grammar.json` |
| Tap vào 1 vocab | `vocab_to_conv.json`, `vocab_to_sentence.json` (lazy) |
| Tap vào 1 grammar | `grammar_to_sentence.json` (lazy) |

Tất cả JSON < 500KB per file cho HSK1-3 — chấp nhận được cho web (1 lần HTTP).

---

## 7. Versioning

`meta.json`:
```json
{
  "graphVersion": 1,
  "dataHash": "sha256:...",
  "generatedAt": "2026-04-19T..."
}
```

Khi `graphVersion` tăng, Drift dynamic layer **không** cần migration vì chỉ ref qua ID. Nếu ID schema đổi (breaking), bump `graphVersion` + viết migration xoá weights không còn valid.
