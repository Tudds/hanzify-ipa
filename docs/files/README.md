# HSK Combinatorial Sentence Generator — v1.0

Hệ thống generate câu tiếng Trung đa dạng cho học HSK1-4, **không dùng AI runtime**, ghép `CollocationsDB × FramesBank` để cho ra câu mới mà vẫn đúng ngữ pháp.

---

## Pipeline

```
CollocationsDB (1.156 cặp)  ──┐
                              ├──> Generator ──> 8 câu/từ với metadata
FramesBank (47 frames)     ──┘                  + DiversityScorer
```

## Files

| File | Vai trò | Format |
|---|---|---|
| `collocations_db.json` | Cụm collocations cho HSK1-4 vocab | JSON, 404 KB |
| `frames_bank.json` | 47 sentence frames HSK1-4 | JSON, 15 KB |
| `sentence_generator.dart` | Dart classes + Generator code | Dart, ready for Flutter |
| `sentence_generator.py` | Python reference implementation | Python (cho test/curation) |
| `sample_output.json` | Output mẫu cho 12 từ HSK1-4 (8 câu/từ = 96 câu) | JSON test fixture |
| `hsk4_curated.py` | Source curated entries Tier 1 (167 verbs) | Python |
| `hsk4_curated_batch2.py` | Source curated entries Tier 2 (85 verbs HSK4-only) | Python |

## CollocationsDB stats

- **360 head verbs/adj** với collocations
- **1.434 cặp collocations** total
- **Sources mix**: mined từ 4.201 câu corpus + extracted từ examples + curated 246 verb HSK4-priority
- **HSK4 verbs covered**: 144/275 truly-HSK4 verbs (52.4%) + 49 HSK1, 60 HSK2, 104 HSK3
- **Scenario tags**: work, study, food, dining, shopping, health, transport, travel, weather, emotion, leisure, sports, tech, social, time, family, school, place, general

## FramesBank stats

- **47 frames** total
- **HSK1**: 10 frames (basic SVO, time adverbs, 不/吗 question)
- **HSK2**: 15 frames (了/过/正在 aspect, modal 想/要/会/可以, comparison 比)
- **HSK3**: 10 frames (conditional 如果, simultaneous 一边, concession 虽然)
- **HSK4**: 12 frames (无论, 不仅而且, 通过, 对于, 越来越, 经过, 由于)
- **9 time frames** × **37 mood types** → diverse contexts

---

## Sử dụng (Dart/Flutter)

```dart
// 1. Load DBs (1 lần khi app khởi động)
final collocationsJson = await rootBundle.loadString('assets/collocations_db.json');
final framesJson = await rootBundle.loadString('assets/frames_bank.json');

final db = await CollocationsDb.fromAsset(collocationsJson);
final bank = await FramesBank.fromAsset(framesJson);
final vocabIndex = await loadVocabIndex(); // your existing vocab loader

// 2. Khởi tạo Generator
final gen = SentenceGenerator(
  collocationsDb: db,
  framesBank: bank,
  vocabIndex: vocabIndex,
);

// 3. Generate cho 1 từ target
final sentences = gen.generate(
  targetWord: '考虑',
  userHskLevel: 4,    // chỉ frames hskLevelMin <= 4
  count: 8,
  enforceDiversity: true,
);

// 4. Sử dụng output
for (final s in sentences) {
  print('${s.zh} — ${s.vi}');
  print('  Frame: ${s.frameId} | ${s.frameGrammar}');
  print('  Context: ${s.scenario} | ${s.time} | ${s.mood}');
}

// 5. Optional: diversity check
final report = gen.diversityReport(sentences);
print('Diversity: ${report.uniqueFrames} frames, '
      '${report.uniqueScenarios} scenarios');
```

## Sample output (cho từ 考虑 HSK4)

```
1. 我喜欢考虑问题。           — Tôi thích suy nghĩ vấn đề.
   [F-H1-08 | verb_chain_喜欢 | scenario=work | mood=preference]

2. 他也考虑情况。             — Anh ấy cũng suy nghĩ tình hình.
   [F-H2-10 | adverb_也 | scenario=work | mood=addition]

3. 我可以考虑情况吗？          — Tôi có thể suy nghĩ tình hình không?
   [F-H2-07 | modal_可以 | scenario=work | mood=permission_q]

4. 我不考虑建议。             — Tôi không suy nghĩ đề nghị.
   [F-H1-06 | negation_不 | scenario=work | mood=negation]

5. 我为了健康而考虑问题。       — Tôi suy nghĩ vấn đề vì sức khỏe.
   [F-H3-06 | purpose_为了_而 | scenario=work | mood=purpose]

6. 经过仔细考虑，我决定考虑方法。 — Sau khi cân nhắc kỹ, tôi quyết định suy nghĩ cách.
   [F-H4-08 | sequence_经过 | scenario=work | mood=decision_after_thought]

... 8 câu, 8 frames, 8 moods khác nhau
```

---

## Architectural decisions (tại sao xây vậy)

### 1. Vì sao tách CollocationsDB ra khỏi FramesBank?
- **CollocationsDB** thay đổi liên tục (mine + curate dần các vocab mới)
- **FramesBank** thay đổi chậm (build 1 lần, dùng nhiều năm)
- Tách ra để build/scale 2 thứ độc lập

### 2. Vì sao đa nguồn (mined + example + curated)?
- **Mined** (corpus): cho collocations xuất hiện trong HSK1-4 corpus thực tế → tự nhiên
- **Example**: mỗi vocab có 1 example sentence → đảm bảo coverage cơ bản
- **Curated**: bổ sung cho HSK4 priority verbs mà corpus thiếu

### 3. Vì sao có DiversityScorer?
- Tránh user gặp 8 câu kiểu `我看书`/`他看书`/`我们看书` (cùng frame, cùng partner)
- Force phân bố trên (frame × scenario × time × mood)

### 4. Vì sao có blacklist?
- Auto-mining sinh ra một số false-positive (như `丰富日`, `解决就业`)
- Production cần curation manual để sạch dần

---

## Roadmap mở rộng

| Phase | Việc | Ước tính |
|---|---|---|
| **Hiện tại (v1.0)** | 1.156 collocations + 47 frames + Generator chạy | ✓ Done |
| **v1.1** | Mở rộng CollocationsDB lên 3000+ pairs (cover 200+ HSK4 verbs) | 1-2 tuần curation |
| **v1.2** | Thêm 30+ frames (HSK4 advanced patterns) | 3-5 ngày |
| **v1.3** | Pre-generate batch lưu Supabase, replace runtime generation | 1 tuần |
| **v2.0** | Add semantic constraints (ví dụ frame F-H4-04 chỉ với adj evolutionary) | 2-4 tuần |
| **v3.0** | Slot-filling tự do với constraint engine (Phase 7 trong plan) | 1-2 tháng |

---

## Known limitations (v1.0)

1. **47.6% HSK4 verb coverage thiếu** — 131/275 truly-HSK4 verbs chưa có collocations curated. Có 2 file batch (`hsk4_curated.py` + `hsk4_curated_batch2.py`) làm template để bạn tự bổ sung tier 3.
2. **Adjective frames hạn chế** — chỉ 10 frame ADJ vs 30+ frame VO. Cần bổ sung.
3. **Scenario blacklist sơ khai** — chỉ block "progressive + health". Cần thêm rules từ user feedback.
4. **VI gloss đôi khi awkward** — vì lấy nghĩa đầu tiên, đôi khi không khớp ngữ cảnh. Production có thể cần vocab có `vi_short` field.
5. **Generator deterministic per-seed** — cùng seed cho cùng output. Production nên dùng datetime seed hoặc user state.

## Đối chiếu với plan `docs/thuattoan.md`

Pipeline này map vào:
- **Tầng 1 (Enrichment)**: CollocationsDB + FramesBank = enriched metadata
- **Tầng 2 (Content Composition)**: Strategy 2B = Combinatorial collocations
- **Tầng 3 (Lesson Selection)**: Generator được gọi từ ChallengeGenerator
- **Tầng 4 (Lesson Packaging)**: Output sentences đưa vào Quiz formats (`vocab_match`, `sentence_order`, `vocab_recall`)

Phù hợp với spec:
- ✓ Không AI runtime
- ✓ Dùng dataset HSK1-4 hiện có
- ✓ Không cần 9000 câu pre-generated (generate on-demand)
- ✓ Schema FSRS-ready: output có `complexity` field cho SRS difficulty
