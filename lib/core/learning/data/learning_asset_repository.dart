import 'dart:convert';

import 'package:flutter/services.dart';

import '../../audio/audio_urls.dart';
import '../domain/collocation.dart';
import '../domain/lesson_context.dart';
import '../application/quiz_generator.dart';
import '../application/sentence_generator.dart';

class LearningAssetRepository {
  const LearningAssetRepository({AssetBundle? bundle}) : _bundle = bundle;

  /// Combined pool — kept only as a fallback for bundles that don't ship the
  /// per-level files (e.g. test fixtures). Production loads per level.
  static const collocationPoolAsset =
      'assets/data/generated/collocation_pool_hsk1_4.json';
  static const collocationPoolByLevel = <int, String>{
    1: 'assets/data/generated/collocation_pool_hsk1.json',
    2: 'assets/data/generated/collocation_pool_hsk2.json',
    3: 'assets/data/generated/collocation_pool_hsk3.json',
    4: 'assets/data/generated/collocation_pool_hsk4.json',
  };
  static const conversationAsset = 'assets/data/conversation.json';
  static const collocationsDbAsset =
      'assets/data/generated/collocations_db.json';
  static const framesBankAsset = 'assets/data/generated/frames_bank.json';
  static const headSemanticsAsset = 'assets/data/generated/head_semantics.json';
  static const partnerSemanticsAsset =
      'assets/data/generated/partner_semantics.json';
  static const qualityRulesAsset =
      'assets/data/generated/sentence_quality_rules.json';
  static const hskVocabAssets = [
    'assets/data/hsk1.json',
    'assets/data/hsk2.json',
    'assets/data/hsk3.json',
    'assets/data/hsk4.json',
  ];

  final AssetBundle? _bundle;

  // Asset parsing is memoized per [AssetBundle] (rootBundle in production is a
  // singleton, so this is effectively an app-wide cache; tests pass distinct
  // fake bundles, so caches stay isolated per test). This keeps the ~1.9MB
  // collocation pool from being re-decoded on every Shorts load + hydration +
  // remediation, and lets the futures dedupe concurrent first loads.
  static final Map<AssetBundle, Map<int, Future<List<CollocationItem>>>>
      _poolLevelFutures = {};
  static final Map<AssetBundle, Future<Map<String, Map<String, int>>>>
      _conversationIndexFutures = {};
  static final Map<AssetBundle, Future<List<CollocationItem>>>
      _combinedPoolFutures = {};

  /// Static collocation pool for a single HSK [level] — parses only that
  /// level's file (~0.2–0.4MB) instead of the whole pool. Cached.
  Future<List<CollocationItem>> loadStaticCollocationPoolForLevel(int level) {
    final bundle = _bundle ?? rootBundle;
    final perLevel = _poolLevelFutures.putIfAbsent(bundle, () => {});
    return perLevel.putIfAbsent(level, () => _doLoadPoolLevel(bundle, level));
  }

  /// Static collocation pool restricted to [levels]. The Shorts startup feed
  /// only needs the active level, so this avoids decoding all four on the main
  /// isolate before the first frame.
  Future<List<CollocationItem>> loadStaticCollocationPoolForLevels(
    List<int> levels,
  ) async {
    final result = <CollocationItem>[];
    for (final level in levels) {
      result.addAll(await loadStaticCollocationPoolForLevel(level));
    }
    return result;
  }

  Future<List<CollocationItem>> loadStaticCollocationPool() =>
      loadStaticCollocationPoolForLevels(const [1, 2, 3, 4]);

  Future<List<CollocationItem>> _doLoadPoolLevel(
    AssetBundle bundle,
    int level,
  ) async {
    final lineIndexes = await _conversationIndex(bundle);
    final path = collocationPoolByLevel[level];
    final raw = path == null ? null : await _maybeLoad(bundle, path);
    final List<CollocationItem> items;
    if (raw != null) {
      items = (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(CollocationItem.fromJson)
          .toList(growable: false);
    } else {
      // Fallback for bundles that only ship the combined file (test fixtures).
      final combined = await _combinedPool(bundle);
      items = combined
          .where((item) => item.level == level)
          .toList(growable: false);
    }
    return List<CollocationItem>.unmodifiable(
      _withConversationAudio(items, lineIndexes),
    );
  }

  Future<Map<String, Map<String, int>>> _conversationIndex(
    AssetBundle bundle,
  ) {
    return _conversationIndexFutures.putIfAbsent(bundle, () async {
      final raw = await bundle.loadString(conversationAsset);
      return _conversationLineIndexes(raw);
    });
  }

  Future<List<CollocationItem>> _combinedPool(AssetBundle bundle) {
    return _combinedPoolFutures.putIfAbsent(bundle, () async {
      final raw = await bundle.loadString(collocationPoolAsset);
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(CollocationItem.fromJson)
          .toList(growable: false);
    });
  }

  Future<List<CollocationItem>> loadCollocationPool() async {
    try {
      return await loadStaticCollocationPool();
    } catch (_) {
      // Tests can provide only generator assets; keep the runtime fallback.
    }

    return loadGeneratedCollocationPool();
  }

  Future<List<CollocationItem>> loadGeneratedCollocationPool() async {
    final bundle = _bundle ?? rootBundle;
    final collocationsRaw = await bundle.loadString(collocationsDbAsset);
    final framesRaw = await bundle.loadString(framesBankAsset);
    final collocationsDb = await CollocationsDb.fromAsset(collocationsRaw);
    final framesBank = await FramesBank.fromAsset(framesRaw);
    final headSemantics = _loadSemantics(
      await _maybeLoad(bundle, headSemanticsAsset),
      'heads',
    );
    final partnerSemantics = _loadSemantics(
      await _maybeLoad(bundle, partnerSemanticsAsset),
      'partners',
    );
    final vocabPinyinIndex = await _loadVocabPinyinIndex(bundle);
    final rules = _loadRules(await _maybeLoad(bundle, qualityRulesAsset));
    final generator = SentenceGenerator(
      collocationsDb: collocationsDb,
      framesBank: framesBank,
      vocabIndex: _vocabIndexFor(collocationsDb, vocabPinyinIndex),
      headSemantics: headSemantics,
      partnerSemantics: partnerSemantics,
      noisyPairBlacklist: rules.pairBlacklist,
      curatedPairAllowlist: rules.pairAllowlist,
      globalForbiddenPatterns: rules.globalForbiddenPatterns,
      seed: 1,
    );

    final items = <CollocationItem>[];
    for (var level = 1; level <= 4; level++) {
      items.addAll(
        _generateLevelItems(
          collocationsDb,
          generator,
          level,
          rules.contextOptions,
        ),
      );
    }
    return items;
  }

  Future<String?> _maybeLoad(AssetBundle bundle, String key) async {
    try {
      return await bundle.loadString(key);
    } catch (_) {
      return null;
    }
  }

  Map<String, Set<String>> _loadSemantics(String? raw, String key) {
    if (raw == null) return const {};
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final values = data[key] as Map<String, dynamic>? ?? const {};
    return values.map(
      (hanzi, tags) => MapEntry(hanzi, Set<String>.from(tags as List)),
    );
  }

  SentenceQualityRules _loadRules(String? raw) {
    if (raw == null) return const SentenceQualityRules();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return SentenceQualityRules(
      pairBlacklist: Set<String>.from(
        data['pair_blacklist'] as List? ?? const [],
      ),
      pairAllowlist: Set<String>.from(
        data['pair_allowlist'] as List? ?? const [],
      ),
      globalForbiddenPatterns: List<String>.from(
        data['global_forbidden_patterns'] as List? ?? const [],
      ),
      minContextHanziLength:
          data['min_context_hanzi_length'] as int? ??
          SentenceQualityOptions.contextual.minHanziLength,
      minContextViWordCount:
          data['min_context_vi_word_count'] as int? ??
          SentenceQualityOptions.contextual.minViWordCount,
      minContextFrameComplexity:
          data['min_context_frame_complexity'] as int? ??
          SentenceQualityOptions.contextual.minFrameComplexity,
      minContextPartnerFrequency:
          data['min_context_partner_frequency'] as int? ??
          SentenceQualityOptions.contextual.minPartnerFrequency,
      minContextScore:
          (data['min_context_score'] as num?)?.toDouble() ??
          SentenceQualityOptions.contextual.minScore,
      contextDeniedFrameIds: Set<String>.from(
        data['context_denied_frame_ids'] as List? ?? const [],
      ),
    );
  }

  Future<Map<String, String>> _loadVocabPinyinIndex(AssetBundle bundle) async {
    final result = <String, String>{};
    for (final asset in hskVocabAssets) {
      final raw = await _maybeLoad(bundle, asset);
      if (raw == null) continue;
      final items = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      for (final item in items) {
        final hanzi = item['hanzi'] as String? ?? '';
        final pinyin = item['pinyin'] as String? ?? '';
        if (hanzi.isEmpty || pinyin.isEmpty) continue;
        result.putIfAbsent(hanzi, () => pinyin);
      }
    }
    return result;
  }

  Map<String, Map<String, int>> _conversationLineIndexes(String raw) {
    final conversations = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>();
    final indexes = <String, Map<String, int>>{};
    for (final conversation in conversations) {
      final id = conversation['id'] as String?;
      if (id == null) continue;
      final lines = (conversation['lines'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
      indexes[id] = {
        for (var index = 0; index < lines.length; index++)
          if (lines[index]['zh'] case final String zh) zh: index,
      };
    }
    return indexes;
  }

  List<CollocationItem> _withConversationAudio(
    List<CollocationItem> items,
    Map<String, Map<String, int>> lineIndexes,
  ) {
    final result = <CollocationItem>[];

    for (final item in items) {
      if (item.source != 'conversation_line' ||
          item.conversationIds.length != 1) {
        result.add(item);
        continue;
      }

      final conversationId = item.conversationIds.first;
      final lineIndex = lineIndexes[conversationId]?[item.textCn];
      if (lineIndex == null) {
        result.add(item);
        continue;
      }
      result.add(
        item.copyWith(
          audioUrl: AudioUrls.forConversationLine(conversationId, lineIndex),
        ),
      );
    }

    return result;
  }

  Map<String, VocabLite> _vocabIndexFor(
    CollocationsDb db,
    Map<String, String> vocabPinyinIndex,
  ) {
    final index = <String, VocabLite>{};
    for (final entry in [
      ...db.verbObject.values,
      ...db.adjNoun.values,
      ...db.measureNoun.values,
    ]) {
      index[entry.headHanzi] = VocabLite(
        hanzi: entry.headHanzi,
        pinyin: _resolvePinyin(
          entry.headHanzi,
          entry.headPinyin,
          vocabPinyinIndex,
        ),
        vi: entry.headVi,
        pos: entry.headPos,
        level: entry.headLevel,
      );
      for (final partner in entry.collocations) {
        index.putIfAbsent(
          partner.objectHanzi,
          () => VocabLite(
            hanzi: partner.objectHanzi,
            pinyin: _resolvePinyin(
              partner.objectHanzi,
              partner.objectPinyin,
              vocabPinyinIndex,
            ),
            vi: partner.objectVi,
            pos: 'n',
            level: partner.objectLevel,
          ),
        );
      }
    }
    return index;
  }

  String _resolvePinyin(
    String hanzi,
    String sourcePinyin,
    Map<String, String> vocabPinyinIndex,
  ) {
    final trimmed = sourcePinyin.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return vocabPinyinIndex[hanzi] ?? '';
  }

  List<CollocationItem> _generateLevelItems(
    CollocationsDb db,
    SentenceGenerator generator,
    int level,
    SentenceQualityOptions contextQualityOptions,
  ) {
    final heads =
        [
            ...db.verbObject.values,
            ...db.adjNoun.values,
          ].where((entry) => entry.headLevel == level).toList()
          ..sort((a, b) => a.headHanzi.compareTo(b.headHanzi));
    final items = <CollocationItem>[];
    final seenText = <String>{};

    for (final entry in heads) {
      final sentences = generator.generate(
        targetWord: entry.headHanzi,
        userHskLevel: level,
        count: 4,
        qualityOptions: contextQualityOptions,
      );
      for (final sentence in sentences) {
        if (!seenText.add(sentence.zh)) continue;
        items.add(
          CollocationItem(
            id: 'gen_${level}_${items.length.toString().padLeft(5, '0')}',
            level: level,
            source: 'on_demand_generator',
            textCn: sentence.zh,
            pinyin: sentence.pinyin,
            textVi: sentence.vi,
            targetVocabIds: ['hsk${entry.headLevel}_${entry.headHanzi}'],
            targetGrammarIds: [sentence.frameGrammar],
            conversationIds: const [],
            tags: [sentence.scenario, sentence.mood],
            difficulty: level + (sentence.complexity / 10),
          ),
        );
      }
    }
    return items;
  }
}

class HskLearningSessionSeed {
  const HskLearningSessionSeed({
    required this.activeLevel,
    required this.collocations,
    required this.quizzes,
  });

  final int activeLevel;
  final List<CollocationItem> collocations;
  final List<LearningQuiz> quizzes;
}

class SentenceQualityRules {
  const SentenceQualityRules({
    this.pairBlacklist = const {},
    this.pairAllowlist = const {},
    this.globalForbiddenPatterns = const [],
    this.minContextHanziLength = 7,
    this.minContextViWordCount = 4,
    this.minContextFrameComplexity = 2,
    this.minContextPartnerFrequency = 2,
    this.minContextScore = 18,
    this.contextDeniedFrameIds = const {},
  });

  final Set<String> pairBlacklist;
  final Set<String> pairAllowlist;
  final List<String> globalForbiddenPatterns;
  final int minContextHanziLength;
  final int minContextViWordCount;
  final int minContextFrameComplexity;
  final int minContextPartnerFrequency;
  final double minContextScore;
  final Set<String> contextDeniedFrameIds;

  SentenceQualityOptions get contextOptions {
    return SentenceQualityOptions(
      minHanziLength: minContextHanziLength,
      minViWordCount: minContextViWordCount,
      minFrameComplexity: minContextFrameComplexity,
      minPartnerFrequency: minContextPartnerFrequency,
      minScore: minContextScore,
      rejectBareSvo: true,
      deniedFrameIds: contextDeniedFrameIds,
    );
  }
}

class HskLearningSessionFactory {
  const HskLearningSessionFactory({
    this.repository = const LearningAssetRepository(),
    this.quizGenerator = const QuizGenerator(),
  });

  final LearningAssetRepository repository;
  final QuizGenerator quizGenerator;

  Future<HskLearningSessionSeed> createHsk2Session({
    int quizLimit = 8,
    LessonContext? lessonContext,
  }) async {
    final pool = await repository.loadCollocationPool();
    final activeLevel = lessonContext?.level ?? 2;
    final levelPool = pool
        .where((item) => item.level == activeLevel)
        .toList(growable: false);
    final lessonPool = _poolForLessonContext(levelPool, lessonContext);
    final quizzes = quizGenerator.generateForLevel(
      pool: lessonPool,
      activeLevel: activeLevel,
      limit: quizLimit,
    );

    return HskLearningSessionSeed(
      activeLevel: activeLevel,
      collocations: lessonPool,
      quizzes: quizzes,
    );
  }

  List<CollocationItem> _poolForLessonContext(
    List<CollocationItem> levelPool,
    LessonContext? context,
  ) {
    if (context == null) return levelPool;

    final conversationIds = context.conversationIds.toSet();
    final grammarIds = context.grammarIds.toSet();
    final exact = levelPool
        .where((item) {
          final conversationMatch = item.conversationIds.any(
            conversationIds.contains,
          );
          final grammarMatch = item.targetGrammarIds.any(grammarIds.contains);
          return conversationMatch || grammarMatch;
        })
        .toList(growable: false);
    if (exact.length >= 4) return exact;

    final conversationOnly = levelPool
        .where((item) {
          return item.conversationIds.any(conversationIds.contains);
        })
        .toList(growable: false);
    if (conversationOnly.length >= 4) return conversationOnly;

    final grammarOnly = levelPool
        .where((item) {
          return item.targetGrammarIds.any(grammarIds.contains);
        })
        .toList(growable: false);
    if (grammarOnly.length >= 4) return grammarOnly;

    return levelPool;
  }
}
