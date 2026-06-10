import 'short_feed_item.dart';

const int kShortsRecentTargetWindow = 8;

class ShortsSession {
  const ShortsSession({
    required this.items,
    this.sourceItems = const [],
    this.remediationItems = const [],
    this.nextCursor = 0,
    this.contentCount = 0,
    this.blockQuizzes = const [],
  });

  final List<ShortFeedItem> items;
  final List<ShortFeedItem> sourceItems;
  final List<ShortFeedItem> remediationItems;
  final int nextCursor;
  final int contentCount;
  final List<ShortQuickQuiz> blockQuizzes;
}

class ShortsSessionBuilder {
  const ShortsSessionBuilder({
    this.activeLevel = 2,
    this.initialContentCount = 40,
    this.sourceItemLimit = 240,
    this.miniTestInterval = 20,
    this.miniTestSize = 3,
  });

  final int activeLevel;
  final int initialContentCount;
  final int sourceItemLimit;
  final int miniTestInterval;
  final int miniTestSize;

  ShortsSession build(
    List<ShortFeedItem> pool, {
    List<ShortFeedItem> remediationItems = const [],
  }) {
    final sourceItems = _buildSourceItems(pool);
    final generated = generateItems(
      sourceItems: sourceItems,
      nextCursor: 0,
      contentCount: 0,
      blockQuizzes: const [],
      contentTarget: initialContentCount,
    );

    return ShortsSession(
      items: List.unmodifiable(generated.items),
      sourceItems: List.unmodifiable(sourceItems),
      remediationItems: List.unmodifiable(remediationItems),
      nextCursor: generated.nextCursor,
      contentCount: generated.contentCount,
      blockQuizzes: List.unmodifiable(generated.blockQuizzes),
    );
  }

  List<ShortFeedItem> _buildSourceItems(List<ShortFeedItem> pool) {
    final regularPool = pool
        .where(
          (item) =>
              item.type != ShortCardType.summary &&
              item.type != ShortCardType.miniTest,
        )
        .where(_passesQualityFloor)
        .toList(growable: false);
    final availableLevels = regularPool.map((item) => item.level).toSet();

    final result = <ShortFeedItem>[];
    final used = <String>{};
    final recentTargets = <String>[];
    final targetUseCounts = <String, int>{};
    final typeCounts = <ShortCardType, int>{};
    final levelCounts = <int, int>{};

    final limit = sourceItemLimit <= 0
        ? regularPool.length
        : sourceItemLimit.clamp(0, regularPool.length);
    while (used.length < regularPool.length && result.length < limit) {
      final next =
          _takeBestNext(
            regularPool,
            used: used,
            recentTargets: recentTargets,
            targetUseCounts: targetUseCounts,
            typeCounts: typeCounts,
            levelCounts: levelCounts,
            availableLevels: availableLevels,
            respectRecentTargets: true,
          ) ??
          _takeBestNext(
            regularPool,
            used: used,
            recentTargets: recentTargets,
            targetUseCounts: targetUseCounts,
            typeCounts: typeCounts,
            levelCounts: levelCounts,
            availableLevels: availableLevels,
            respectRecentTargets: false,
          );
      if (next == null) break;

      result.add(next);
      used.add(next.id);
      _rememberRecentTarget(recentTargets, next);
      final targetKey = shortsTargetKeyForItem(next);
      if (targetKey != null) {
        targetUseCounts[targetKey] = (targetUseCounts[targetKey] ?? 0) + 1;
      }
      typeCounts[next.type] = (typeCounts[next.type] ?? 0) + 1;
      levelCounts[next.level] = (levelCounts[next.level] ?? 0) + 1;
    }

    return result;
  }

  ShortFeedItem? _takeBestNext(
    List<ShortFeedItem> items, {
    required Set<String> used,
    required List<String> recentTargets,
    required Map<String, int> targetUseCounts,
    required Map<ShortCardType, int> typeCounts,
    required Map<int, int> levelCounts,
    required Set<int> availableLevels,
    required bool respectRecentTargets,
  }) {
    ShortFeedItem? best;
    var bestScore = double.negativeInfinity;
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (used.contains(item.id)) continue;
      final targetKey = shortsTargetKeyForItem(item);
      if (respectRecentTargets &&
          targetKey != null &&
          recentTargets.contains(targetKey)) {
        continue;
      }

      final score = _candidateScore(
        item,
        sourceOrder: index,
        resultPosition: typeCounts.values.fold<int>(0, (a, b) => a + b),
        targetUseCount: targetKey == null ? 0 : targetUseCounts[targetKey] ?? 0,
        typeCount: typeCounts[item.type] ?? 0,
        levelCount: levelCounts[item.level] ?? 0,
        availableLevels: availableLevels,
      );
      if (score > bestScore) {
        best = item;
        bestScore = score;
      }
    }
    return best;
  }

  double _candidateScore(
    ShortFeedItem item, {
    required int sourceOrder,
    required int resultPosition,
    required int targetUseCount,
    required int typeCount,
    required int levelCount,
    required Set<int> availableLevels,
  }) {
    final preferredLevel = _preferredLevelForPosition(
      resultPosition,
      availableLevels,
    );
    final preferredType = _preferredTypeForPosition(resultPosition);
    final targetNovelty = targetUseCount == 0 ? 180.0 : -160.0 * targetUseCount;
    return _levelScore(item.level, preferredLevel, levelCount) +
        _typeScore(item.type, preferredType, typeCount) +
        _qualityScore(item) +
        targetNovelty -
        sourceOrder * 0.001;
  }

  int _preferredLevelForPosition(int position, Set<int> availableLevels) {
    if (availableLevels.isEmpty) return activeLevel;
    final preferred = [
      activeLevel,
      activeLevel,
      activeLevel,
      activeLevel - 1,
      activeLevel + 1,
    ].where(availableLevels.contains).toList(growable: false);
    if (preferred.isNotEmpty) {
      return preferred[position % preferred.length];
    }
    final sorted = availableLevels.toList()..sort();
    return sorted.first;
  }

  ShortCardType _preferredTypeForPosition(int position) {
    const pattern = <ShortCardType>[
      ShortCardType.vocabContext,
      ShortCardType.quickQuiz,
      ShortCardType.grammarContext,
      ShortCardType.vocabContext,
      ShortCardType.dialogue,
      ShortCardType.listening,
      ShortCardType.quickQuiz,
      ShortCardType.vocabContext,
    ];
    return pattern[position % pattern.length];
  }

  double _levelScore(int level, int preferredLevel, int levelCount) {
    if (level == preferredLevel) return 1200 - levelCount * 0.05;
    if (level == activeLevel) return 650 - levelCount * 0.05;
    if (level == activeLevel - 1 || level == activeLevel + 1) {
      return 420 - (level - activeLevel).abs() * 10 - levelCount * 0.05;
    }
    return 80 - (level - activeLevel).abs() * 20 - levelCount * 0.05;
  }

  double _typeScore(
    ShortCardType type,
    ShortCardType preferredType,
    int typeCount,
  ) {
    final preferredBonus = type == preferredType ? 260.0 : 0.0;
    final scarcityBonus = switch (type) {
      ShortCardType.dialogue || ShortCardType.listening => 30.0,
      ShortCardType.grammarContext => 18.0,
      ShortCardType.quickQuiz => 12.0,
      ShortCardType.vocabContext => 8.0,
      ShortCardType.miniTest || ShortCardType.summary => 0.0,
    };
    return preferredBonus + scarcityBonus - typeCount * 0.03;
  }

  bool _passesQualityFloor(ShortFeedItem item) {
    final payload = item.payload;
    return switch (payload) {
      ShortVocabContext() =>
        payload.hanzi.isNotEmpty &&
            payload.vi.isNotEmpty &&
            payload.targetVocabId.isNotEmpty &&
            (!item.tags.contains('Câu sinh') ||
                (payload.pinyin.isNotEmpty &&
                    _hanziLength(payload.hanzi) >= 7)),
      ShortGrammarContext() =>
        payload.title.isNotEmpty &&
            payload.targetGrammarId.isNotEmpty &&
            (payload.formulaParts.isNotEmpty || payload.examples.isNotEmpty),
      ShortQuickQuiz() =>
        payload.prompt.isNotEmpty &&
            payload.answer.isNotEmpty &&
            payload.explanation.isNotEmpty &&
            payload.choices.length >= 2,
      ShortDialogue() => payload.title.isNotEmpty && payload.context.isNotEmpty,
      ShortMiniTest() || ShortSummary() => false,
      _ => true,
    };
  }

  double _qualityScore(ShortFeedItem item) {
    final payload = item.payload;
    return switch (payload) {
      ShortVocabContext() => _vocabContextQuality(item, payload),
      ShortGrammarContext() => _grammarContextQuality(payload),
      ShortQuickQuiz() => _quizQuality(payload),
      ShortDialogue() => 88 + payload.lines.length.clamp(0, 4) * 2,
      _ => 0,
    };
  }

  double _vocabContextQuality(ShortFeedItem item, ShortVocabContext payload) {
    var score = 70.0;
    if (payload.pinyin.isNotEmpty) score += 10;
    if (payload.audioUrl != null) score += 4;
    if (_hanziLength(payload.hanzi) >= 7) score += 12;
    if (payload.situation.startsWith('Một ví dụ HSK')) score += 8;
    if (item.tags.contains('Câu sinh')) score += 24;
    if (item.tags.contains('Câu mẫu')) score += 14;
    if (payload.situation.startsWith('Từ vựng')) score -= 12;
    return score;
  }

  double _grammarContextQuality(ShortGrammarContext payload) {
    var score = 74.0;
    if (payload.structure.isNotEmpty) score += 6;
    if (payload.formulaParts.isNotEmpty) score += 8;
    if (payload.examples.isNotEmpty) score += 10;
    if (payload.examples.any((example) => example.pinyin.isNotEmpty)) {
      score += 4;
    }
    return score;
  }

  double _quizQuality(ShortQuickQuiz payload) {
    var score = 68.0;
    if (payload.choices.length >= 4) score += 8;
    if (payload.promptMeaning != null && payload.promptMeaning!.isNotEmpty) {
      score += 5;
    }
    if (payload.promptPinyin != null && payload.promptPinyin!.isNotEmpty) {
      score += 5;
    }
    if (payload.targetVocabId != null || payload.targetGrammarIds.isNotEmpty) {
      score += 5;
    }
    return score;
  }

  int _hanziLength(String value) {
    return value.runes.where((rune) => rune >= 0x4E00 && rune <= 0x9FFF).length;
  }

  ShortsGenerationResult generateItems({
    required List<ShortFeedItem> sourceItems,
    required int nextCursor,
    required int contentCount,
    required List<ShortQuickQuiz> blockQuizzes,
    required int contentTarget,
  }) {
    final items = <ShortFeedItem>[];
    final quizzes = List<ShortQuickQuiz>.from(blockQuizzes);
    var cursor = nextCursor;
    var count = contentCount;

    while (sourceItems.isNotEmpty && count < contentTarget) {
      final item = _itemAt(sourceItems, cursor);
      cursor++;
      items.add(item);
      count++;

      final payload = item.payload;
      if (payload is ShortQuickQuiz) {
        quizzes.add(payload);
      }

      if (count % miniTestInterval == 0) {
        final miniTest = _miniTestFor(
          sourceItems: sourceItems,
          nextCursor: cursor,
          contentCount: count,
          blockQuizzes: quizzes,
        );
        if (miniTest != null) {
          items.add(miniTest);
        }
        quizzes.clear();
      }
    }

    return ShortsGenerationResult(
      items: items,
      nextCursor: cursor,
      contentCount: count,
      blockQuizzes: quizzes,
    );
  }

  ShortFeedItem _itemAt(List<ShortFeedItem> sourceItems, int cursor) {
    final cycle = cursor ~/ sourceItems.length;
    final item = sourceItems[cursor % sourceItems.length];
    if (cycle == 0) return item;
    return _copyItemWithId(item, '${item.id}__loop_$cycle');
  }

  ShortFeedItem? _miniTestFor({
    required List<ShortFeedItem> sourceItems,
    required int nextCursor,
    required int contentCount,
    required List<ShortQuickQuiz> blockQuizzes,
  }) {
    final quizzes = blockQuizzes.length <= miniTestSize
        ? List<ShortQuickQuiz>.from(blockQuizzes)
        : blockQuizzes.sublist(blockQuizzes.length - miniTestSize);

    var cursor = nextCursor;
    while (quizzes.length < miniTestSize &&
        sourceItems.isNotEmpty &&
        cursor < nextCursor + sourceItems.length) {
      final payload = _itemAt(sourceItems, cursor).payload;
      if (payload is ShortQuickQuiz && !quizzes.contains(payload)) {
        quizzes.add(payload);
      }
      cursor++;
    }

    if (quizzes.isEmpty) return null;
    return ShortFeedItem(
      id: 'mini_test_after_$contentCount',
      type: ShortCardType.miniTest,
      level: 0,
      tags: const ['Mini test'],
      payload: ShortMiniTest(
        title: 'Mini test',
        quizzes: quizzes.take(miniTestSize).toList(growable: false),
      ),
    );
  }

  ShortFeedItem _copyItemWithId(ShortFeedItem item, String id) {
    return ShortFeedItem(
      id: id,
      type: item.type,
      level: item.level,
      tags: item.tags,
      payload: item.payload,
    );
  }
}

class ShortsGenerationResult {
  const ShortsGenerationResult({
    required this.items,
    required this.nextCursor,
    required this.contentCount,
    required this.blockQuizzes,
  });

  final List<ShortFeedItem> items;
  final int nextCursor;
  final int contentCount;
  final List<ShortQuickQuiz> blockQuizzes;
}

class ShortsSessionState {
  const ShortsSessionState({
    this.items = const [],
    this.sourceItems = const [],
    this.remediationItems = const [],
    this.remediationCursorByTarget = const {},
    this.currentIndex = 0,
    this.nextCursor = 0,
    this.contentCount = 0,
    this.blockQuizzes = const [],
    this.selectedAnswers = const {},
    this.correctCount = 0,
    this.incorrectCount = 0,
  });

  final List<ShortFeedItem> items;
  final List<ShortFeedItem> sourceItems;
  final List<ShortFeedItem> remediationItems;
  final Map<String, int> remediationCursorByTarget;
  final int currentIndex;
  final int nextCursor;
  final int contentCount;
  final List<ShortQuickQuiz> blockQuizzes;
  final Map<String, String> selectedAnswers;
  final int correctCount;
  final int incorrectCount;

  ShortFeedItem? get currentItem {
    if (items.isEmpty || currentIndex < 0 || currentIndex >= items.length) {
      return null;
    }
    return items[currentIndex];
  }

  ShortsSessionState copyWith({
    List<ShortFeedItem>? items,
    List<ShortFeedItem>? sourceItems,
    List<ShortFeedItem>? remediationItems,
    Map<String, int>? remediationCursorByTarget,
    int? currentIndex,
    int? nextCursor,
    int? contentCount,
    List<ShortQuickQuiz>? blockQuizzes,
    Map<String, String>? selectedAnswers,
    int? correctCount,
    int? incorrectCount,
  }) {
    return ShortsSessionState(
      items: items ?? this.items,
      sourceItems: sourceItems ?? this.sourceItems,
      remediationItems: remediationItems ?? this.remediationItems,
      remediationCursorByTarget:
          remediationCursorByTarget ?? this.remediationCursorByTarget,
      currentIndex: currentIndex ?? this.currentIndex,
      nextCursor: nextCursor ?? this.nextCursor,
      contentCount: contentCount ?? this.contentCount,
      blockQuizzes: blockQuizzes ?? this.blockQuizzes,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
    );
  }
}

void _rememberRecentTarget(List<String> recentTargets, ShortFeedItem item) {
  final targetKey = shortsTargetKeyForItem(item);
  if (targetKey == null) return;
  recentTargets.add(targetKey);
  if (recentTargets.length > kShortsRecentTargetWindow) {
    recentTargets.removeAt(0);
  }
}

bool shortsIsContentCard(ShortFeedItem item) {
  return item.type != ShortCardType.miniTest &&
      item.type != ShortCardType.summary;
}

String? shortsTargetKeyForItem(ShortFeedItem item) {
  final payload = item.payload;
  return switch (payload) {
    ShortVocabContext() => 'vocab:${payload.targetVocabId}',
    ShortGrammarContext() => 'grammar:${payload.targetGrammarId}',
    ShortQuickQuiz() => shortsTargetKeyForQuiz(payload),
    _ => null,
  };
}

String? shortsTargetKeyForQuiz(ShortQuickQuiz quiz) {
  final vocabId = quiz.targetVocabId;
  if (vocabId != null && vocabId.isNotEmpty) return 'vocab:$vocabId';
  for (final grammarId in quiz.targetGrammarIds) {
    if (grammarId.isNotEmpty) return 'grammar:$grammarId';
  }
  final collocationId = quiz.sourceCollocationId;
  if (collocationId != null && collocationId.isNotEmpty) {
    return 'collocation:$collocationId';
  }
  return null;
}
