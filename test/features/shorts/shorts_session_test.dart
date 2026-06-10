import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/features/shorts/application/shorts_session_controller.dart';
import 'package:hanzify/features/shorts/domain/short_feed_item.dart';
import 'package:hanzify/features/shorts/domain/shorts_session.dart';

void main() {
  test('session builder keeps mixed rhythm and excludes summaries', () {
    final items = [
      for (var index = 0; index < 12; index++)
        _item('v$index', ShortCardType.vocabContext),
      for (var index = 0; index < 12; index++)
        _item('g$index', ShortCardType.grammarContext),
      for (var index = 0; index < 12; index++)
        _item('q$index', ShortCardType.quickQuiz),
      _item('d1', ShortCardType.dialogue),
      _item('l1', ShortCardType.listening),
      _item('m1', ShortCardType.miniTest),
      _item('s1', ShortCardType.summary),
    ];

    final session = const ShortsSessionBuilder(
      initialContentCount: 10,
    ).build(items);

    expect(session.items.first.type, ShortCardType.vocabContext);
    expect(session.items[1].type, ShortCardType.quickQuiz);
    expect(session.items[2].type, ShortCardType.grammarContext);
    expect(
      session.items.any((item) => item.type == ShortCardType.summary),
      isFalse,
    );
    expect(
      session.items.map((item) => item.id).toSet().length,
      session.items.length,
    );
  });

  test(
    'session builder inserts three-question mini test after 20 content cards',
    () {
      final session = const ShortsSessionBuilder(
        initialContentCount: 20,
      ).build(_largePool());

      final miniTest = session.items[20];
      expect(
        session.items
            .take(20)
            .where((item) => item.type == ShortCardType.miniTest),
        isEmpty,
      );
      expect(miniTest.type, ShortCardType.miniTest);
      expect((miniTest.payload as ShortMiniTest).quizzes, hasLength(3));
    },
  );

  test('session builder prioritizes active, previous, and next levels', () {
    final session = const ShortsSessionBuilder(
      activeLevel: 2,
      initialContentCount: 40,
    ).build(_balancedPool());
    final first40 = _contentCards(session.items).take(40).toList();

    expect(_countBy(first40, (item) => item.level), {2: 24, 1: 8, 3: 8});
  });

  test('session builder keeps high target diversity in first 40 cards', () {
    final session = const ShortsSessionBuilder(
      activeLevel: 2,
      initialContentCount: 40,
    ).build(_balancedPool());
    final first40 = _contentCards(session.items).take(40).toList();
    final uniqueTargets = first40
        .map(shortsTargetKeyForItem)
        .whereType<String>()
        .toSet();

    expect(uniqueTargets.length, greaterThanOrEqualTo(28));
  });

  test('session builder avoids target repetition in recent window', () {
    final session = const ShortsSessionBuilder(
      activeLevel: 2,
      initialContentCount: 40,
    ).build(_balancedPool());
    final first40 = _contentCards(session.items).take(40).toList();

    expect(_recentTargetCollisions(first40), 0);
  });

  test('session builder caps large source pools for fast loading', () {
    final session = const ShortsSessionBuilder(
      activeLevel: 2,
      initialContentCount: 40,
      sourceItemLimit: 80,
    ).build(_veryLargePool());

    expect(session.sourceItems, hasLength(80));
    expect(session.items, isNotEmpty);
  });

  test('controller appends infinite items with unique ids near feed end', () {
    final provider =
        NotifierProvider<ShortsSessionController, ShortsSessionState>(
          ShortsSessionController.new,
        );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final session = const ShortsSessionBuilder(
      initialContentCount: 20,
    ).build(_largePool());
    final controller = container.read(provider.notifier)..start(session);
    final initialLength = container.read(provider).items.length;

    controller.goTo(initialLength - 3);

    final state = container.read(provider);
    expect(state.items.length, greaterThan(initialLength));
    expect(
      state.items.map((item) => item.id).toSet().length,
      state.items.length,
    );
  });

  test(
    'controller hydrates source and remediation without resetting progress',
    () {
      final provider =
          NotifierProvider<ShortsSessionController, ShortsSessionState>(
            ShortsSessionController.new,
          );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final quizItem = _targetQuizItem('q1');
      final initialItems = [
        quizItem,
        for (var index = 1; index <= 12; index++) _contextItem('c$index'),
      ];
      final controller = container.read(provider.notifier)
        ..start(ShortsSession(items: initialItems, sourceItems: initialItems));

      controller.goTo(1);
      controller.hydrate(
        ShortsSession(
          items: [quizItem, _contextItem('c1'), _contextItem('c2')],
          sourceItems: [quizItem, _contextItem('c1'), _contextItem('c13')],
          remediationItems: [_remediationQuizItem('r1')],
        ),
      );

      final state = container.read(provider);
      expect(state.currentIndex, 1);
      expect(state.items.map((item) => item.id), [
        'q1',
        for (var index = 1; index <= 12; index++) 'c$index',
      ]);
      expect(state.sourceItems.map((item) => item.id), [
        'q1',
        for (var index = 1; index <= 13; index++) 'c$index',
      ]);
      expect(state.remediationItems.single.id, 'r1');
    },
  );

  test('controller locks answer and updates score once', () {
    final item = ShortFeedItem(
      id: 'q1',
      type: ShortCardType.quickQuiz,
      level: 1,
      tags: const [],
      payload: const ShortQuickQuiz(
        prompt: '喜欢 nghĩa là gì?',
        choices: ['thích', 'học'],
        answer: 'thích',
        explanation: '喜欢 là thích.',
      ),
    );
    final provider =
        NotifierProvider<ShortsSessionController, ShortsSessionState>(
          ShortsSessionController.new,
        );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(provider.notifier)
      ..start(ShortsSession(items: [item]));

    controller.selectAnswer(item, 'thích');
    controller.selectAnswer(item, 'học');

    final state = container.read(provider);
    expect(state.selectedAnswers[item.id], 'thích');
    expect(state.correctCount, 1);
    expect(state.incorrectCount, 0);
  });

  test('controller inserts remediation after recent target window', () {
    final provider =
        NotifierProvider<ShortsSessionController, ShortsSessionState>(
          ShortsSessionController.new,
        );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final quizItem = _targetQuizItem('q1');
    final controller = container.read(provider.notifier)
      ..start(
        ShortsSession(
          items: [
            quizItem,
            _contextItem('c1'),
            _contextItem('c2'),
            _contextItem('c3'),
            _contextItem('c4'),
          ],
          remediationItems: [_remediationQuizItem('r1')],
        ),
      );

    controller.selectAnswer(quizItem, 'học');

    final ids = container.read(provider).items.map((item) => item.id).toList();
    expect(ids.sublist(1, 5), ['c1', 'c2', 'c3', 'c4']);
    expect(ids[5], 'r1');
    expect(container.read(provider).incorrectCount, 1);
  });

  test('controller treats timeout as wrong answer for remediation', () {
    final provider =
        NotifierProvider<ShortsSessionController, ShortsSessionState>(
          ShortsSessionController.new,
        );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final quizItem = _targetQuizItem('q1');
    final quiz = quizItem.payload as ShortQuickQuiz;
    final controller = container.read(provider.notifier)
      ..start(
        ShortsSession(
          items: [
            quizItem,
            _contextItem('c1'),
            _contextItem('c2'),
            _contextItem('c3'),
          ],
          remediationItems: [_remediationQuizItem('r1')],
        ),
      );

    controller.selectQuizAnswer(
      itemId: quizItem.id,
      answer: '',
      correctAnswer: quiz.answer,
      quiz: quiz,
    );

    final state = container.read(provider);
    expect(state.selectedAnswers[quizItem.id], '');
    expect(state.items.last.id, 'r1');
    expect(state.incorrectCount, 1);
  });

  test(
    'controller keeps feed moving when remediation candidate is missing',
    () {
      final provider =
          NotifierProvider<ShortsSessionController, ShortsSessionState>(
            ShortsSessionController.new,
          );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final quizItem = _targetQuizItem('q1');
      final controller = container.read(provider.notifier)
        ..start(
          ShortsSession(
            items: [quizItem, _contextItem('c1'), _contextItem('c2')],
          ),
        );

      controller.selectAnswer(quizItem, 'học');

      final state = container.read(provider);
      expect(state.items.map((item) => item.id), ['q1', 'c1', 'c2']);
      expect(state.incorrectCount, 1);
    },
  );

  test('controller avoids repeating the same target in recent window', () {
    final provider =
        NotifierProvider<ShortsSessionController, ShortsSessionState>(
          ShortsSessionController.new,
        );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final quizItem = _targetQuizItem('q1');
    final controller = container.read(provider.notifier)
      ..start(
        ShortsSession(
          items: [
            quizItem,
            _contextItem('c1'),
            _contextItem('c2'),
            _contextItem('same_target_context', targetVocabId: 'hsk1_喜欢'),
            _contextItem('c4'),
            _contextItem('c5'),
            _contextItem('c6'),
          ],
          remediationItems: [_remediationQuizItem('r1')],
        ),
      );

    controller.selectAnswer(quizItem, 'học');

    final ids = container.read(provider).items.map((item) => item.id).toList();
    expect(ids.indexOf('r1'), 7);
    expect(ids.sublist(4, 7), ['c4', 'c5', 'c6']);
  });
}

List<ShortFeedItem> _largePool() {
  return [
    for (var index = 0; index < 24; index++)
      _item('v$index', ShortCardType.vocabContext),
    for (var index = 0; index < 24; index++)
      _item('g$index', ShortCardType.grammarContext),
    for (var index = 0; index < 24; index++)
      _item('q$index', ShortCardType.quickQuiz),
    _item('d1', ShortCardType.dialogue),
    _item('l1', ShortCardType.listening),
    _item('s1', ShortCardType.summary),
  ];
}

List<ShortFeedItem> _balancedPool() {
  return [
    for (final level in [1, 2, 3, 4])
      for (var index = 0; index < 36; index++)
        _targetedItem(
          'l${level}_$index',
          switch (index % 3) {
            0 => ShortCardType.vocabContext,
            1 => ShortCardType.quickQuiz,
            _ => ShortCardType.grammarContext,
          },
          level: level,
          target: 'hsk${level}_$index',
        ),
  ];
}

List<ShortFeedItem> _veryLargePool() {
  return [
    for (final level in [1, 2, 3, 4])
      for (var index = 0; index < 260; index++)
        _targetedItem(
          'large_l${level}_$index',
          switch (index % 3) {
            0 => ShortCardType.vocabContext,
            1 => ShortCardType.quickQuiz,
            _ => ShortCardType.grammarContext,
          },
          level: level,
          target: 'hsk${level}_large_$index',
        ),
  ];
}

ShortFeedItem _item(String id, ShortCardType type) {
  final payload = switch (type) {
    ShortCardType.vocabContext => const ShortVocabContext(
      situation: 'Một tình huống ngắn.',
      hanzi: '我喜欢茶。',
      pinyin: 'wo xihuan cha',
      vi: 'Tôi thích trà.',
      targetVocabId: 'hsk1_喜欢',
    ),
    ShortCardType.grammarContext => const ShortGrammarContext(
      title: 'Câu SVO',
      structure: 'S + V + O',
      explanation: 'Cấu trúc câu cơ bản.',
      targetGrammarId: 'g_svo',
      formulaParts: [
        ShortGrammarFormulaPart(text: 'S', isHighlighted: false),
        ShortGrammarFormulaPart(text: 'V', isHighlighted: true),
        ShortGrammarFormulaPart(text: 'O', isHighlighted: false),
      ],
      examples: [
        ShortGrammarExample(
          hanzi: '我喝茶。',
          pinyin: 'Wǒ hē chá.',
          vi: 'Tôi uống trà.',
        ),
      ],
    ),
    ShortCardType.quickQuiz || ShortCardType.listening => const ShortQuickQuiz(
      prompt: '喜欢 nghĩa là gì?',
      choices: ['thích', 'học'],
      answer: 'thích',
      explanation: '喜欢 là thích.',
    ),
    ShortCardType.dialogue => const ShortDialogue(
      title: 'Đi mua trà',
      context: 'Một đoạn thoại ngắn.',
      lines: [],
    ),
    ShortCardType.miniTest => const ShortMiniTest(
      title: 'Mini test',
      quizzes: [
        ShortQuickQuiz(
          prompt: '喜欢 nghĩa là gì?',
          choices: ['thích', 'học'],
          answer: 'thích',
          explanation: '喜欢 là thích.',
        ),
      ],
    ),
    ShortCardType.summary => const ShortSummary(
      title: 'Tổng kết',
      message: 'Bạn vừa học xong.',
    ),
  };
  return ShortFeedItem(
    id: id,
    type: type,
    level: 1,
    tags: const [],
    payload: payload,
  );
}

ShortFeedItem _targetedItem(
  String id,
  ShortCardType type, {
  required int level,
  required String target,
}) {
  final payload = switch (type) {
    ShortCardType.vocabContext => ShortVocabContext(
      situation: 'Một ví dụ HSK$level để nhớ từ 词$target.',
      hanzi: '我正在学习词$target。',
      pinyin: 'Wǒ zhèngzài xuéxí cí $target.',
      vi: 'Tôi đang học từ $target.',
      targetVocabId: target,
    ),
    ShortCardType.grammarContext => ShortGrammarContext(
      title: 'Ngữ pháp $target',
      structure: 'S + V + O',
      explanation: 'Cấu trúc luyện tập $target.',
      targetGrammarId: 'g_$target',
      formulaParts: const [
        ShortGrammarFormulaPart(text: 'S', isHighlighted: false),
        ShortGrammarFormulaPart(text: 'V', isHighlighted: true),
        ShortGrammarFormulaPart(text: 'O', isHighlighted: false),
      ],
      examples: const [
        ShortGrammarExample(
          hanzi: '我喝水。',
          pinyin: 'Wǒ hē shuǐ.',
          vi: 'Tôi uống nước.',
        ),
      ],
    ),
    ShortCardType.quickQuiz || ShortCardType.listening => ShortQuickQuiz(
      prompt: '词$target nghĩa là gì?',
      choices: ['nghĩa $target', 'nhiễu A', 'nhiễu B', 'nhiễu C'],
      answer: 'nghĩa $target',
      explanation: '词$target nghĩa là nghĩa $target.',
      targetVocabId: target,
      sourceCollocationId: 'col_$target',
      quizType: 'vocabRecognition',
      promptPinyin: 'cí $target',
      promptMeaning: 'nghĩa $target',
    ),
    ShortCardType.dialogue => const ShortDialogue(
      title: 'Hội thoại',
      context: 'Một đoạn thoại ngắn.',
      lines: [],
    ),
    ShortCardType.miniTest => const ShortMiniTest(
      title: 'Mini test',
      quizzes: [],
    ),
    ShortCardType.summary => const ShortSummary(
      title: 'Tổng kết',
      message: 'Bạn vừa học xong.',
    ),
  };
  return ShortFeedItem(
    id: id,
    type: type,
    level: level,
    tags: const [],
    payload: payload,
  );
}

ShortFeedItem _targetQuizItem(String id) {
  return ShortFeedItem(
    id: id,
    type: ShortCardType.quickQuiz,
    level: 1,
    tags: const [],
    payload: const ShortQuickQuiz(
      prompt: '喜欢 nghĩa là gì?',
      choices: ['thích', 'học'],
      answer: 'thích',
      explanation: '喜欢 là thích.',
      targetVocabId: 'hsk1_喜欢',
      sourceCollocationId: 'col_like',
      quizType: 'vocabRecognition',
    ),
  );
}

ShortFeedItem _contextItem(String id, {String? targetVocabId}) {
  return ShortFeedItem(
    id: id,
    type: ShortCardType.vocabContext,
    level: 1,
    tags: const [],
    payload: ShortVocabContext(
      situation: 'Một tình huống ngắn.',
      hanzi: '句子$id',
      pinyin: 'juzi $id',
      vi: 'Câu $id.',
      targetVocabId: targetVocabId ?? 'hsk1_$id',
    ),
  );
}

ShortFeedItem _remediationQuizItem(String id) {
  return ShortFeedItem(
    id: id,
    type: ShortCardType.quickQuiz,
    level: 1,
    tags: const ['Ôn lại'],
    payload: const ShortQuickQuiz(
      prompt: '我喜欢茶 nghĩa là gì?',
      choices: ['Tôi thích trà', 'Tôi học trà'],
      answer: 'Tôi thích trà',
      explanation: 'Một ví dụ khác với 喜欢.',
      targetVocabId: 'hsk1_喜欢',
      sourceCollocationId: 'col_like_variant',
      quizType: 'vocabRecognition',
    ),
  );
}

List<ShortFeedItem> _contentCards(List<ShortFeedItem> items) {
  return items.where(shortsIsContentCard).toList(growable: false);
}

Map<Object, int> _countBy<T>(Iterable<T> values, Object Function(T) keyOf) {
  final result = <Object, int>{};
  for (final value in values) {
    final key = keyOf(value);
    result[key] = (result[key] ?? 0) + 1;
  }
  return result;
}

int _recentTargetCollisions(List<ShortFeedItem> items) {
  var collisions = 0;
  for (var index = 0; index < items.length; index++) {
    final targetKey = shortsTargetKeyForItem(items[index]);
    if (targetKey == null) continue;
    final start = index - kShortsRecentTargetWindow < 0
        ? 0
        : index - kShortsRecentTargetWindow;
    for (var previous = start; previous < index; previous++) {
      if (shortsTargetKeyForItem(items[previous]) == targetKey) {
        collisions++;
        break;
      }
    }
  }
  return collisions;
}
