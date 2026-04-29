import 'dart:convert';

import 'package:flutter/services.dart';

import '../../audio/audio_urls.dart';
import '../domain/collocation.dart';
import '../domain/lesson_context.dart';
import '../application/quiz_generator.dart';
import '../application/sentence_generator.dart';

class LearningAssetRepository {
  const LearningAssetRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const collocationPoolAsset =
      'assets/data/generated/collocation_pool_hsk1_4.json';
  static const conversationAsset = 'assets/data/conversation.json';
  static const collocationsDbAsset =
      'assets/data/generated/collocations_db.json';
  static const framesBankAsset = 'assets/data/generated/frames_bank.json';

  final AssetBundle? _bundle;

  Future<List<CollocationItem>> loadCollocationPool() async {
    final bundle = _bundle ?? rootBundle;
    try {
      final poolRaw = await bundle.loadString(collocationPoolAsset);
      final conversationRaw = await bundle.loadString(conversationAsset);
      final lineIndexes = _conversationLineIndexes(conversationRaw);
      final pool = (jsonDecode(poolRaw) as List)
          .cast<Map<String, dynamic>>()
          .map(CollocationItem.fromJson)
          .toList(growable: false);
      return _withConversationAudio(pool, lineIndexes);
    } catch (_) {
      // Tests can provide only generator assets; keep the runtime fallback.
    }

    final collocationsRaw = await bundle.loadString(collocationsDbAsset);
    final framesRaw = await bundle.loadString(framesBankAsset);
    final collocationsDb = await CollocationsDb.fromAsset(collocationsRaw);
    final framesBank = await FramesBank.fromAsset(framesRaw);
    final generator = SentenceGenerator(
      collocationsDb: collocationsDb,
      framesBank: framesBank,
      vocabIndex: _vocabIndexFor(collocationsDb),
      seed: 1,
    );

    final items = <CollocationItem>[];
    for (var level = 1; level <= 4; level++) {
      items.addAll(_generateLevelItems(collocationsDb, generator, level));
    }
    return items;
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

  Map<String, VocabLite> _vocabIndexFor(CollocationsDb db) {
    final index = <String, VocabLite>{};
    for (final entry in [
      ...db.verbObject.values,
      ...db.adjNoun.values,
      ...db.measureNoun.values,
    ]) {
      index[entry.headHanzi] = VocabLite(
        hanzi: entry.headHanzi,
        pinyin: entry.headPinyin,
        vi: entry.headVi,
        pos: entry.headPos,
        level: entry.headLevel,
      );
      for (final partner in entry.collocations) {
        index.putIfAbsent(
          partner.objectHanzi,
          () => VocabLite(
            hanzi: partner.objectHanzi,
            pinyin: partner.objectPinyin,
            vi: partner.objectVi,
            pos: 'n',
            level: partner.objectLevel,
          ),
        );
      }
    }
    return index;
  }

  List<CollocationItem> _generateLevelItems(
    CollocationsDb db,
    SentenceGenerator generator,
    int level,
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
      );
      for (final sentence in sentences) {
        if (!seenText.add(sentence.zh)) continue;
        items.add(
          CollocationItem(
            id: 'gen_${level}_${items.length.toString().padLeft(5, '0')}',
            level: level,
            source: 'on_demand_generator',
            textCn: sentence.zh,
            pinyin: _generatedPinyin(entry, sentence.partnerHanzi),
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

  String _generatedPinyin(CollocationEntry entry, String partnerHanzi) {
    CollocationPartner? partner;
    for (final item in entry.collocations) {
      if (item.objectHanzi == partnerHanzi) {
        partner = item;
        break;
      }
    }
    if (partner == null || partner.objectPinyin.isEmpty) {
      return entry.headPinyin;
    }
    return '${entry.headPinyin} ${partner.objectPinyin}'.trim();
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
