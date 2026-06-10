# Làm Sạch Sinh Câu HSK — Quality Gate v2 (Plan giao ChatGPT)

> Mục tiêu: pipeline `CollocationsDB × FramesBank → SentenceGenerator` chỉ
> sinh ra câu **đúng ngữ pháp**, **hợp ngữ cảnh**, **dùng ngôn từ tự nhiên
> chuẩn 现代汉语**, không sinh kết hợp vô nghĩa kiểu `参加汉语`, `丰富日子`,
> `我越来越新鲜`, `食品对身体非常新鲜`, `经过仔细考虑，我决定考虑问题`.
>
> Plan này viết để giao thẳng cho ChatGPT thực hiện coding. Ưu tiên **ít
> nhưng chuẩn** — generator được phép trả ít hơn `count` thay vì sinh bừa.

---

## 0. Bối cảnh & file liên quan

| Vai trò | Đường dẫn |
|---|---|
| Generator (Dart) | `lib/core/learning/application/sentence_generator.dart` |
| Wiring vào Flutter | `lib/core/learning/data/learning_asset_repository.dart` |
| Frames bank (asset chính) | `assets/data/generated/frames_bank.json` |
| Frames bank (mirror docs) | `docs/files/frames_bank.json` |
| Collocations DB | `assets/data/generated/collocations_db.json` |
| Generator (Python tham khảo) | `docs/files/sentence_generator.py` |
| Generator (Dart tham khảo) | `docs/files/sentence_generator.dart` |
| Test hiện có | `test/core/learning/learning_asset_repository_test.dart` |
| Test mới (chưa có) | `test/core/learning/sentence_generator_test.dart` |

Quy tắc bắt buộc:
- Mỗi khi sửa file có `part '*.g.dart'` → chạy `dart run build_runner build --delete-conflicting-outputs`. *Sentence generator hiện không dùng codegen — không cần build_runner.*
- `frames_bank.json` ở `assets/` và `docs/files/` phải đồng nhất byte-by-byte.
- Tất cả thay đổi phải pass `flutter analyze` và 4 lệnh test ở §10.

---

## 1. Phân loại lỗi mà generator hiện tại đang sinh ra

| Loại | Ví dụ câu xấu | Nguyên nhân |
|---|---|---|
| **A. Partner rác trong DB** | `参加汉语`, `丰富日`, `考虑能不能` | Auto-mining bằng jieba khớp sai cụm; partner ít nghĩa hoặc thiếu danh từ phụ |
| **B. Frame × scenario lệch** | `食品对身体非常新鲜` (frame health × adj 新鲜) | Frame dành riêng nhóm adj sức khoẻ, nhưng generator chấp nhận mọi adj |
| **C. Frame × POS/semantic lệch** | `我会考虑情况` (会 = ability), `我为了健康而考虑问题` | Frame yêu cầu verb kỹ năng / verb sức khỏe, generator không filter |
| **D. Frame × head property lệch** | `我越来越新鲜` | 越来越 chỉ nhận ADJ đo được trên chính chủ ngữ (人) |
| **E. Template tự đụng target** | `经过仔细考虑，我决定考虑问题` (F-H4-08) | Template chứa sẵn `考虑`; slot lại nhét chính `考虑` |
| **F. Lặp âm tiết / reduplication sai** | `考虑考虑问题` | Verb 2 âm tiết không reduplicate kiểu ABAB liền nhau |
| **G. Pinyin output sai** | pinyin chỉ ghép `head + partner`, thiếu phần khung câu | `_generatedPinyin` ở `learning_asset_repository.dart:179` |
| **H. Bản dịch Việt gượng** | "Tôi muốn đi chơi tiếng Trung" do partner_vi đa nghĩa | `_cleanVi` chỉ cắt theo dấu phẩy, không có override per-pair |

Plan này ưu tiên giải A→F. G–H liệt kê thành **§9 — Optional Phase 2**.

---

## 2. Mô hình mới: Semantic tag ở cả head và partner

Hiện tại generator chỉ phân biệt `pos ∈ {v, adj, n, mw}`. Để chặn lỗi C–D
phải có **semantic class** chi tiết hơn POS. Hai lớp nhãn cần thêm:

### 2.1 Head semantic tags

Áp cho từng head verb/adj. Mỗi head có **0 hoặc nhiều** tag.

| Tag | Mô tả | Ví dụ head |
|---|---|---|
| `verb.skill` | Verb làm được (đi với 会 ability) | 唱(歌), 游(泳), 开(车), 说(汉语), 做(饭), 写(字), 弹(琴) |
| `verb.cognition` | Verb tư duy / cảm nhận | 考虑, 想, 觉得, 了解, 决定, 注意, 反映 |
| `verb.action.physical` | Hành động cụ thể có đối tượng | 吃, 喝, 买, 卖, 看, 听, 写, 画, 打 |
| `verb.movement` | Di chuyển | 去, 来, 走, 跑, 飞, 出发 |
| `verb.communication` | Giao tiếp | 说, 告诉, 讨论, 介绍, 通知, 解释 |
| `verb.daily` | Sinh hoạt thường ngày | 起床, 睡觉, 洗澡, 刷牙, 锻炼, 跑步 |
| `verb.work_study` | Hoạt động học/làm | 学习, 工作, 研究, 复习, 上课, 开会 |
| `verb.healthy` | Hành động vì sức khỏe (gắn với 为了健康) | 锻炼, 跑步, 戒烟, 散步, 运动 |
| `verb.preparable` | Verb hợp với 准备/决定 (intentional action) | 出发, 结婚, 搬家, 报名 |
| `adj.evaluative.health` | Adj đánh giá sức khỏe | 好, 不好, 健康, 有益, 有害 |
| `adj.gradable.person` | Adj tăng tiến áp được lên 我/他 | 紧张, 自信, 熟练, 流利, 高兴, 累 |
| `adj.physical_property` | Tính chất vật lý của vật | 新鲜, 干净, 整齐, 漂亮, 大, 小 |
| `adj.subjective` | Adj cảm xúc của người | 高兴, 难过, 紧张, 累, 满意 |

### 2.2 Partner semantic tags

Áp cho từng object/N. Mỗi partner có **0 hoặc nhiều** tag (mặc định derive
từ `scenario` nếu không khai báo).

| Tag | Mô tả | Ví dụ |
|---|---|---|
| `noun.food` | Thực phẩm/đồ uống | 米饭, 面条, 水果, 牛奶, 茶 |
| `noun.skill_object` | Tân ngữ cho verb kỹ năng | 歌, 钢琴, 车, 汉语, 饭, 字 |
| `noun.event` | Sự kiện (đi với 参加) | 会议, 比赛, 活动, 婚礼, 考试 |
| `noun.abstract` | Khái niệm | 问题, 情况, 原因, 计划, 目标 |
| `noun.place` | Địa điểm | 北京, 公园, 学校, 医院 |
| `noun.tool` | Công cụ (đi với 用) | 手机, 电脑, 现金, 筷子 |
| `noun.media` | Media (đi với 看/听) | 电影, 音乐, 新闻, 书 |
| `noun.body_topic` | Liên quan thân thể (đi với 对身体) | 食品, 蔬菜, 水果, 运动, 烟酒 |
| `noun.subject_only` | Chỉ làm chủ ngữ, không làm tân ngữ | 天气, 时间 |

Lưu ý: thực hiện **kế thừa scenario → semantic** mặc định:
```
scenario "place"     → +noun.place
scenario "food"      → +noun.food
scenario "tech"      → +noun.tool
scenario "transport" → +noun.tool +noun.place
scenario "study"     → +noun.abstract (cho từ trừu tượng) hoặc +noun.event
```
Khi `partner_semantics` được khai báo tường minh thì override default.

### 2.3 Lưu ở đâu

Tạo **2 file mới** (đừng nhồi vào DB cũ — giữ DB schema cũ tương thích):

```
assets/data/generated/head_semantics.json
assets/data/generated/partner_semantics.json
```

Schema:
```jsonc
// head_semantics.json
{
  "version": "1.0",
  "heads": {
    "考虑": ["verb.cognition"],
    "唱":   ["verb.skill", "verb.action.physical"],
    "锻炼": ["verb.healthy", "verb.daily"],
    "新鲜": ["adj.physical_property"]
  }
}

// partner_semantics.json — chỉ liệt kê khi cần override default
{
  "version": "1.0",
  "partners": {
    "汉语":   ["noun.skill_object"],
    "钢琴":   ["noun.skill_object"],
    "会议":   ["noun.event"],
    "食品":   ["noun.body_topic"],
    "天气":   ["noun.subject_only"]
  }
}
```

Để giảm khối lượng curate, **chỉ tag thủ công** các head và partner xuất
hiện trong frames có whitelist nghiêm ngặt (xem §4). Phần còn lại derive
default từ scenario.

---

## 3. Schema mới của `SentenceFrame`

Mở rộng class `SentenceFrame` (file `sentence_generator.dart`, hiện ở dòng
166–233). Tất cả field mới đều **optional** với default backward-compatible
(`generation_enabled = true`, mọi whitelist trống = "không kiểm tra"):

```dart
class SentenceFrame {
  // ====== field cũ — giữ nguyên ======
  final String id;
  final String zhTemplate;
  final String viTemplate;
  final List<SlotType> slotTypes;
  final String time;
  final String mood;
  final String grammarFocus;
  final int hskLevelMin;
  final int complexity;
  final List<String> scenarioBlacklist;

  // ====== field mới — quality gate ======

  /// Tắt frame ở runtime mà không cần xoá dòng JSON.
  final bool generationEnabled;             // default true

  /// Whitelist semantic tag cho head. Nếu rỗng → không kiểm tra.
  /// Frame được chấp nhận khi head có ÍT NHẤT MỘT tag trùng.
  final List<String> headSemanticWhitelist; // default const []

  /// Blacklist semantic tag cho head — chặn nhanh.
  final List<String> headSemanticBlacklist; // default const []

  /// Whitelist semantic tag cho partner. Như trên.
  final List<String> partnerSemanticWhitelist; // default const []
  final List<String> partnerSemanticBlacklist; // default const []

  /// Whitelist scenario partner. Nếu rỗng → không kiểm tra.
  final List<String> partnerScenarioWhitelist; // default const []

  /// Cấm head hanzi xuất hiện đã có trong template (chống case "考虑考虑").
  final bool forbidTargetInTemplate;        // default true (an toàn)

  /// Cấm pattern regex sau khi đã substitute (post-validation).
  final List<String> forbiddenPatterns;     // default const []

  /// Tần suất tối thiểu của partner trong corpus.
  final int minPartnerFrequency;            // default 1

  /// Yêu cầu partner có ít nhất một trong các sources này.
  /// Ví dụ ["curated", "example"] để loại partner mined lẻ.
  final List<String> requiredPartnerSources; // default const []

  /// partner.objectLevel - head.headLevel ≤ giá trị này.
  /// Ví dụ frame HSK1 không nên ghép partner HSK4.
  final int maxPartnerLevelDelta;           // default 99 = không kiểm tra
}
```

JSON tương ứng (mọi field optional, snake_case):
```jsonc
{
  "id": "F-H2-06",
  "zh": "我会{VO}。",
  "vi": "Tôi biết {VVO}.",
  "slot_types": ["VO"],
  "time": "ability",
  "mood": "ability",
  "grammar_focus": "modal_会_ability",
  "hsk_level_min": 2,
  "complexity": 2,

  // mới ↓
  "generation_enabled": true,
  "head_semantic_whitelist": ["verb.skill"],
  "partner_semantic_whitelist": ["noun.skill_object"],
  "forbid_target_in_template": true,
  "forbidden_patterns": []
}
```

`SentenceFrame.fromJson` phải đọc đầy đủ các field optional với default
hợp lý. Viết test riêng cho fromJson để chắc backward-compatible.

---

## 4. Patch frame bank — sửa từng frame có vấn đề

Áp đúng từng patch sau vào **cả** `assets/data/generated/frames_bank.json`
**và** `docs/files/frames_bank.json`. Mọi frame không liệt kê → không đụng.

### 4.1 Frame `F-H2-06` — `我会{VO}。`
Thêm:
```jsonc
"head_semantic_whitelist": ["verb.skill"],
"partner_semantic_whitelist": ["noun.skill_object"]
```
→ chặn `我会考虑情况`, chỉ cho `我会唱歌`, `我会说汉语`, `我会开车`.

### 4.2 Frame `F-H3-06` — `我为了健康而{VO}。`
Thêm:
```jsonc
"head_semantic_whitelist": ["verb.healthy"],
"partner_scenario_whitelist": ["health", "sports", "food"]
```
→ chặn `我为了健康而考虑问题`, chỉ cho `我为了健康而锻炼身体` v.v.

### 4.3 Frame `F-H4-04` — `随着时间的推移，我越来越{ADJ}。`
Thêm:
```jsonc
"head_semantic_whitelist": ["adj.gradable.person", "adj.subjective"],
"head_semantic_blacklist": ["adj.physical_property"]
```
→ chặn `我越来越新鲜`, chỉ cho `我越来越自信/紧张/熟练`.

### 4.4 Frame `F-H4-11` — `{N}对身体非常{ADJ}。`
Thêm:
```jsonc
"head_semantic_whitelist": ["adj.evaluative.health"],
"partner_semantic_whitelist": ["noun.body_topic", "noun.food"]
```
→ chặn `食品对身体非常新鲜`, chỉ cho `蔬菜对身体非常好/有益`.

### 4.5 Frame `F-H4-01` — `我正在考虑{VO}的事。` *(template chứa `考虑`)*
Thêm:
```jsonc
"forbid_target_in_template": true,
"head_semantic_blacklist": ["verb.cognition"]
```
→ chặn 考虑考虑问题 và mọi verb cognition khác.

### 4.6 Frame `F-H4-08` — `经过仔细考虑，我决定{VO}。` *(template chứa `考虑`)*
Thêm:
```jsonc
"forbid_target_in_template": true,
"head_semantic_blacklist": ["verb.cognition"],
"head_semantic_whitelist": ["verb.preparable", "verb.movement", "verb.work_study"]
```

### 4.7 Frame `F-H4-03` — `对于{N},我们要认真{V}。` *(template chứa `认真`)*
Thêm:
```jsonc
"forbid_target_in_template": true,
"head_semantic_whitelist": ["verb.cognition", "verb.work_study", "verb.communication"],
"partner_semantic_whitelist": ["noun.abstract", "noun.event"]
```
+ sửa lỗi space trong template hiện tại (`{N},` → `{N}，` — thay phẩy
nửa-góc bằng phẩy toàn-góc, đúng quy tắc Trung văn).

### 4.8 Frame `F-H3-10` — `{N}非常{ADJ}。`
Thêm:
```jsonc
"head_semantic_blacklist": ["adj.gradable.person"],
"partner_semantic_blacklist": ["noun.subject_only"]
```
→ chặn câu kiểu `天气非常自信`.

### 4.9 Frame `F-H4-10` — `为了将来，我必须{VO}。`
Thêm:
```jsonc
"head_semantic_whitelist": ["verb.preparable", "verb.work_study", "verb.healthy"],
"min_partner_frequency": 2,
"required_partner_sources": ["curated", "example"]
```

### 4.10 Toàn bộ frame còn lại
Thêm mặc định:
```jsonc
"generation_enabled": true,
"forbid_target_in_template": true
```
Field còn lại (whitelist…) để trống. `forbid_target_in_template` phải bật
mặc định để tránh trùng âm tiết khi target là verb 2 chữ (xem §5).

---

## 5. Sửa `SentenceGenerator` — pipeline validator

Refactor file `lib/core/learning/application/sentence_generator.dart`. Mục
tiêu: tách phần "build candidate" và "validate". Mọi rule mới phải đi qua
validator chứ không nhồi vào `_filterPartners` cũ.

### 5.1 Bổ sung tham số constructor

```dart
class SentenceGenerator {
  SentenceGenerator({
    required this.collocationsDb,
    required this.framesBank,
    required this.vocabIndex,
    this.headSemantics = const {},          // hanzi -> Set<String>
    this.partnerSemantics = const {},       // hanzi -> Set<String>
    Set<String>? noisyPairBlacklist,        // "head|partner"
    Set<String>? curatedPairAllowlist,      // ưu tiên mạnh
    int? seed,
  }) : ...;
}
```

`headSemantics` / `partnerSemantics` load từ 2 file JSON mới ở §2.3.
`noisyPairBlacklist` đọc từ file mới `assets/data/generated/sentence_quality_rules.json` (§7).

### 5.2 Hàm derive semantic mặc định

```dart
Set<String> _resolvePartnerSemantics(CollocationPartner p) {
  final explicit = partnerSemantics[p.objectHanzi];
  if (explicit != null && explicit.isNotEmpty) return explicit;
  return _semanticsFromScenario(p.scenario);
}

Set<String> _semanticsFromScenario(String scenario) => switch (scenario) {
  'place'     => {'noun.place'},
  'food'      => {'noun.food'},
  'tech'      => {'noun.tool'},
  'transport' => {'noun.tool', 'noun.place'},
  'study'     => {'noun.abstract'},
  'work'      => {'noun.event', 'noun.abstract'},
  'sports'    => {'noun.event'},
  'health'    => {'noun.body_topic'},
  'leisure'   => {'noun.media', 'noun.event'},
  _           => const <String>{},
};
```

### 5.3 Validator pipeline

Thay block `while (output.length < count …)` (hiện ở dòng ~486) bằng:

```dart
bool _frameAcceptsHead(SentenceFrame f, VocabLite head) {
  if (!f.generationEnabled) return false;
  if (!f.acceptsTargetPos(head.pos)) return false;
  if (f.hskLevelMin > userHskLevel) return false;
  final hs = headSemantics[head.hanzi] ?? const <String>{};
  if (f.headSemanticWhitelist.isNotEmpty &&
      !hs.any(f.headSemanticWhitelist.contains)) return false;
  if (f.headSemanticBlacklist.any(hs.contains)) return false;
  if (f.forbidTargetInTemplate &&
      f.zhTemplate.contains(head.hanzi)) return false;
  return true;
}

bool _frameAcceptsPartner(SentenceFrame f, CollocationPartner p) {
  if (f.partnerScenarioWhitelist.isNotEmpty &&
      !f.partnerScenarioWhitelist.contains(p.scenario)) return false;
  if (f.scenarioBlacklist.contains(p.scenario)) return false;
  if (p.frequency < f.minPartnerFrequency) return false;
  if (f.requiredPartnerSources.isNotEmpty &&
      !p.sources.any(f.requiredPartnerSources.contains)) return false;
  if (f.maxPartnerLevelDelta < 99 &&
      p.objectLevel - currentHead.headLevel > f.maxPartnerLevelDelta) {
    return false;
  }
  final ps = _resolvePartnerSemantics(p);
  if (f.partnerSemanticWhitelist.isNotEmpty &&
      !ps.any(f.partnerSemanticWhitelist.contains)) return false;
  if (f.partnerSemanticBlacklist.any(ps.contains)) return false;
  return true;
}

bool _validateBuiltSentence(SentenceFrame f, String zh, String head) {
  // 1. Không còn slot dư
  if (zh.contains('{')) return false;
  // 2. Trùng nguyên đoạn target liền nhau (考虑考虑) khi head ≥ 2 ký tự
  if (head.runes.length >= 2 && zh.contains('$head$head')) return false;
  // 3. Forbidden patterns frame-specific
  for (final pat in f.forbiddenPatterns) {
    if (RegExp(pat).hasMatch(zh)) return false;
  }
  return true;
}
```

### 5.4 Diversity & rejection log

`generate()` trả thêm `RejectionStats` (đếm số lần bị reject theo nguyên
nhân) — chỉ dùng debug, không expose ra UI:

```dart
class RejectionStats {
  int frameDisabled = 0;
  int headSemantic = 0;
  int partnerSemantic = 0;
  int scenarioBlacklist = 0;
  int targetInTemplate = 0;
  int builtPostValidation = 0;
  int diversityCollision = 0;
  int frequencyFloor = 0;
  int sourcesFloor = 0;
  int levelDelta = 0;
}
```

API:
```dart
({List<GeneratedSentence> sentences, RejectionStats stats}) generateWithStats({...});
```
Giữ `generate()` cũ làm wrapper trả `sentences` only — backward-compat.

### 5.5 Bảo đảm "ít nhưng chuẩn"

Vòng lặp generate hiện cap `attempts = count * 8`. Đổi thành **deterministic
exhaust**: lặp **mọi** combo `(frame, partner)` đã shuffle bằng `_random`,
mỗi combo chỉ thử một lần. Khi danh sách cạn mà output < count → trả về
output ngắn hơn `count` (đúng tinh thần plan v1).

---

## 6. Cập nhật `_filterPartners` & `noisyBlacklist`

File hiện hardcode `noisyBlacklist` ở `sentence_generator.dart:401`. Tách
ra:

### 6.1 Xoá literal trong code
Xoá luôn default trong constructor. Luôn yêu cầu pass từ ngoài (load từ
JSON ở §7). Nếu không pass thì empty set.

### 6.2 Mở rộng pair blacklist hiện tại
Bổ sung các pair sau vào `sentence_quality_rules.json` → `pair_blacklist`:
```
打|出租车           # frame past_了 + 出租车 nghe lạ; vẫn cho phép trong frame today/now
参加|汉语           # 参加汉语 không thành cụm (cần 汉语班/课/比赛)
丰富|分钟           # auto-mined garbage
丰富|日子
丰富|日
考虑|能不能
解决|就业
反映|社会
看|医生            # đúng nhưng sinh sai frame; xử lý qua frame whitelist tốt hơn
```
+ giữ nguyên các pair plan v1 đã liệt kê.

### 6.3 Bộ lọc partner-level cứng (vẫn giữ trong code)
Giữ nguyên 2 rule:
- `len(objectHanzi) > 4` → loại
- `objectHanzi ∈ {人, 事, 东西}` → loại

Bổ sung:
- `objectHanzi == headHanzi` (self-loop, ví dụ 学习|学习) → loại
- `objectHanzi.length == 1 && headHanzi.contains(objectHanzi)` → loại
  (chống 丰富|富 sau jieba sai)
- partner thuộc set chức năng đếm/thời gian: `{了, 过, 着, 的, 个, 些}` → loại

---

## 7. File rule mới `sentence_quality_rules.json`

Tạo `assets/data/generated/sentence_quality_rules.json`:

```jsonc
{
  "version": "1.0",
  "pair_blacklist": [
    "考虑|能不能", "解决|就业", "反映|社会",
    "丰富|日", "丰富|分钟", "丰富|日子",
    "看|医生", "打|出租车", "参加|汉语"
  ],
  "pair_allowlist": [
    "唱|歌", "弹|钢琴", "开|车", "做|饭",
    "锻炼|身体", "考虑|问题", "考虑|情况",
    "参加|会议", "参加|比赛", "参加|活动"
  ],
  "global_forbidden_patterns": [
    "(.)\\1{2,}",                       // 1 ký tự lặp ≥ 3 lần
    "我.{0,2}我",                       // "我" lặp gần
    "了了"
  ]
}
```

Loader nằm trong `learning_asset_repository.dart` — xem §8.

---

## 8. Wiring trong `learning_asset_repository.dart`

File: `lib/core/learning/data/learning_asset_repository.dart`

### 8.1 Thêm asset constants
```dart
static const headSemanticsAsset =
    'assets/data/generated/head_semantics.json';
static const partnerSemanticsAsset =
    'assets/data/generated/partner_semantics.json';
static const qualityRulesAsset =
    'assets/data/generated/sentence_quality_rules.json';
```

### 8.2 Sửa `loadGeneratedCollocationPool()`
Trước khi `SentenceGenerator(...)`:

```dart
final headSemantics = _loadSemantics(
    await _maybeLoad(bundle, headSemanticsAsset), 'heads');
final partnerSemantics = _loadSemantics(
    await _maybeLoad(bundle, partnerSemanticsAsset), 'partners');
final rules = _loadRules(await _maybeLoad(bundle, qualityRulesAsset));

final generator = SentenceGenerator(
  collocationsDb: collocationsDb,
  framesBank: framesBank,
  vocabIndex: _vocabIndexFor(collocationsDb),
  headSemantics: headSemantics,
  partnerSemantics: partnerSemantics,
  noisyPairBlacklist: rules.pairBlacklist,
  curatedPairAllowlist: rules.pairAllowlist,
  globalForbiddenPatterns: rules.globalForbiddenPatterns,
  seed: 1,
);
```

### 8.3 `_maybeLoad`
```dart
Future<String?> _maybeLoad(AssetBundle b, String key) async {
  try { return await b.loadString(key); } catch (_) { return null; }
}
```
Mục đích: test cũ không có 3 asset mới vẫn pass.

### 8.4 Đăng ký asset trong `pubspec.yaml`
Thêm 3 dòng vào section `flutter.assets`:
```yaml
- assets/data/generated/head_semantics.json
- assets/data/generated/partner_semantics.json
- assets/data/generated/sentence_quality_rules.json
```
*(Nếu đang dùng glob `assets/data/generated/` thì không cần — kiểm tra
trước khi thêm để tránh duplicate.)*

---

## 9. Optional Phase 2 (không bắt buộc trong patch này)

Ghi rõ để ChatGPT **không tự ý mở rộng**:

- **G. Pinyin full sentence**: viết module `lib/core/utils/pinyin_full.dart`
  cần dictionary char→pinyin (đã có một phần trong vocab DB). Defer.
- **H. Vietnamese override per-pair**: dùng file `vi_short_overrides_curated_hsk1_3.json`
  đã có sẵn. Cần sửa `_cleanVi` để consult override trước khi cắt phẩy.
  Defer trừ khi user yêu cầu.

---

## 10. Test Plan

### 10.1 Test mới: `test/core/learning/sentence_generator_test.dart`

Mỗi case build `SentenceGenerator` in-memory, KHÔNG load asset thật.

| Case | Input | Expectation |
|---|---|---|
| `T1` | targetWord `新鲜`, có frame F-H4-04 (`越来越{ADJ}`), head_semantics `新鲜→[adj.physical_property]`, frame whitelist `[adj.gradable.person]` | Output không chứa `我越来越新鲜` |
| `T2` | targetWord `新鲜`, frame F-H4-11, partner `食品` mặc định scenario `general` (không thuộc whitelist) | Output không chứa `食品对身体非常新鲜` |
| `T3` | targetWord `考虑`, frame F-H3-06 (`为了健康而{VO}`), partner `问题` | Output không chứa `我为了健康而考虑问题` |
| `T4` | targetWord `考虑`, frame F-H2-06 (`我会{VO}`) | Output không chứa `我会考虑情况` (semantic block) |
| `T5` | targetWord `考虑`, frame F-H4-08 (`经过仔细考虑，我决定{VO}`), `forbid_target_in_template=true` | Frame bị bỏ qua, output không chứa `考虑考虑` |
| `T6` | targetWord `考虑`, partner `问题` lặp 2 lần trong template (giả lập) | Sentence-level validator chặn `考虑考虑问题` |
| `T7` | partners đã filter cạn → còn 1 frame valid; count=8 | Trả ≤ 1 sentence (không tự nhân bản) |
| `T8` | `pair_blacklist` chứa `参加|汉语` | Không sinh `我参加汉语` |
| `T9` | `pair_allowlist` chứa `锻炼|身体`, frame F-H3-06 | Sinh `我为了健康而锻炼身体` |
| `T10` | `generation_enabled=false` cho frame F-H1-01 | Không xuất hiện sentence frameId F-H1-01 |
| `T11` | `RejectionStats.frameDisabled` đếm đúng số frame off | Counter > 0 và khớp số expected |
| `T12` | `SentenceFrame.fromJson` với JSON cũ (không có field mới) | Default values áp đúng (generationEnabled=true, whitelist rỗng) |

### 10.2 Test có sẵn — vẫn phải pass
```
flutter test test/core/learning/learning_asset_repository_test.dart
flutter test test/core/learning/collocation_pool_test.dart
flutter test test/core/learning/quiz_generator_test.dart
flutter test test/features/shorts/shorts_feed_repository_test.dart
flutter test test/core/learning/sentence_generator_test.dart   # mới
```

### 10.3 Lint
```
flutter analyze
```
Phải xanh sạch. Cấm `// ignore_for_file:`.

### 10.4 Smoke kiểm tra số lượng câu
Sau patch, chạy thêm script ad-hoc một lần (Dart `bin/audit_generated.dart`
— viết tạm, không cần commit):
- Generate cho 50 head HSK4.
- Đảm bảo: trung bình ≥ 2 câu/head; **không** chứa bất kỳ chuỗi sau:
  ```
  我越来越新鲜    我会考虑    经过仔细考虑，我决定考虑
  食品对身体非常新鲜    我为了健康而考虑    我参加汉语
  考虑考虑    丰富日    丰富分钟
  ```

---

## 11. Trật tự thực hiện cho ChatGPT

Làm tuần tự, mỗi bước commit riêng để dễ revert:

1. **B1 — Schema mới**
   - Sửa `SentenceFrame` (thêm field + fromJson default).
   - Test `T12` pass.
   - `flutter analyze` xanh.

2. **B2 — Loader & wiring**
   - Tạo 3 file rỗng-template ở `assets/data/generated/`:
     `head_semantics.json` (chỉ version), `partner_semantics.json`,
     `sentence_quality_rules.json`.
   - Sửa `learning_asset_repository.dart` thêm `_maybeLoad` + truyền vào
     constructor. Test cũ vẫn pass.

3. **B3 — Validator pipeline**
   - Refactor `generate()` theo §5.3 + 5.5.
   - Thêm `generateWithStats` + `RejectionStats`.
   - Viết test T1–T11 ban đầu (semantic map dummy in-memory).

4. **B4 — Patch `frames_bank.json` (cả 2 mirror)**
   - Áp 9 patch ở §4.1–4.9 + default `forbid_target_in_template=true` cho
     toàn bộ frame còn lại (§4.10).
   - Sửa phẩy nửa-góc trong F-H4-03.

5. **B5 — Curate semantic JSON**
   - Tag head + partner cho **mọi** từ xuất hiện trong head_semantic_*
     hoặc partner_semantic_* whitelist của các frame đã sửa (§4).
   - Tối thiểu cần tag (xem bảng 2.1 + 2.2): khoảng 60–80 head và 80–120
     partner. Phần còn lại để default scenario-derived.

6. **B6 — Quality rules JSON**
   - Đổ pair_blacklist + pair_allowlist + global_forbidden_patterns theo §7.

7. **B7 — Smoke audit**
   - Chạy `dart run bin/audit_generated.dart` (script tạm).
   - Nếu phát hiện chuỗi cấm còn xuất hiện → quay lại tag bổ sung.

8. **B8 — Cleanup**
   - Xoá literal `noisyBlacklist` mặc định trong constructor
     `SentenceGenerator`.
   - Cập nhật `lib/core/learning/README.md` mô tả ngắn về quality gate.

---

## 12. Acceptance criteria (giao Tu kiểm)

ChatGPT báo "xong" khi đạt **toàn bộ**:

- [ ] `SentenceFrame` có 10 field mới, `fromJson` backward-compatible.
- [ ] `SentenceGenerator` tách validator pipeline; có `generateWithStats`.
- [ ] `frames_bank.json` (2 mirror) áp 9 patch + default
      `forbid_target_in_template`.
- [ ] 3 file mới `head_semantics.json`, `partner_semantics.json`,
      `sentence_quality_rules.json` được commit và đăng ký asset.
- [ ] `learning_asset_repository.dart` load đủ rule + semantic.
- [ ] `test/core/learning/sentence_generator_test.dart` có 12 case T1–T12
      và pass.
- [ ] 4 test cũ ở §10.2 vẫn pass.
- [ ] `flutter analyze` clean.
- [ ] Audit smoke không còn chuỗi cấm ở §10.4.
- [ ] README `lib/core/learning/README.md` cập nhật một đoạn ngắn.

---

## 13. Giả định (giữ nguyên từ plan v1)

- Pipeline vẫn offline 100% — không gọi LLM runtime.
- Không refactor UI/quiz flow.
- Bản dịch Việt vẫn dùng `_cleanVi` cũ; nâng cấp override defer Phase 2.
- Pinyin sentence-level vẫn ghép `headPinyin + partnerPinyin` defer Phase 2.
- Mọi rule mới đều có thể **tắt** bằng cách để whitelist trống — bảo vệ
  backward-compat của các frame chưa được curate kỹ.
