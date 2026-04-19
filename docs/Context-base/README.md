# Context Graph — Design Docs

Thiết kế cho **Hybrid Context Graph** liên kết Vocabulary ↔ Grammar ↔ Conversation để tăng ngữ cảnh học và độ tương tác.

## Nguyên tắc
- **Static (offline JSON)** + **Dynamic (Drift, Phase 3)**.
- Web-first, load nhanh qua inverted-index JSON chia nhỏ.
- Graph chỉ là **index over existing data**; không duplicate nội dung.
- Non-blocking: graph fail → app vẫn chạy (degrade panel context).

## Phase roadmap
1. **Phase 1 — Conversation → expand.** Mở hội thoại → panel vocab/grammar rank theo density + level. *← Next up.*
2. **Phase 2 — Reverse lookup.** Tap vocab/grammar → thấy mọi conversation/sentence dùng nó.
3. **Phase 3 — Learning path.** Dynamic weight + SM-2 + mastery. Sau khi có user data.

## Index
- [`graph_schema.md`](graph_schema.md) — node/edge model, ID conventions, static artifact structure, build pipeline.
- [`edge_types.md`](edge_types.md) — danh mục edge types theo phase, cardinality, quality flags.
- [`ranking_algorithm.md`](ranking_algorithm.md) — công thức scoring + weights cho từng phase.
- [`learning_flow.md`](learning_flow.md) — UX flow end-to-end map xuống provider/repository.
- [`api_contract.md`](api_contract.md) — Dart interfaces, DTOs, providers, build script.

## Tài liệu gốc
- [`thuattoan.md`](thuattoan.md) — sketch ban đầu.
- [`context-add.md`](context-add.md) — phản biện + đề xuất hybrid.
- `context-base.svg`, `context-base2.svg` — mermaid diagrams cấu trúc bài học hiện tại.

## Nội dung chưa chốt
- Tokenizer chính thức cho tiếng Trung (longest-match vs jieba port) — xem `graph_schema.md §5`.
- Grammar pattern matching auto hay manual-only — Phase 1 dùng manual tag trong grammar JSON.
- Khi cần upgrade `graphVersion` với Drift Phase 3 → viết migration riêng.
