import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/features/dictionary/data/library_repository.dart';
import 'package:hanzify/features/dictionary/presentation/widgets/grammar_detail_sheet.dart';
import 'package:hanzify/features/dictionary/presentation/widgets/vocab_detail_sheet.dart';
import 'package:hanzify/features/shorts/domain/short_feed_item.dart';
import 'package:hanzify/features/shorts/domain/shorts_session.dart';
import 'package:hanzify/features/shorts/presentation/shorts_feed_screen.dart';

import '../support/profile_overrides.dart';

Widget _wrap([
  ShortsSession session = _testSession,
  LibraryRepository? libraryRepository,
  List<Override> overrides = const [],
]) {
  return ProviderScope(
    overrides: [
      ...overrides,
      shortsSessionLoaderProvider.overrideWith((ref) async => session),
      if (libraryRepository != null)
        libraryRepositoryProvider.overrideWithValue(libraryRepository),
    ],
    child: const MaterialApp(home: Scaffold(body: ShortsFeedScreen())),
  );
}

LibraryRepository _libraryRepository() {
  return LibraryRepository(bundle: _FakeAssetBundle(_libraryAssets));
}

const _testSession = ShortsSession(
  items: [
    ShortFeedItem(
      id: 'context_1',
      type: ShortCardType.vocabContext,
      level: 1,
      tags: ['test'],
      payload: ShortVocabContext(
        situation: 'Bạn đang gọi trà sữa.',
        hanzi: '我要一杯奶茶',
        pinyin: 'wo yao yi bei naicha',
        vi: 'Tôi muốn một ly trà sữa.',
        targetVocabId: 'hsk1_奶茶',
      ),
    ),
    ShortFeedItem(
      id: 'quiz_1',
      type: ShortCardType.quickQuiz,
      level: 1,
      tags: ['test'],
      payload: ShortQuickQuiz(
        prompt: '喜欢 nghĩa là gì?',
        choices: ['ăn', 'uống', 'thích'],
        answer: 'thích',
        explanation: '喜欢 dùng để nói thích một người hoặc sự vật.',
        targetVocabId: 'hsk1_喜欢',
        sourceCollocationId: 'col_like',
        quizType: 'vocabRecognition',
      ),
    ),
    ShortFeedItem(
      id: 'context_2',
      type: ShortCardType.vocabContext,
      level: 1,
      tags: ['test'],
      payload: ShortVocabContext(
        situation: 'Một câu đệm trong feed.',
        hanzi: '谢谢',
        pinyin: 'xie xie',
        vi: 'Cảm ơn.',
        targetVocabId: 'hsk1_谢谢',
      ),
    ),
    ShortFeedItem(
      id: 'dialogue_1',
      type: ShortCardType.dialogue,
      level: 1,
      tags: ['test'],
      payload: ShortDialogue(
        title: 'Đi mua trà sữa',
        context: 'Một hội thoại ngắn khi mua đồ uống.',
        lines: [
          ShortDialogueLine(
            speaker: 'A',
            hanzi: '我要一杯奶茶',
            pinyin: 'wo yao yi bei naicha',
            vi: 'Tôi muốn một ly trà sữa.',
          ),
          ShortDialogueLine(
            speaker: 'B',
            hanzi: '好的',
            pinyin: 'hao de',
            vi: 'Được.',
          ),
        ],
      ),
    ),
    ShortFeedItem(
      id: 'grammar_1',
      type: ShortCardType.grammarContext,
      level: 1,
      tags: ['test'],
      payload: ShortGrammarContext(
        title: 'Câu chủ-vị SVO',
        structure: 'S + V + O',
        explanation: 'Dùng để nói ai làm gì với một đối tượng.',
        targetGrammarId: 'g_svo',
        formulaParts: [
          ShortGrammarFormulaPart(text: 'S', isHighlighted: false),
          ShortGrammarFormulaPart(text: '+', isHighlighted: false),
          ShortGrammarFormulaPart(text: 'V', isHighlighted: true),
          ShortGrammarFormulaPart(text: '+', isHighlighted: false),
          ShortGrammarFormulaPart(text: 'O', isHighlighted: false),
        ],
        examples: [
          ShortGrammarExample(
            hanzi: '我喝水。',
            pinyin: 'Wǒ hē shuǐ.',
            vi: 'Tôi uống nước.',
          ),
        ],
      ),
    ),
  ],
  remediationItems: [
    ShortFeedItem(
      id: 'remed_like_1',
      type: ShortCardType.quickQuiz,
      level: 1,
      tags: ['Ôn lại'],
      payload: ShortQuickQuiz(
        prompt: '我喜欢喝茶 nghĩa là gì?',
        choices: ['Tôi thích uống trà', 'Tôi học uống trà'],
        answer: 'Tôi thích uống trà',
        explanation: 'Một ví dụ khác với 喜欢.',
        targetVocabId: 'hsk1_喜欢',
        sourceCollocationId: 'col_like_variant',
        quizType: 'vocabRecognition',
      ),
    ),
  ],
);

const _staticCollocationPinyinSession = ShortsSession(
  items: [
    ShortFeedItem(
      id: 'staticcol_context',
      type: ShortCardType.vocabContext,
      level: 2,
      tags: ['HSK2', 'Câu mẫu', 'study'],
      payload: ShortVocabContext(
        situation: 'Câu mẫu để luyện từ vựng trong ngữ cảnh.',
        hanzi: '如果有时间，我就学习中文。',
        pinyin: 'Rúguǒ yǒu shíjiān, wǒ jiù xuéxí Zhōngwén.',
        vi: 'Nếu có thời gian, tôi sẽ học tiếng Trung.',
        targetVocabId: 'hsk2_学习',
      ),
    ),
  ],
);

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  final visibleText = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .join(' | ');
  fail('Shorts feed did not render. Visible text: $visibleText');
}

Future<void> _jumpToPage(WidgetTester tester, int page) async {
  final pageView = tester.widget<PageView>(find.byType(PageView));
  pageView.controller!.jumpToPage(page);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shorts static collocation shows full pinyin', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      _wrap(_staticCollocationPinyinSession, null, overrides),
    );
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(PageView));

    expect(find.text('如果有时间，我就学习中文。'), findsOneWidget);
    expect(
      find.text('Rúguǒ yǒu shíjiān, wǒ jiù xuéxí Zhōngwén.'),
      findsOneWidget,
    );
  });

  testWidgets('shorts vocab CTA opens vocab detail sheet', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      _wrap(_testSession, _libraryRepository(), overrides),
    );
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(PageView));

    await tester.ensureVisible(find.text('Chi tiết từ'));
    await tester.tap(find.text('Chi tiết từ'));
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(VocabDetailSheet));

    expect(find.byType(VocabDetailSheet), findsOneWidget);
    expect(find.text('奶茶'), findsWidgets);
  });

  testWidgets('shorts grammar CTA opens grammar detail sheet', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      _wrap(_testSession, _libraryRepository(), overrides),
    );
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(PageView));

    await _jumpToPage(tester, 4);
    await tester.ensureVisible(find.text('Chi tiết ngữ pháp'));
    await tester.tap(find.text('Chi tiết ngữ pháp'));
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(GrammarDetailSheet));

    expect(find.byType(GrammarDetailSheet), findsOneWidget);
    expect(find.text('Cách dùng'), findsOneWidget);
  });

  testWidgets('shorts quiz has countdown and feedback popup', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(_testSession, null, overrides));
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(PageView));

    await tester.drag(find.byType(PageView), const Offset(0, -420));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await _pumpUntilFound(tester, find.text('喜欢 nghĩa là gì?'));

    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.text('喜欢 nghĩa là gì?'), findsOneWidget);

    await tester.tap(find.text('thích'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Chính xác'), findsOneWidget);
    expect(find.text('Đáp án đúng'), findsOneWidget);
    expect(find.text('Giải thích'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('shorts dialogue hides pinyin and meaning behind toggles', (
    tester,
  ) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(_testSession, null, overrides));
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(PageView));

    await _jumpToPage(tester, 3);

    expect(find.text('Đi mua trà sữa'), findsOneWidget);
    expect(find.text('wo yao yi bei naicha'), findsNothing);
    expect(find.text('Tôi muốn một ly trà sữa.'), findsNothing);

    await tester.tap(find.text('Pinyin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('wo yao yi bei naicha'), findsOneWidget);

    await tester.tap(find.text('Nghĩa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tôi muốn một ly trà sữa.'), findsOneWidget);
  });

  testWidgets('shorts inserts generated remediation after a wrong answer', (
    tester,
  ) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(_testSession, null, overrides));
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(PageView));

    await tester.drag(find.byType(PageView), const Offset(0, -420));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await _pumpUntilFound(tester, find.text('喜欢 nghĩa là gì?'));

    await tester.tap(find.text('ăn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Chưa đúng'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    for (var page = 5; page <= 50; page++) {
      await _jumpToPage(tester, page);
      if (find.text('我喜欢喝茶 nghĩa là gì?').evaluate().isNotEmpty) break;
    }

    expect(find.text('我喜欢喝茶 nghĩa là gì?'), findsOneWidget);
  });

  testWidgets('shorts renders grammar cards with formula and examples', (
    tester,
  ) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(_testSession, null, overrides));
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(PageView));

    await _jumpToPage(tester, 4);

    expect(find.text('Ngữ pháp'), findsOneWidget);
    expect(find.text('Câu chủ-vị SVO'), findsOneWidget);
    expect(find.text('V'), findsOneWidget);
    expect(find.text('我喝水。'), findsOneWidget);
    expect(find.text('Tôi uống nước.'), findsOneWidget);
  });

  testWidgets(
    'shorts shows a three-question mini test after 20 content cards',
    (tester) async {
      final overrides = await profileTestOverrides();

      await tester.pumpWidget(_wrap(_miniTestSession, null, overrides));
      await tester.pump();
      await _pumpUntilFound(tester, find.byType(PageView));

      await _jumpToPage(tester, 20);

      await _pumpUntilFound(tester, find.text('Mini test'));
      expect(find.text('1/3'), findsOneWidget);

      await tester.tap(find.text('một'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2/3'), findsOneWidget);
    },
  );
}

final _miniTestSession = ShortsSession(
  items: [
    for (var index = 0; index < 20; index++)
      ShortFeedItem(
        id: 'context_$index',
        type: ShortCardType.vocabContext,
        level: 1,
        tags: const ['test'],
        payload: ShortVocabContext(
          situation: 'Card học $index',
          hanzi: '词$index',
          pinyin: 'ci $index',
          vi: 'Từ $index',
          targetVocabId: 'hsk1_$index',
        ),
      ),
    const ShortFeedItem(
      id: 'mini_test_after_20',
      type: ShortCardType.miniTest,
      level: 0,
      tags: ['Mini test'],
      payload: ShortMiniTest(
        title: 'Mini test',
        quizzes: [
          ShortQuickQuiz(
            prompt: '一 nghĩa là gì?',
            choices: ['một', 'hai', 'ba'],
            answer: 'một',
            explanation: '一 là một.',
          ),
          ShortQuickQuiz(
            prompt: '二 nghĩa là gì?',
            choices: ['một', 'hai', 'ba'],
            answer: 'hai',
            explanation: '二 là hai.',
          ),
          ShortQuickQuiz(
            prompt: '三 nghĩa là gì?',
            choices: ['một', 'hai', 'ba'],
            answer: 'ba',
            explanation: '三 là ba.',
          ),
        ],
      ),
    ),
  ],
);

final _libraryAssets = {
  'assets/data/hsk1.json': jsonEncode([
    {
      'id': 'hsk1_奶茶',
      'hanzi': '奶茶',
      'pinyin': 'nǎichá',
      'pinyinNormalized': 'naicha',
      'characters': ['奶', '茶'],
      'meanings': [
        {'pos': 'noun', 'vi': 'trà sữa', 'en': 'milk tea'},
      ],
      'exampleSentences': [
        {
          'cn': '我要一杯奶茶。',
          'pinyin': 'Wǒ yào yì bēi nǎichá.',
          'vi': 'Tôi muốn một ly trà sữa.',
        },
      ],
      'level': 1,
      'wordType': 'noun',
      'tags': ['đồ uống'],
      'frequency': '',
    },
  ]),
  'assets/data/grammar_hsk1.json': jsonEncode([
    {
      'id': 'g_svo',
      'title': 'Câu chủ-vị SVO',
      'structure': 'S + V + O',
      'explanation': 'Dùng để nói ai làm gì với một đối tượng.',
      'level': 1,
      'category': 'basic',
      'formulaParts': [
        {'text': 'S', 'isHighlighted': false},
        {'text': '+', 'isHighlighted': false},
        {'text': 'V', 'isHighlighted': true},
        {'text': '+', 'isHighlighted': false},
        {'text': 'O', 'isHighlighted': false},
      ],
      'usages': [
        {
          'icon': '',
          'title': 'Nói hành động cơ bản',
          'description': 'Đặt chủ ngữ trước động từ và tân ngữ.',
        },
      ],
      'examples': [
        {'zh': '我喝水。', 'pinyin': 'Wǒ hē shuǐ.', 'vi': 'Tôi uống nước.'},
      ],
      'commonMistakes': [],
      'relatedGrammar': [],
    },
  ]),
};

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw FlutterError('Missing test asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = assets[key];
    if (value == null) {
      throw FlutterError('Missing test asset: $key');
    }
    return value;
  }
}
