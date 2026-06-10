// ============================================================================
// HSK Sentence Generation System — Dart Class Definitions
// Generated for Combinatorial Collocations Pipeline v1.0
// ============================================================================
//
// Pipeline:
//   CollocationsDB + FramesBank → Generator → GeneratedSentence[]
//
// Usage in Flutter:
//   final gen = SentenceGenerator(
//     collocationsDb: await loadCollocationsDb('assets/collocations_db.json'),
//     framesBank: await loadFramesBank('assets/frames_bank.json'),
//     vocabIndex: await loadVocabIndex(...),
//   );
//   final sentences = gen.generate(targetWord: '考虑', userHskLevel: 4, count: 8);
// ============================================================================

import 'dart:convert';
import 'dart:math';

// ============================================================================
// COLLOCATIONS DB MODELS
// ============================================================================

/// Một collocation entry — partner ghép với head word.
class CollocationPartner {
  final String objectHanzi;
  final String objectPinyin;
  final String objectVi;
  final int objectLevel;

  /// Tần suất xuất hiện trong corpus (cao = tự nhiên hơn)
  final int frequency;

  /// Nguồn gốc: 'mined' | 'example' | 'curated'
  final List<String> sources;

  /// Scenario tag suy ra từ tags của object: 'work', 'study', 'food', etc.
  final String scenario;

  CollocationPartner({
    required this.objectHanzi,
    required this.objectPinyin,
    required this.objectVi,
    required this.objectLevel,
    required this.frequency,
    required this.sources,
    required this.scenario,
  });

  factory CollocationPartner.fromJson(Map<String, dynamic> json) {
    return CollocationPartner(
      objectHanzi: json['object_hanzi'] as String,
      objectPinyin: json['object_pinyin'] as String? ?? '',
      objectVi: json['object_vi'] as String? ?? '',
      objectLevel: json['object_level'] as int? ?? 0,
      frequency: json['frequency'] as int? ?? 1,
      sources: List<String>.from(json['sources'] as List? ?? const []),
      scenario: json['scenario'] as String? ?? 'general',
    );
  }
}

/// Một head word + tất cả collocations của nó.
class CollocationEntry {
  final String headHanzi;
  final String headPinyin;
  final String headVi;
  final int headLevel;
  final String headPos; // 'v' | 'adj' | 'n' | 'mw'
  final List<CollocationPartner> collocations;

  CollocationEntry({
    required this.headHanzi,
    required this.headPinyin,
    required this.headVi,
    required this.headLevel,
    required this.headPos,
    required this.collocations,
  });

  factory CollocationEntry.fromJson(Map<String, dynamic> json) {
    return CollocationEntry(
      headHanzi: json['head_hanzi'] as String,
      headPinyin: json['head_pinyin'] as String? ?? '',
      headVi: json['head_vi'] as String? ?? '',
      headLevel: json['head_level'] as int? ?? 0,
      headPos: json['head_pos'] as String? ?? '',
      collocations: (json['collocations'] as List)
          .map((c) => CollocationPartner.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CollocationsDb {
  final String version;
  final Map<String, CollocationEntry> verbObject; // verb hanzi -> entry
  final Map<String, CollocationEntry> adjNoun; // adj hanzi -> entry
  final Map<String, CollocationEntry> measureNoun; // mw hanzi -> entry

  CollocationsDb({
    required this.version,
    required this.verbObject,
    required this.adjNoun,
    required this.measureNoun,
  });

  factory CollocationsDb.fromJson(Map<String, dynamic> json) {
    Map<String, CollocationEntry> parseSection(String key) {
      final section = json[key] as Map<String, dynamic>;
      return section.map(
        (k, v) =>
            MapEntry(k, CollocationEntry.fromJson(v as Map<String, dynamic>)),
      );
    }

    return CollocationsDb(
      version: json['version'] as String? ?? '1.0',
      verbObject: parseSection('verb_object'),
      adjNoun: parseSection('adj_noun'),
      measureNoun: parseSection('measure_noun'),
    );
  }

  static Future<CollocationsDb> fromAsset(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return CollocationsDb.fromJson(data);
  }
}

// ============================================================================
// FRAMES BANK MODELS
// ============================================================================

/// Loại slot trong frame.
enum SlotType { vo, an, v, n, n2, adj }

extension SlotTypeX on SlotType {
  String get token {
    switch (this) {
      case SlotType.vo:
        return 'VO';
      case SlotType.an:
        return 'AN';
      case SlotType.v:
        return 'V';
      case SlotType.n:
        return 'N';
      case SlotType.n2:
        return 'N2';
      case SlotType.adj:
        return 'ADJ';
    }
  }

  static SlotType fromString(String s) {
    return SlotType.values.firstWhere(
      (e) => e.token == s.toUpperCase(),
      orElse: () => SlotType.vo,
    );
  }
}

/// Một frame template với metadata.
class SentenceFrame {
  final String id;
  final String zhTemplate; // ví dụ: "今天我{VO}。"
  final String pinyinTemplate; // ví dụ: "Jīntiān wǒ {PVO}."
  final String viTemplate; // ví dụ: "Hôm nay tôi {VVO}."
  final List<SlotType> slotTypes;

  // Metadata for DiversityScorer
  final String time; // 'today' | 'past' | 'future' | 'now' | ...
  final String mood; // 'statement' | 'question' | 'negation' | ...
  final String grammarFocus; // ID of grammar point
  final int hskLevelMin;
  final int complexity; // 1-5

  /// Scenario combinations to skip (e.g., progressive + health = awkward)
  final List<String> scenarioBlacklist;
  final bool generationEnabled;
  final List<String> headSemanticWhitelist;
  final List<String> headSemanticBlacklist;
  final List<String> partnerSemanticWhitelist;
  final List<String> partnerSemanticBlacklist;
  final List<String> partnerScenarioWhitelist;
  final bool forbidTargetInTemplate;
  final List<String> forbiddenPatterns;
  final int minPartnerFrequency;
  final List<String> requiredPartnerSources;
  final int maxPartnerLevelDelta;

  SentenceFrame({
    required this.id,
    required this.zhTemplate,
    this.pinyinTemplate = '',
    required this.viTemplate,
    required this.slotTypes,
    required this.time,
    required this.mood,
    required this.grammarFocus,
    required this.hskLevelMin,
    required this.complexity,
    this.scenarioBlacklist = const [],
    this.generationEnabled = true,
    this.headSemanticWhitelist = const [],
    this.headSemanticBlacklist = const [],
    this.partnerSemanticWhitelist = const [],
    this.partnerSemanticBlacklist = const [],
    this.partnerScenarioWhitelist = const [],
    this.forbidTargetInTemplate = true,
    this.forbiddenPatterns = const [],
    this.minPartnerFrequency = 1,
    this.requiredPartnerSources = const [],
    this.maxPartnerLevelDelta = 99,
  });

  factory SentenceFrame.fromJson(Map<String, dynamic> json) {
    return SentenceFrame(
      id: json['id'] as String,
      zhTemplate: json['zh'] as String,
      pinyinTemplate: json['pinyin'] as String? ?? '',
      viTemplate: json['vi'] as String,
      slotTypes: (json['slot_types'] as List)
          .map((s) => SlotTypeX.fromString(s as String))
          .toList(),
      time: json['time'] as String,
      mood: json['mood'] as String,
      grammarFocus: json['grammar_focus'] as String,
      hskLevelMin: json['hsk_level_min'] as int,
      complexity: json['complexity'] as int,
      scenarioBlacklist: List<String>.from(
        json['scenario_blacklist'] as List? ?? const [],
      ),
      generationEnabled: json['generation_enabled'] as bool? ?? true,
      headSemanticWhitelist: List<String>.from(
        json['head_semantic_whitelist'] as List? ?? const [],
      ),
      headSemanticBlacklist: List<String>.from(
        json['head_semantic_blacklist'] as List? ?? const [],
      ),
      partnerSemanticWhitelist: List<String>.from(
        json['partner_semantic_whitelist'] as List? ?? const [],
      ),
      partnerSemanticBlacklist: List<String>.from(
        json['partner_semantic_blacklist'] as List? ?? const [],
      ),
      partnerScenarioWhitelist: List<String>.from(
        json['partner_scenario_whitelist'] as List? ?? const [],
      ),
      forbidTargetInTemplate:
          json['forbid_target_in_template'] as bool? ?? true,
      forbiddenPatterns: List<String>.from(
        json['forbidden_patterns'] as List? ?? const [],
      ),
      minPartnerFrequency: json['min_partner_frequency'] as int? ?? 1,
      requiredPartnerSources: List<String>.from(
        json['required_partner_sources'] as List? ?? const [],
      ),
      maxPartnerLevelDelta: json['max_partner_level_delta'] as int? ?? 99,
    );
  }

  bool acceptsTargetPos(String pos) {
    if (slotTypes.contains(SlotType.vo) && pos == 'v') {
      return true;
    }
    if (slotTypes.contains(SlotType.v) &&
        !slotTypes.contains(SlotType.vo) &&
        pos == 'v') {
      return true;
    }
    if (slotTypes.contains(SlotType.adj) && pos == 'adj') {
      return true;
    }
    if (slotTypes.contains(SlotType.n) &&
        !slotTypes.contains(SlotType.vo) &&
        pos == 'n') {
      return true;
    }
    return false;
  }
}

class FramesBank {
  final String version;
  final List<SentenceFrame> frames;

  FramesBank({required this.version, required this.frames});

  factory FramesBank.fromJson(Map<String, dynamic> json) {
    return FramesBank(
      version: json['version'] as String? ?? '1.0',
      frames: (json['frames'] as List)
          .map((f) => SentenceFrame.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<FramesBank> fromAsset(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return FramesBank.fromJson(data);
  }
}

// ============================================================================
// GENERATOR OUTPUT
// ============================================================================

/// Một câu được generate cùng metadata.
class GeneratedSentence {
  final String zh;
  final String pinyin;
  final String vi;
  final String frameId;
  final String frameGrammar;
  final String time;
  final String mood;
  final String scenario;
  final int complexity;
  final int hskLevel;

  // Collocation used
  final String headHanzi;
  final String partnerHanzi;
  final String partnerVi;
  final int partnerFrequency;
  final List<String> partnerSources;
  final double qualityScore;

  GeneratedSentence({
    required this.zh,
    this.pinyin = '',
    required this.vi,
    required this.frameId,
    required this.frameGrammar,
    required this.time,
    required this.mood,
    required this.scenario,
    required this.complexity,
    required this.hskLevel,
    required this.headHanzi,
    required this.partnerHanzi,
    required this.partnerVi,
    required this.partnerFrequency,
    required this.partnerSources,
    this.qualityScore = 0,
  });

  Map<String, dynamic> toJson() => {
    'zh': zh,
    'pinyin': pinyin,
    'vi': vi,
    'frame_id': frameId,
    'frame_grammar': frameGrammar,
    'time': time,
    'mood': mood,
    'scenario': scenario,
    'complexity': complexity,
    'hsk_level': hskLevel,
    'quality_score': qualityScore,
    'collocation': {
      'head': headHanzi,
      'partner': partnerHanzi,
      'partner_vi': partnerVi,
      'frequency': partnerFrequency,
      'sources': partnerSources,
    },
  };

  GeneratedSentence withQualityScore(double score) {
    return GeneratedSentence(
      zh: zh,
      pinyin: pinyin,
      vi: vi,
      frameId: frameId,
      frameGrammar: frameGrammar,
      time: time,
      mood: mood,
      scenario: scenario,
      complexity: complexity,
      hskLevel: hskLevel,
      headHanzi: headHanzi,
      partnerHanzi: partnerHanzi,
      partnerVi: partnerVi,
      partnerFrequency: partnerFrequency,
      partnerSources: partnerSources,
      qualityScore: score,
    );
  }
}

/// Diversity report cho một batch sentences.
class DiversityReport {
  final int count;
  final int uniqueFrames;
  final int uniqueScenarios;
  final int uniqueTimes;
  final int uniqueMoods;
  final int uniqueCollocationPartners;
  final double avgComplexity;

  DiversityReport({
    required this.count,
    required this.uniqueFrames,
    required this.uniqueScenarios,
    required this.uniqueTimes,
    required this.uniqueMoods,
    required this.uniqueCollocationPartners,
    required this.avgComplexity,
  });

  Map<String, dynamic> toJson() => {
    'count': count,
    'unique_frames': uniqueFrames,
    'unique_scenarios': uniqueScenarios,
    'unique_times': uniqueTimes,
    'unique_moods': uniqueMoods,
    'unique_collocation_partners': uniqueCollocationPartners,
    'avg_complexity': avgComplexity,
  };
}

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
  int qualityRejected = 0;
}

class SentenceQualityOptions {
  const SentenceQualityOptions({
    this.minHanziLength = 0,
    this.minViWordCount = 0,
    this.minFrameComplexity = 0,
    this.minPartnerFrequency = 0,
    this.minScore = 0,
    this.rejectBareSvo = false,
    this.deniedFrameIds = const {},
  });

  static const relaxed = SentenceQualityOptions();

  static const contextual = SentenceQualityOptions(
    minHanziLength: 7,
    minViWordCount: 4,
    minFrameComplexity: 2,
    minPartnerFrequency: 2,
    minScore: 18,
    rejectBareSvo: true,
  );

  final int minHanziLength;
  final int minViWordCount;
  final int minFrameComplexity;
  final int minPartnerFrequency;
  final double minScore;
  final bool rejectBareSvo;
  final Set<String> deniedFrameIds;
}

class SentenceQualityScore {
  const SentenceQualityScore({required this.accepted, required this.value});

  final bool accepted;
  final double value;
}

class SentenceQualityScorer {
  const SentenceQualityScorer(this.options);

  final SentenceQualityOptions options;

  SentenceQualityScore score({
    required GeneratedSentence sentence,
    required SentenceFrame frame,
    required Set<String> headTags,
    required Set<String> partnerTags,
  }) {
    if (options.deniedFrameIds.contains(frame.id)) {
      return const SentenceQualityScore(accepted: false, value: 0);
    }
    if (_hanziLength(sentence.zh) < options.minHanziLength) {
      return const SentenceQualityScore(accepted: false, value: 0);
    }
    if (_viWordCount(sentence.vi) < options.minViWordCount) {
      return const SentenceQualityScore(accepted: false, value: 0);
    }
    if (frame.complexity < options.minFrameComplexity) {
      return const SentenceQualityScore(accepted: false, value: 0);
    }
    if (sentence.partnerFrequency < options.minPartnerFrequency) {
      return const SentenceQualityScore(accepted: false, value: 0);
    }
    if (options.rejectBareSvo && _isBareSvoFrame(frame)) {
      return const SentenceQualityScore(accepted: false, value: 0);
    }

    var value = 0.0;
    value += min(sentence.partnerFrequency, 6) * 1.5;
    value += frame.complexity * 4;
    value += sentence.frameGrammar.isEmpty ? 0 : 2;
    value += _contextCueScore(frame.zhTemplate);
    value += min(max(_hanziLength(sentence.zh) - 4, 0), 8) * 0.8;
    value += min(max(_viWordCount(sentence.vi) - 3, 0), 6) * 0.7;
    value += sentence.scenario == 'general' ? -2 : 2;
    value += _sourceScore(sentence.partnerSources);

    if (frame.headSemanticWhitelist.isNotEmpty && headTags.isNotEmpty) {
      value += 3;
    }
    if (frame.partnerSemanticWhitelist.isNotEmpty && partnerTags.isNotEmpty) {
      value += 3;
    }
    if (_isBareSvoFrame(frame)) {
      value -= 8;
    }

    return SentenceQualityScore(
      accepted: value >= options.minScore,
      value: value,
    );
  }

  int _hanziLength(String value) {
    return value.runes.where((rune) => rune >= 0x4E00 && rune <= 0x9FFF).length;
  }

  int _viWordCount(String value) {
    final normalized = value.replaceAll(RegExp(r'[.,!?;:，。？！；：]'), ' ').trim();
    if (normalized.isEmpty) return 0;
    return normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  double _sourceScore(List<String> sources) {
    if (sources.contains('curated')) return 6;
    if (sources.contains('example') || sources.contains('test')) return 4;
    if (sources.contains('mined')) return 1;
    return 0;
  }

  double _contextCueScore(String template) {
    const cues = [
      '今天',
      '明天',
      '昨天',
      '每天',
      '正在',
      '已经',
      '如果',
      '虽然',
      '尽管',
      '通过',
      '对于',
      '随着',
      '无论',
      '不仅',
      '经过',
      '由于',
      '为了',
      '跟朋友',
      '一起',
    ];
    return cues.any(template.contains) ? 4 : 0;
  }

  bool _isBareSvoFrame(SentenceFrame frame) {
    final compact = frame.zhTemplate.replaceAll(RegExp(r'\s+'), '');
    return {
      '我{VO}。',
      '他{VO}。',
      '她{VO}。',
      '我们{VO}。',
      '你{VO}吗？',
      '{N}很{ADJ}。',
      '他是{N}。',
    }.contains(compact);
  }
}

class _SentenceCandidate {
  const _SentenceCandidate({
    required this.sentence,
    required this.diversityKey,
    required this.order,
  });

  final GeneratedSentence sentence;
  final String diversityKey;
  final int order;
}

// ============================================================================
// GENERATOR
// ============================================================================

/// Vocab metadata cần thiết cho generator (nhẹ, không full).
class VocabLite {
  final String hanzi;
  final String pinyin;
  final String vi;
  final String pos;
  final int level;

  VocabLite({
    required this.hanzi,
    required this.pinyin,
    required this.vi,
    required this.pos,
    required this.level,
  });
}

/// Sentence Generator chính.
///
/// Sử dụng:
/// ```dart
/// final gen = SentenceGenerator(
///   collocationsDb: db,
///   framesBank: bank,
///   vocabIndex: vocabMap,
/// );
/// final sentences = gen.generate(
///   targetWord: '考虑',
///   userHskLevel: 4,
///   count: 8,
/// );
/// ```
class SentenceGenerator {
  final CollocationsDb collocationsDb;
  final FramesBank framesBank;
  final Map<String, VocabLite> vocabIndex;
  final Random _random;

  /// Blacklist các collocation pair noisy từ auto-mining.
  /// Format: "{head}|{partner}"
  final Set<String> noisyBlacklist;
  final Set<String> curatedPairAllowlist;
  final Map<String, Set<String>> headSemantics;
  final Map<String, Set<String>> partnerSemantics;
  final List<String> globalForbiddenPatterns;

  SentenceGenerator({
    required this.collocationsDb,
    required this.framesBank,
    required this.vocabIndex,
    Set<String>? noisyPairBlacklist,
    Set<String>? curatedPairAllowlist,
    this.headSemantics = const {},
    this.partnerSemantics = const {},
    this.globalForbiddenPatterns = const [],
    int? seed,
  }) : _random = seed != null ? Random(seed) : Random(),
       curatedPairAllowlist = curatedPairAllowlist ?? const {},
       noisyBlacklist = noisyPairBlacklist ?? const {};

  /// Lấy nghĩa Việt sạch (trước dấu phẩy đầu tiên).
  String _cleanVi(String hanzi) {
    final v = vocabIndex[hanzi];
    if (v == null) return hanzi;
    var raw = v.vi;
    for (final sep in [',', '/', '；', ';']) {
      if (raw.contains(sep)) {
        raw = raw.split(sep).first;
      }
    }
    return raw.trim();
  }

  /// Filter collocations: bỏ noise.
  List<CollocationPartner> _filterPartners(
    String head,
    List<CollocationPartner> partners,
  ) {
    return partners.where((p) {
      final key = '$head|${p.objectHanzi}';
      if (!curatedPairAllowlist.contains(key) && noisyBlacklist.contains(key)) {
        return false;
      }
      if (p.objectHanzi.length > 4) return false;
      if ({'人', '事', '东西'}.contains(p.objectHanzi)) return false;
      if (p.objectHanzi == head) return false;
      if (p.objectHanzi.length == 1 && head.contains(p.objectHanzi)) {
        return false;
      }
      if ({'了', '过', '着', '的', '个', '些'}.contains(p.objectHanzi)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Tạo chunk verb-object zh + vi.
  ({String zh, String vi}) _buildVoChunk(
    String verbHanzi,
    CollocationPartner p,
  ) {
    final zh = '$verbHanzi${p.objectHanzi}';
    final vi = '${_cleanVi(verbHanzi)} ${_cleanVi(p.objectHanzi)}'.trim();
    return (zh: zh, vi: vi);
  }

  /// Generate diverse sentences containing [targetWord].
  ///
  /// [userHskLevel]: 1-4. Chỉ frames hskLevelMin <= này được dùng.
  /// [count]: số câu mong muốn. Generator có thể trả ít hơn nếu không đủ diversity.
  /// [enforceDiversity]: nếu true, tránh lặp combo (frame, scenario, time, mood).
  List<GeneratedSentence> generate({
    required String targetWord,
    int userHskLevel = 4,
    int count = 8,
    bool enforceDiversity = true,
    SentenceQualityOptions qualityOptions = SentenceQualityOptions.relaxed,
  }) {
    return generateWithStats(
      targetWord: targetWord,
      userHskLevel: userHskLevel,
      count: count,
      enforceDiversity: enforceDiversity,
      qualityOptions: qualityOptions,
    ).sentences;
  }

  ({List<GeneratedSentence> sentences, RejectionStats stats})
  generateWithStats({
    required String targetWord,
    int userHskLevel = 4,
    int count = 8,
    bool enforceDiversity = true,
    SentenceQualityOptions qualityOptions = SentenceQualityOptions.relaxed,
  }) {
    final stats = RejectionStats();
    final vocab = vocabIndex[targetWord];
    if (vocab == null) return (sentences: const [], stats: stats);
    final pos = vocab.pos;
    final headEntry = _entryFor(targetWord, pos);
    if (headEntry == null) return (sentences: const [], stats: stats);
    final partners = _filterPartners(targetWord, headEntry.collocations)
      ..shuffle(_random);
    if (partners.isEmpty) return (sentences: const [], stats: stats);

    final frames = framesBank.frames.toList()..shuffle(_random);
    final combos = [
      for (final frame in frames)
        for (final partner in partners) (frame: frame, partner: partner),
    ]..shuffle(_random);
    final candidates = <_SentenceCandidate>[];
    final scorer = SentenceQualityScorer(qualityOptions);
    final headTags = headSemantics[targetWord] ?? const <String>{};
    var order = 0;

    for (final combo in combos) {
      final frame = combo.frame;
      final partner = combo.partner;
      if (!_frameAcceptsHead(frame, vocab, userHskLevel, stats)) continue;
      if (!_frameAcceptsPartner(frame, partner, headEntry, stats)) continue;
      final comboKey =
          '${frame.id}|${partner.scenario}|${frame.time}|${frame.mood}';

      final built = _buildSentence(frame, vocab, partner);
      if (built == null ||
          !_validateBuiltSentence(
            frame,
            built.zh,
            built.vi,
            built.pinyin,
            targetWord,
          )) {
        stats.builtPostValidation++;
        continue;
      }

      final sentence = GeneratedSentence(
        zh: built.zh,
        pinyin: built.pinyin,
        vi: built.vi,
        frameId: frame.id,
        frameGrammar: frame.grammarFocus,
        time: frame.time,
        mood: frame.mood,
        scenario: partner.scenario,
        complexity: frame.complexity,
        hskLevel: frame.hskLevelMin,
        headHanzi: targetWord,
        partnerHanzi: partner.objectHanzi,
        partnerVi: partner.objectVi,
        partnerFrequency: partner.frequency,
        partnerSources: partner.sources,
      );
      final quality = scorer.score(
        sentence: sentence,
        frame: frame,
        headTags: headTags,
        partnerTags: _resolvePartnerSemantics(partner),
      );
      if (!quality.accepted) {
        stats.qualityRejected++;
        continue;
      }
      candidates.add(
        _SentenceCandidate(
          sentence: sentence.withQualityScore(quality.value),
          diversityKey: comboKey,
          order: order++,
        ),
      );
    }

    candidates.sort((a, b) {
      final score = b.sentence.qualityScore.compareTo(a.sentence.qualityScore);
      if (score != 0) return score;
      return a.order.compareTo(b.order);
    });

    final output = <GeneratedSentence>[];
    final usedCombos = <String>{};
    for (final candidate in candidates) {
      if (output.length >= count) break;
      if (enforceDiversity && !usedCombos.add(candidate.diversityKey)) {
        stats.diversityCollision++;
        continue;
      }
      output.add(candidate.sentence);
    }

    return (sentences: output, stats: stats);
  }

  CollocationEntry? _entryFor(String targetWord, String pos) {
    if (pos == 'v') return collocationsDb.verbObject[targetWord];
    if (pos == 'adj') return collocationsDb.adjNoun[targetWord];
    return null;
  }

  bool _frameAcceptsHead(
    SentenceFrame frame,
    VocabLite head,
    int userHskLevel,
    RejectionStats stats,
  ) {
    if (!frame.generationEnabled) {
      stats.frameDisabled++;
      return false;
    }
    if (!frame.acceptsTargetPos(head.pos)) return false;
    if (frame.hskLevelMin > userHskLevel) return false;
    final tags = headSemantics[head.hanzi] ?? const <String>{};
    if (frame.headSemanticWhitelist.isNotEmpty &&
        !tags.any(frame.headSemanticWhitelist.contains)) {
      stats.headSemantic++;
      return false;
    }
    if (frame.headSemanticBlacklist.any(tags.contains)) {
      stats.headSemantic++;
      return false;
    }
    if (frame.forbidTargetInTemplate &&
        head.hanzi.runes.length >= 2 &&
        frame.zhTemplate.contains(head.hanzi)) {
      stats.targetInTemplate++;
      return false;
    }
    return true;
  }

  bool _frameAcceptsPartner(
    SentenceFrame frame,
    CollocationPartner partner,
    CollocationEntry headEntry,
    RejectionStats stats,
  ) {
    if (frame.partnerScenarioWhitelist.isNotEmpty &&
        !frame.partnerScenarioWhitelist.contains(partner.scenario)) {
      stats.scenarioBlacklist++;
      return false;
    }
    if (frame.scenarioBlacklist.contains(partner.scenario)) {
      stats.scenarioBlacklist++;
      return false;
    }
    if (partner.frequency < frame.minPartnerFrequency) {
      stats.frequencyFloor++;
      return false;
    }
    if (frame.requiredPartnerSources.isNotEmpty &&
        !partner.sources.any(frame.requiredPartnerSources.contains)) {
      stats.sourcesFloor++;
      return false;
    }
    if (frame.maxPartnerLevelDelta < 99 &&
        partner.objectLevel - headEntry.headLevel >
            frame.maxPartnerLevelDelta) {
      stats.levelDelta++;
      return false;
    }
    final tags = _resolvePartnerSemantics(partner);
    if (frame.partnerSemanticWhitelist.isNotEmpty &&
        !tags.any(frame.partnerSemanticWhitelist.contains)) {
      stats.partnerSemantic++;
      return false;
    }
    if (frame.partnerSemanticBlacklist.any(tags.contains)) {
      stats.partnerSemantic++;
      return false;
    }
    return true;
  }

  Set<String> _resolvePartnerSemantics(CollocationPartner partner) {
    final explicit = partnerSemantics[partner.objectHanzi];
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return _semanticsFromScenario(partner.scenario);
  }

  Set<String> _semanticsFromScenario(String scenario) {
    return switch (scenario) {
      'place' => {'noun.place'},
      'food' => {'noun.food'},
      'tech' => {'noun.tool'},
      'transport' => {'noun.tool', 'noun.place'},
      'study' => {'noun.abstract'},
      'work' => {'noun.event', 'noun.abstract'},
      'sports' => {'noun.event'},
      'health' => {'noun.body_topic'},
      'leisure' => {'noun.media', 'noun.event'},
      _ => const <String>{},
    };
  }

  ({String zh, String pinyin, String vi})? _buildSentence(
    SentenceFrame frame,
    VocabLite vocab,
    CollocationPartner partner,
  ) {
    var zh = frame.zhTemplate;
    var pinyin = frame.pinyinTemplate;
    var vi = frame.viTemplate;
    final targetWord = vocab.hanzi;

    if (vocab.pos == 'v') {
      if (frame.slotTypes.contains(SlotType.vo)) {
        final chunk = _buildVoChunk(targetWord, partner);
        final voPinyin = _buildVoPinyin(vocab, partner);
        zh = zh.replaceAll('{VO}', chunk.zh);
        pinyin = _replacePinyinSlot(pinyin, '{PVO}', voPinyin);
        vi = vi.replaceAll('{VVO}', chunk.vi);
      } else if (frame.slotTypes.contains(SlotType.v)) {
        zh = zh.replaceAll('{V}', targetWord);
        pinyin = _replacePinyinSlot(pinyin, '{PV}', vocab.pinyin);
        vi = vi.replaceAll('{VV}', _cleanVi(targetWord));
        if (zh.contains('{N}')) {
          zh = zh.replaceAll('{N}', partner.objectHanzi);
          pinyin = _replacePinyinSlot(
            pinyin,
            '{PN}',
            _pinyinForPartner(partner),
          );
          vi = vi.replaceAll('{VN}', _cleanVi(partner.objectHanzi));
        }
      }
    } else if (vocab.pos == 'adj') {
      if (frame.slotTypes.contains(SlotType.n) &&
          frame.slotTypes.contains(SlotType.adj)) {
        final n = partner.objectHanzi;
        zh = zh.replaceFirst('{N}', n).replaceAll('{ADJ}', targetWord);
        pinyin = pinyin
            .replaceFirst('{PN}', _pinyinForPartner(partner))
            .replaceAll('{PADJ}', vocab.pinyin);
        if (frame.pinyinTemplate.isNotEmpty &&
            (_pinyinForPartner(partner).isEmpty || vocab.pinyin.isEmpty)) {
          pinyin = '';
        }
        vi = vi
            .replaceFirst('{VN}', _cleanVi(n))
            .replaceAll('{VADJ}', _cleanVi(targetWord));
        if (zh.contains('{N2}')) {
          final pool = vocabIndex.values
              .where((v) => v.pos == 'n' && v.level <= 2 && v.hanzi != n)
              .toList();
          if (pool.isEmpty) return null;
          final n2Vocab = pool[_random.nextInt(pool.length)];
          final n2 = n2Vocab.hanzi;
          zh = zh.replaceAll('{N2}', n2);
          pinyin = _replacePinyinSlot(pinyin, '{PN2}', n2Vocab.pinyin);
          vi = vi.replaceAll('{VN2}', _cleanVi(n2));
        }
      } else if (frame.slotTypes.contains(SlotType.adj)) {
        zh = zh.replaceAll('{ADJ}', targetWord);
        pinyin = _replacePinyinSlot(pinyin, '{PADJ}', vocab.pinyin);
        vi = vi.replaceAll('{VADJ}', _cleanVi(targetWord));
      }
    }

    return (zh: zh, pinyin: pinyin, vi: vi);
  }

  String _buildVoPinyin(VocabLite vocab, CollocationPartner partner) {
    final partnerPinyin = _pinyinForPartner(partner);
    if (vocab.pinyin.isEmpty || partnerPinyin.isEmpty) return '';
    return '${vocab.pinyin} $partnerPinyin'.trim();
  }

  String _pinyinForPartner(CollocationPartner partner) {
    if (partner.objectPinyin.isNotEmpty) return partner.objectPinyin;
    return vocabIndex[partner.objectHanzi]?.pinyin ?? '';
  }

  String _replacePinyinSlot(String template, String slot, String value) {
    if (template.isEmpty) return '';
    if (value.isEmpty) return '';
    return template.replaceAll(slot, value);
  }

  bool _validateBuiltSentence(
    SentenceFrame frame,
    String zh,
    String vi,
    String pinyin,
    String head,
  ) {
    if (zh.contains('{') || vi.contains('{') || pinyin.contains('{')) {
      return false;
    }
    if (head.runes.length >= 2 && zh.contains('$head$head')) return false;
    for (final pattern in [
      ...frame.forbiddenPatterns,
      ...globalForbiddenPatterns,
    ]) {
      if (RegExp(pattern).hasMatch(zh)) return false;
    }
    return true;
  }

  /// Compute diversity metrics for a batch.
  DiversityReport diversityReport(List<GeneratedSentence> sentences) {
    if (sentences.isEmpty) {
      return DiversityReport(
        count: 0,
        uniqueFrames: 0,
        uniqueScenarios: 0,
        uniqueTimes: 0,
        uniqueMoods: 0,
        uniqueCollocationPartners: 0,
        avgComplexity: 0,
      );
    }
    return DiversityReport(
      count: sentences.length,
      uniqueFrames: sentences.map((s) => s.frameId).toSet().length,
      uniqueScenarios: sentences.map((s) => s.scenario).toSet().length,
      uniqueTimes: sentences.map((s) => s.time).toSet().length,
      uniqueMoods: sentences.map((s) => s.mood).toSet().length,
      uniqueCollocationPartners: sentences
          .map((s) => s.partnerHanzi)
          .toSet()
          .length,
      avgComplexity:
          sentences.map((s) => s.complexity).reduce((a, b) => a + b) /
          sentences.length,
    );
  }
}
