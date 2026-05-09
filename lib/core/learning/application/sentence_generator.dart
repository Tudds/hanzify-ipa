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

  GeneratedSentence({
    required this.zh,
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
  });

  Map<String, dynamic> toJson() => {
    'zh': zh,
    'vi': vi,
    'frame_id': frameId,
    'frame_grammar': frameGrammar,
    'time': time,
    'mood': mood,
    'scenario': scenario,
    'complexity': complexity,
    'hsk_level': hskLevel,
    'collocation': {
      'head': headHanzi,
      'partner': partnerHanzi,
      'partner_vi': partnerVi,
      'frequency': partnerFrequency,
      'sources': partnerSources,
    },
  };
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
    Set<String>? noisyBlacklist,
    Set<String>? noisyPairBlacklist,
    Set<String>? curatedPairAllowlist,
    this.headSemantics = const {},
    this.partnerSemantics = const {},
    this.globalForbiddenPatterns = const [],
    int? seed,
  }) : _random = seed != null ? Random(seed) : Random(),
       curatedPairAllowlist = curatedPairAllowlist ?? const {},
       noisyBlacklist =
           noisyPairBlacklist ??
           noisyBlacklist ??
           {'考虑|能不能', '解决|就业', '反映|社会', '丰富|日', '丰富|分钟', '丰富|日子', '看|医生'};

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
      if (noisyBlacklist.contains(key)) return false;
      if (p.objectHanzi.length > 4) return false;
      if ({'人', '事', '东西'}.contains(p.objectHanzi)) return false;
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
  }) {
    final vocab = vocabIndex[targetWord];
    if (vocab == null) return [];

    final pos = vocab.pos;

    // Get collocations
    List<CollocationPartner> partners = [];
    if (pos == 'v' && collocationsDb.verbObject.containsKey(targetWord)) {
      partners = _filterPartners(
        targetWord,
        collocationsDb.verbObject[targetWord]!.collocations,
      );
    } else if (pos == 'adj' && collocationsDb.adjNoun.containsKey(targetWord)) {
      partners = _filterPartners(
        targetWord,
        collocationsDb.adjNoun[targetWord]!.collocations,
      );
    }

    if (partners.isEmpty) return [];

    // Filter compatible frames
    final compatible = framesBank.frames
        .where((f) => f.hskLevelMin <= userHskLevel && f.acceptsTargetPos(pos))
        .toList();

    if (compatible.isEmpty) return [];

    // Generate
    final output = <GeneratedSentence>[];
    final usedCombos = <String>{};
    var attempts = 0;
    final maxAttempts = count * 8;

    while (output.length < count && attempts < maxAttempts) {
      attempts++;
      final frame = compatible[_random.nextInt(compatible.length)];
      final partner = partners[_random.nextInt(partners.length)];

      final comboKey =
          '${frame.id}|${partner.scenario}|${frame.time}|${frame.mood}';
      if (enforceDiversity && usedCombos.contains(comboKey)) continue;
      usedCombos.add(comboKey);

      // Skip blacklisted scenarios for this frame
      if (frame.scenarioBlacklist.contains(partner.scenario)) continue;

      // Build sentence
      var zh = frame.zhTemplate;
      var vi = frame.viTemplate;

      if (pos == 'v') {
        if (frame.slotTypes.contains(SlotType.vo)) {
          final chunk = _buildVoChunk(targetWord, partner);
          zh = zh.replaceAll('{VO}', chunk.zh);
          vi = vi.replaceAll('{VVO}', chunk.vi);
        } else if (frame.slotTypes.contains(SlotType.v)) {
          zh = zh.replaceAll('{V}', targetWord);
          vi = vi.replaceAll('{VV}', _cleanVi(targetWord));
          if (zh.contains('{N}')) {
            zh = zh.replaceAll('{N}', partner.objectHanzi);
            vi = vi.replaceAll('{VN}', _cleanVi(partner.objectHanzi));
          }
        }
      } else if (pos == 'adj') {
        if (frame.slotTypes.contains(SlotType.n) &&
            frame.slotTypes.contains(SlotType.adj)) {
          final n = partner.objectHanzi;
          zh = zh.replaceFirst('{N}', n).replaceAll('{ADJ}', targetWord);
          vi = vi
              .replaceFirst('{VN}', _cleanVi(n))
              .replaceAll('{VADJ}', _cleanVi(targetWord));
          if (zh.contains('{N2}')) {
            // Pick another common noun (not partner)
            final pool = vocabIndex.values
                .where((v) => v.pos == 'n' && v.level <= 2 && v.hanzi != n)
                .toList();
            if (pool.isEmpty) continue;
            final n2 = pool[_random.nextInt(pool.length)].hanzi;
            zh = zh.replaceAll('{N2}', n2);
            vi = vi.replaceAll('{VN2}', _cleanVi(n2));
          }
        } else if (frame.slotTypes.contains(SlotType.adj)) {
          zh = zh.replaceAll('{ADJ}', targetWord);
          vi = vi.replaceAll('{VADJ}', _cleanVi(targetWord));
        }
      }

      // Validate no leftover slots
      if (zh.contains('{') || vi.contains('{')) continue;

      output.add(
        GeneratedSentence(
          zh: zh,
          vi: vi,
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
        ),
      );
    }

    return output;
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
