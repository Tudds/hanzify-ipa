# Learning Flow — Phase 1 & 2

Mô tả luồng UX end-to-end map xuống provider/repository.

---

## Phase 1 — Conversation as entry point

### Flow
```
User tap conversation card
   ↓
ConversationDetailScreen mount
   ↓
conversationContextProvider(convId).load()
   ├─ Load conversation từ ConversationRepository
   ├─ Load conv_to_vocab.json → vocab IDs + occurrences + spans
   ├─ Load conv_to_grammar.json → grammar IDs
   ├─ Hydrate vocab details qua VocabRepository.getByIds()
   └─ Hydrate grammar details qua GrammarRepository.getByIds()
   ↓
Ranker.rankContextNodes(vocabs + grammars, ctx)
   ↓
UI render:
   ├─ Hội thoại lines (zh/pinyin/vi) với tap-highlights (dùng spans)
   ├─ Panel "Từ vựng bài" — top-N vocab sorted by score, badge occurrences
   └─ Panel "Ngữ pháp bài" — grammar items với câu minh hoạ inline
```

### Interactions
- **Tap từ trong line** → bottom sheet vocab detail (Phase 2 flow).
- **Tap grammar pill** → Grammar detail screen.
- **Tap câu** → TTS (reuse existing).

### Caching
`conversationContextProvider` dùng `@Riverpod(keepAlive: true)` — conversation detail lặp lại nhiều, cache cả session.

---

## Phase 2 — Reverse lookup khi tap vocab

### Flow
```
User tap một từ trong bất kỳ screen nào
   ↓
VocabDetailSheet(vocabId) mở
   ↓
vocabContextProvider(vocabId).load()
   ├─ Vocab entity từ VocabRepository
   ├─ Load vocab_to_conv.json (lazy, cache) → conv list với density
   ├─ Load vocab_to_sentence.json → sentences chứa vocab
   └─ (đã có) characters từ vocab.characters
   ↓
Ranker.rankRelatedConversations(convs, ctx)
   ↓
UI render:
   ├─ Header: hanzi/pinyin/nghĩa (đã có)
   ├─ "Xuất hiện trong hội thoại" — top 3-5 conv cards, badge "X lần"
   ├─ "Câu ví dụ trong ngữ cảnh" — 3-5 sentences với highlight span
   └─ "Cấu tạo" — characters (đã có)
```

### Cross-linking
Tap một card hội thoại → navigate sang ConversationDetailScreen với `initialHighlightVocab: vocabId` để auto-scroll đến line đầu chứa từ đó.

---

## Phase 3 — (placeholder) Learning Path

Chưa implement. Khi có:
- Track `user_interactions` trong Drift (node_id, action, timestamp).
- Compute `due_nodes` từ SM-2 + coverage gap.
- Sinh playlist: conversation → mini-quiz → next conversation, tất cả nối bằng graph.

---

## Provider map (Riverpod)

| Provider | File đề xuất | Scope |
|---|---|---|
| `graphManifestProvider` | `lib/core/graph/graph_manifest_provider.dart` | app-wide, load `meta.json` once |
| `conversationContextProvider(id)` | `lib/features/conversation/.../providers/` | family, keepAlive |
| `vocabContextProvider(id)` | `lib/features/vocab/.../providers/` | family, keepAlive |
| `grammarContextProvider(id)` | `lib/features/grammar/.../providers/` | family, keepAlive |

Tất cả **đọc từ static JSON** — không touch Drift ở Phase 1-2 ngoại trừ user preferences hiện có.

---

## Web vs Native

Static graph JSON **giống nhau** cả 2 platform — load qua `rootBundle.loadString()`. Không cần conditional import cho graph layer.

Chỉ phần dynamic (Phase 3, Drift) mới cần pattern stub-web như hiện có với `app_database_stub.dart`.

---

## Error handling

- `graphManifest` fail load → degrade gracefully: conversation vẫn show được (lines), chỉ panel context trống + banner "Không tải được dữ liệu ngữ cảnh".
- Version mismatch (`meta.graphVersion` khác app expect) → ignore graph, log warning. App vẫn chạy.
- Thiếu 1 vocab ID trong edge → skip node đó, không crash.

Graph là enhancement layer, **không phải** critical path. Không block UI nếu load fail.
