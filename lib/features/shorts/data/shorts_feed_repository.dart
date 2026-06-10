import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/audio/audio_urls.dart';
import '../../../core/constants/hsk_levels.dart';
import '../../../core/learning/collocation.dart';
import '../../../core/learning/learning_asset_repository.dart';
import '../../../core/learning/quiz_generator.dart';
import '../domain/short_feed_item.dart';
import 'hsk_grammar_asset_repository.dart';
import 'hsk_vocab_asset_repository.dart';

const _staticCollocationItemsPerLevel = 24;

class ShortsFeedLoadOptions {
  const ShortsFeedLoadOptions({
    this.staticItemsPerLevel = _staticCollocationItemsPerLevel,
    this.vocabItemsPerLevel,
    this.grammarItemsPerLevel,
    this.includeRemediation = true,
  });

  static const startup = ShortsFeedLoadOptions(
    staticItemsPerLevel: 8,
    vocabItemsPerLevel: 32,
    grammarItemsPerLevel: 10,
    includeRemediation: false,
  );

  final int staticItemsPerLevel;
  final int? vocabItemsPerLevel;
  final int? grammarItemsPerLevel;
  final bool includeRemediation;
}

class ShortsFeedSeed {
  const ShortsFeedSeed({required this.items, required this.remediationItems});

  final List<ShortFeedItem> items;
  final List<ShortFeedItem> remediationItems;
}

class ShortsFeedRepository {
  const ShortsFeedRepository({
    AssetBundle? bundle,
    HskVocabAssetRepository? vocabAssets,
    HskGrammarAssetRepository? grammarAssets,
  }) : _bundle = bundle,
       _vocabAssets = vocabAssets,
       _grammarAssets = grammarAssets;

  static const curatedHsk1Asset = 'assets/data/shorts/shorts_seed_hsk1.json';

  final AssetBundle? _bundle;
  final HskVocabAssetRepository? _vocabAssets;
  final HskGrammarAssetRepository? _grammarAssets;

  Future<ShortsFeedSeed> loadHsk1Feed({int generatedLimit = 8}) {
    return loadHskFeed(levels: const [1], activeLevel: 1);
  }

  Future<ShortsFeedSeed> loadHskFeed({
    List<int> levels = kHskLevels,
    int activeLevel = 2,
    ShortsFeedLoadOptions options = const ShortsFeedLoadOptions(),
  }) async {
    final orderedLevels = _orderedLevels(levels, activeLevel);
    final curated = await _loadCurated();
    final generated = [
      ...await _loadStaticCollocationShorts(
        orderedLevels,
        itemsPerLevel: options.staticItemsPerLevel,
      ),
      ...await _loadGeneratedFromVocab(
        orderedLevels,
        itemsPerLevel: options.vocabItemsPerLevel,
      ),
      ...await _loadGeneratedFromGrammar(
        orderedLevels,
        itemsPerLevel: options.grammarItemsPerLevel,
      ),
    ];
    final byId = <String, ShortFeedItem>{};

    for (final item in [...generated, ...curated]) {
      byId.putIfAbsent(item.id, () => item);
    }

    final items = byId.values.toList(growable: false);
    return ShortsFeedSeed(
      items: items,
      remediationItems: options.includeRemediation
          ? await _loadGeneratedRemediation(orderedLevels, items)
          : const [],
    );
  }

  List<int> _orderedLevels(List<int> levels, int activeLevel) {
    final available = levels.toSet();
    final result = <int>[];
    for (final level in [activeLevel, activeLevel - 1, activeLevel + 1]) {
      if (available.contains(level) && !result.contains(level)) {
        result.add(level);
      }
    }
    for (final level in levels) {
      if (!result.contains(level)) result.add(level);
    }
    return result;
  }

  Future<List<ShortFeedItem>> _loadCurated() async {
    final raw = await (_bundle ?? rootBundle).loadString(curatedHsk1Asset);
    final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return decoded.map(ShortFeedItem.fromJson).toList(growable: false);
  }

  Future<List<ShortFeedItem>> _loadStaticCollocationShorts(
    List<int> levels, {
    required int itemsPerLevel,
  }) async {
    if (itemsPerLevel <= 0) return const [];
    try {
      final learningAssets = LearningAssetRepository(bundle: _bundle);
      final pool = await learningAssets.loadStaticCollocationPoolForLevels(
        levels,
      );
      final result = <ShortFeedItem>[];
      const quizGenerator = QuizGenerator();

      for (final level in levels) {
        final levelItems = pool
            .where((item) => item.level == level)
            .take(itemsPerLevel)
            .toList(growable: false);

        for (final item in levelItems) {
          final context = _collocationToStaticContext(item);
          if (context != null) result.add(context);
        }

        final quizzes = quizGenerator.generateForLevel(
          pool: levelItems,
          activeLevel: level,
          limit: itemsPerLevel,
        );
        for (final quiz in quizzes) {
          result.add(_learningQuizToStaticShort(quiz, level));
        }
      }

      return result;
    } catch (_) {
      return const [];
    }
  }

  Future<List<ShortFeedItem>> _loadGeneratedFromVocab(
    List<int> levels, {
    required int? itemsPerLevel,
  }) async {
    try {
      final vocab = _takePerLevel(
        await (_vocabAssets ?? HskVocabAssetRepository(bundle: _bundle))
            .loadVocab(levels: levels),
        itemsPerLevel,
        (item) => item.level,
      );
      final result = <ShortFeedItem>[];
      for (var index = 0; index < vocab.length; index++) {
        final item = vocab[index];
        result.add(_vocabToContextShort(item));
        if (item.viShort.isNotEmpty) {
          result.add(_vocabToQuizShort(item, vocab, index));
        }
      }
      return result;
    } catch (_) {
      return const [];
    }
  }

  Future<List<ShortFeedItem>> _loadGeneratedFromGrammar(
    List<int> levels, {
    required int? itemsPerLevel,
  }) async {
    try {
      final grammar = _takePerLevel(
        await (_grammarAssets ?? HskGrammarAssetRepository(bundle: _bundle))
            .loadGrammar(levels: levels),
        itemsPerLevel,
        (item) => item.level,
      );
      return [for (final item in grammar) ..._grammarToContextShorts(item)];
    } catch (_) {
      return const [];
    }
  }

  List<T> _takePerLevel<T>(
    List<T> items,
    int? limit,
    int Function(T item) levelOf,
  ) {
    if (limit == null) return items;
    if (limit <= 0) return const [];
    final counts = <int, int>{};
    final result = <T>[];
    for (final item in items) {
      final level = levelOf(item);
      final count = counts[level] ?? 0;
      if (count >= limit) continue;
      counts[level] = count + 1;
      result.add(item);
    }
    return result;
  }

  ShortFeedItem _vocabToContextShort(HskVocabItem item) {
    final example = item.examples.isEmpty ? null : item.examples.first;
    return ShortFeedItem(
      id: 'vocab_${item.id}_context',
      type: ShortCardType.vocabContext,
      level: item.level,
      tags: _tagsFor(item),
      payload: ShortVocabContext(
        situation: example == null
            ? 'Từ vựng HSK${item.level}.'
            : 'Một ví dụ HSK${item.level} để nhớ từ ${item.hanzi}.',
        hanzi: example?.cn ?? item.hanzi,
        pinyin: example?.pinyin ?? item.pinyin,
        vi: example?.vi ?? item.viShort,
        targetVocabId: item.id,
        audioUrl: example == null
            ? AudioUrls.forVocab(item.id)
            : AudioUrls.forVocabExample(item.id, 0),
      ),
    );
  }

  ShortFeedItem _vocabToQuizShort(
    HskVocabItem item,
    List<HskVocabItem> vocab,
    int index,
  ) {
    return ShortFeedItem(
      id: 'vocab_${item.id}_quiz',
      type: ShortCardType.quickQuiz,
      level: item.level,
      tags: _tagsFor(item),
      payload: ShortQuickQuiz(
        prompt: '${item.hanzi} nghĩa là gì?',
        choices: _choicesFor(item, vocab, index),
        answer: item.viShort,
        explanation:
            '${item.hanzi}'
            '${item.pinyin.isEmpty ? '' : ' (${item.pinyin})'} nghĩa là "${item.viShort}".',
        audioUrl: AudioUrls.forVocab(item.id),
        targetVocabId: item.id,
        sourceCollocationId: item.id,
        quizType: QuizType.vocabRecognition.name,
        promptPinyin: item.pinyin,
        promptMeaning: item.viShort,
      ),
    );
  }

  List<ShortFeedItem> _grammarToContextShorts(HskGrammarItem item) {
    if (item.usages.length <= 1) {
      return [_grammarToContextShort(item, usageIndex: null)];
    }
    return [
      for (var index = 0; index < item.usages.length; index++)
        _grammarToContextShort(item, usageIndex: index),
    ];
  }

  ShortFeedItem _grammarToContextShort(
    HskGrammarItem item, {
    required int? usageIndex,
  }) {
    final usage = usageIndex == null ? null : item.usages[usageIndex];
    final suffix = usageIndex == null ? '' : '_u${usageIndex + 1}';
    final title = usage == null ? item.title : '${item.title} - ${usage.title}';
    final examples = _examplesForGrammarVariant(item, usageIndex);
    return ShortFeedItem(
      id: 'grammar_${item.id}${suffix}_context',
      type: ShortCardType.grammarContext,
      level: item.level,
      tags: _grammarTagsFor(item, usage?.title),
      payload: ShortGrammarContext(
        title: title,
        structure: item.structure,
        explanation: usage?.description ?? item.explanation,
        targetGrammarId: item.id,
        formulaParts: item.formulaParts
            .map(
              (part) => ShortGrammarFormulaPart(
                text: part.text,
                isHighlighted: part.isHighlighted,
              ),
            )
            .toList(growable: false),
        examples: examples
            .map(
              (example) => ShortGrammarExample(
                hanzi: example.hanzi,
                pinyin: example.pinyin,
                vi: example.vi,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  List<HskGrammarExample> _examplesForGrammarVariant(
    HskGrammarItem item,
    int? usageIndex,
  ) {
    if (item.examples.isEmpty) return const [];
    if (usageIndex == null) {
      return item.examples.take(1).toList(growable: false);
    }
    return [item.examples[usageIndex % item.examples.length]];
  }

  ShortFeedItem? _collocationToStaticContext(CollocationItem item) {
    if (item.targetVocabIds.isEmpty || item.textCn.isEmpty) return null;
    return ShortFeedItem(
      id: 'staticcol_${item.id}_context',
      type: ShortCardType.vocabContext,
      level: item.level,
      tags: ['HSK${item.level}', 'Câu mẫu', ...item.tags.take(2)],
      payload: ShortVocabContext(
        situation: 'Câu mẫu để luyện từ vựng trong ngữ cảnh.',
        hanzi: item.textCn,
        pinyin: item.pinyin,
        vi: item.textVi,
        targetVocabId: item.targetVocabIds.first,
      ),
    );
  }

  ShortFeedItem _learningQuizToStaticShort(LearningQuiz quiz, int level) {
    return ShortFeedItem(
      id: 'staticcol_${quiz.id}',
      type: ShortCardType.quickQuiz,
      level: level,
      tags: ['HSK$level', 'Câu mẫu'],
      payload: ShortQuickQuiz(
        prompt: quiz.prompt,
        choices: quiz.choices,
        answer: quiz.answer,
        explanation: _explanationFor(quiz),
        targetVocabId: quiz.targetId,
        targetGrammarIds: quiz.targetGrammarIds,
        sourceCollocationId: quiz.sourceCollocationId,
        quizType: quiz.quizType ?? quiz.type.name,
        promptPinyin: quiz.promptPinyin,
        promptMeaning: quiz.promptMeaning,
      ),
    );
  }

  List<String> _choicesFor(
    HskVocabItem item,
    List<HskVocabItem> vocab,
    int index,
  ) {
    final answer = item.viShort;
    final distractors = <String>[];
    final seen = {answer};
    final sameLevel = vocab.where((candidate) => candidate.level == item.level);

    for (final candidate in [...sameLevel, ...vocab]) {
      final vi = candidate.viShort;
      if (candidate.id == item.id || vi.isEmpty || !seen.add(vi)) continue;
      distractors.add(vi);
      if (distractors.length == 3) break;
    }

    final choices = [answer, ...distractors];
    if (choices.length <= 1) return choices;
    final shift = index % choices.length;
    return [
      for (var i = 0; i < choices.length; i++)
        choices[(i + shift) % choices.length],
    ];
  }

  List<String> _tagsFor(HskVocabItem item) {
    return ['HSK${item.level}', ...item.tags.take(2)];
  }

  List<String> _grammarTagsFor(HskGrammarItem item, String? usageTitle) {
    return [
      'HSK${item.level}',
      if (item.category.isNotEmpty) item.category,
      if (usageTitle != null && usageTitle.isNotEmpty) usageTitle,
    ];
  }

  Future<List<ShortFeedItem>> _loadGeneratedRemediation(
    List<int> levels,
    List<ShortFeedItem> primaryItems,
  ) async {
    try {
      final pool = await LearningAssetRepository(
        bundle: _bundle,
      ).loadStaticCollocationPoolForLevels(levels);
      final usedText = {for (final item in primaryItems) ?_textKeyFor(item)};
      final result = <ShortFeedItem>[];
      final seenIds = <String>{};
      const quizGenerator = QuizGenerator();

      for (final level in levels) {
        final levelPool = pool
            .where((item) => item.level == level)
            .toList(growable: false);
        final quizzes = quizGenerator.generateForLevel(
          pool: levelPool,
          activeLevel: level,
          limit: 80,
        );

        for (final item in levelPool) {
          final context = _collocationToRemediationContext(item);
          if (context == null) continue;
          final text = _textKeyFor(context);
          if (text == null || usedText.contains(text)) continue;
          if (seenIds.add(context.id)) {
            result.add(context);
            usedText.add(text);
          }
        }

        for (final quiz in quizzes) {
          final item = _learningQuizToRemediationShort(quiz, level);
          final text = _textKeyFor(item);
          if (text == null || usedText.contains(text)) continue;
          if (seenIds.add(item.id)) {
            result.add(item);
            usedText.add(text);
          }
        }
      }

      return result;
    } catch (_) {
      return const [];
    }
  }

  ShortFeedItem? _collocationToRemediationContext(CollocationItem item) {
    if (item.targetVocabIds.isEmpty || item.textCn.isEmpty) return null;
    return ShortFeedItem(
      id: 'remed_${item.id}_context',
      type: ShortCardType.vocabContext,
      level: item.level,
      tags: ['Ôn lại', ...item.tags.take(2)],
      payload: ShortVocabContext(
        situation: 'Một ví dụ khác để sửa lỗi gần đây.',
        hanzi: item.textCn,
        pinyin: item.pinyin,
        vi: item.textVi,
        targetVocabId: item.targetVocabIds.first,
      ),
    );
  }

  ShortFeedItem _learningQuizToRemediationShort(LearningQuiz quiz, int level) {
    return ShortFeedItem(
      id: 'remed_${quiz.id}',
      type: ShortCardType.quickQuiz,
      level: level,
      tags: const ['Ôn lại'],
      payload: ShortQuickQuiz(
        prompt: quiz.prompt,
        choices: quiz.choices,
        answer: quiz.answer,
        explanation: _explanationFor(quiz),
        targetVocabId: quiz.targetId,
        targetGrammarIds: quiz.targetGrammarIds,
        sourceCollocationId: quiz.sourceCollocationId,
        quizType: quiz.quizType ?? quiz.type.name,
        promptPinyin: quiz.promptPinyin,
        promptMeaning: quiz.promptMeaning,
      ),
    );
  }

  String _explanationFor(LearningQuiz quiz) {
    final meaning = quiz.promptMeaning;
    if (meaning != null && meaning.isNotEmpty) {
      return '"${quiz.prompt}" nghĩa là "$meaning".';
    }
    return 'Đáp án đúng là "${quiz.answer}".';
  }

  String? _textKeyFor(ShortFeedItem item) {
    final payload = item.payload;
    return switch (payload) {
      ShortVocabContext() => payload.hanzi,
      ShortGrammarContext() => payload.title,
      ShortQuickQuiz() => payload.prompt,
      ShortDialogue() => payload.title,
      ShortMiniTest() => payload.title,
      ShortSummary() => payload.title,
      _ => null,
    };
  }
}
