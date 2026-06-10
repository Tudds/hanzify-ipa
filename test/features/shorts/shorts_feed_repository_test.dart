import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/learning_asset_repository.dart';
import 'package:hanzify/features/shorts/data/hsk_grammar_asset_repository.dart';
import 'package:hanzify/features/shorts/data/hsk_vocab_asset_repository.dart';
import 'package:hanzify/features/shorts/data/shorts_feed_repository.dart';
import 'package:hanzify/features/shorts/domain/short_feed_item.dart';
import 'package:hanzify/features/shorts/domain/shorts_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads HSK vocab assets in round-robin level order', () async {
    final repository = HskVocabAssetRepository(
      bundle: _FakeAssetBundle(_assets),
    );

    final items = await repository.loadVocab(levels: const [1, 2, 3, 4]);

    expect(items.map((item) => item.level).take(4), [1, 2, 3, 4]);
    expect(items.first.hanzi, '爱');
    expect(items.first.viShort, 'yêu');
    expect(items.first.examples.first.cn, '我爱中文。');
  });

  test('loads HSK grammar assets in round-robin level order', () async {
    final repository = HskGrammarAssetRepository(
      bundle: _FakeAssetBundle(_assets),
    );

    final items = await repository.loadGrammar(levels: const [1, 2, 3, 4]);

    expect(items.map((item) => item.level), [1, 2, 3, 4]);
    expect(items.first.title, 'Câu SVO');
    expect(items.first.formulaParts.first.text, 'S');
    expect(items.first.examples.first.hanzi, '我喝水。');
  });

  test('loads mixed HSK1-HSK4 shorts feed from vocab assets', () async {
    final bundle = _FakeAssetBundle({
      ..._assets,
      ShortsFeedRepository.curatedHsk1Asset: jsonEncode([_curatedDialogue]),
    });
    final repository = ShortsFeedRepository(
      bundle: bundle,
      vocabAssets: HskVocabAssetRepository(bundle: bundle),
      grammarAssets: HskGrammarAssetRepository(bundle: bundle),
    );

    final seed = await repository.loadHskFeed(levels: const [1, 2, 3, 4]);
    final items = seed.items;

    expect(items.map((item) => item.id).toSet().length, items.length);
    expect(items.map((item) => item.level).toSet(), containsAll([1, 2, 3, 4]));
    expect(items.any((item) => item.payload is ShortVocabContext), isTrue);
    expect(items.any((item) => item.payload is ShortGrammarContext), isTrue);
    expect(items.any((item) => item.payload is ShortQuickQuiz), isTrue);
    expect(items.any((item) => item.payload is ShortDialogue), isTrue);
  });

  test(
    'startup load options cap generated shorts and skip remediation',
    () async {
      final bundle = _FakeAssetBundle({
        ..._assets,
        ShortsFeedRepository.curatedHsk1Asset: jsonEncode([_curatedDialogue]),
      });
      final repository = ShortsFeedRepository(
        bundle: bundle,
        vocabAssets: HskVocabAssetRepository(bundle: bundle),
        grammarAssets: HskGrammarAssetRepository(bundle: bundle),
      );

      final seed = await repository.loadHskFeed(
        levels: const [1, 2],
        options: const ShortsFeedLoadOptions(
          staticItemsPerLevel: 0,
          vocabItemsPerLevel: 1,
          grammarItemsPerLevel: 1,
          includeRemediation: false,
        ),
      );
      final generatedVocabContexts = seed.items
          .where((item) => item.id.startsWith('vocab_'))
          .where((item) => item.payload is ShortVocabContext)
          .toList(growable: false);
      final generatedGrammarContexts = seed.items
          .where((item) => item.id.startsWith('grammar_'))
          .where((item) => item.payload is ShortGrammarContext)
          .toList(growable: false);

      expect(seed.remediationItems, isEmpty);
      expect(generatedVocabContexts, hasLength(2));
      expect(generatedGrammarContexts, hasLength(2));
    },
  );

  test('adds static collocation shorts to primary feed', () async {
    final bundle = _FakeAssetBundle({
      ..._assets,
      ShortsFeedRepository.curatedHsk1Asset: jsonEncode([_curatedDialogue]),
      LearningAssetRepository.collocationPoolAsset: jsonEncode([
        _collocation(
          id: 'static_study',
          textCn: '今天我学习中文。',
          textVi: 'Hôm nay tôi học tiếng Trung.',
          targetVocabId: 'hsk2_学习',
        ),
        _collocation(
          id: 'static_intro',
          textCn: '我介绍朋友。',
          textVi: 'Tôi giới thiệu bạn bè.',
          targetVocabId: 'hsk2_介绍',
        ),
      ]),
      LearningAssetRepository.conversationAsset: jsonEncode([]),
    });
    final repository = ShortsFeedRepository(
      bundle: bundle,
      vocabAssets: HskVocabAssetRepository(bundle: bundle),
      grammarAssets: HskGrammarAssetRepository(bundle: bundle),
    );

    final seed = await repository.loadHskFeed(levels: const [2]);
    final staticContexts = seed.items
        .where((item) => item.tags.contains('Câu mẫu'))
        .map((item) => item.payload)
        .whereType<ShortVocabContext>()
        .toList(growable: false);
    final staticQuizzes = seed.items
        .where((item) => item.tags.contains('Câu mẫu'))
        .map((item) => item.payload)
        .whereType<ShortQuickQuiz>()
        .toList(growable: false);

    expect(staticContexts, isNotEmpty);
    expect(staticContexts.any((item) => item.hanzi == '今天我学习中文。'), isTrue);
    expect(staticContexts.every((item) => item.pinyin.isNotEmpty), isTrue);
    expect(staticQuizzes, isNotEmpty);
    expect(
      staticQuizzes.first.sourceCollocationId,
      isIn(['static_intro', 'static_study']),
    );
    expect(staticQuizzes.first.quizType, isNotEmpty);
    expect(seed.items.any((item) => item.tags.contains('Câu sinh')), isFalse);
  });

  test(
    'generated collocation pool keeps only quality-approved contexts',
    () async {
      final bundle = _FakeAssetBundle({
        ..._assets,
        LearningAssetRepository.collocationsDbAsset: jsonEncode(
          _generatedCollocationsDb,
        ),
        LearningAssetRepository.framesBankAsset: jsonEncode(_framesBank),
      });

      final pool = await LearningAssetRepository(
        bundle: bundle,
      ).loadGeneratedCollocationPool();

      expect(pool, isNotEmpty);
      expect(pool.every((item) => _hanziLength(item.textCn) >= 7), isTrue);
      expect(pool.every((item) => _viWordCount(item.textVi) >= 4), isTrue);
      expect(pool.every((item) => item.targetVocabIds.isNotEmpty), isTrue);
      expect(
        pool.every((item) => item.targetGrammarIds.any((id) => id.isNotEmpty)),
        isTrue,
      );
      expect(pool.every((item) => item.pinyin.isNotEmpty), isTrue);
    },
  );

  test(
    'fills generated pinyin from vocab assets when collocation pinyin is missing',
    () async {
      final bundle = _FakeAssetBundle({
        ..._assets,
        'assets/data/hsk2.json': jsonEncode([
          _vocab(
            id: 'hsk2_学习',
            level: 2,
            hanzi: '学习',
            pinyin: 'xuéxí',
            vi: 'học',
          ),
          _vocab(
            id: 'hsk2_中文',
            level: 2,
            hanzi: '中文',
            pinyin: 'Zhōngwén',
            vi: 'tiếng Trung',
          ),
        ]),
        LearningAssetRepository.collocationsDbAsset: jsonEncode(
          _generatedCollocationsDbMissingPinyin,
        ),
        LearningAssetRepository.framesBankAsset: jsonEncode(_framesBank),
      });

      final pool = await LearningAssetRepository(
        bundle: bundle,
      ).loadGeneratedCollocationPool();

      expect(pool, hasLength(1));
      expect(pool.single.pinyin, 'Rúguǒ yǒu shíjiān, wǒ jiù xuéxí Zhōngwén.');
    },
  );

  test(
    'does not use generated collocations when static pool is unavailable',
    () async {
      final bundle = _FakeAssetBundle({
        ..._assets,
        ShortsFeedRepository.curatedHsk1Asset: jsonEncode([_curatedDialogue]),
        LearningAssetRepository.collocationsDbAsset: jsonEncode(
          _generatedCollocationsDb,
        ),
        LearningAssetRepository.framesBankAsset: jsonEncode(_weakFramesBank),
      });
      final repository = ShortsFeedRepository(
        bundle: bundle,
        vocabAssets: HskVocabAssetRepository(bundle: bundle),
        grammarAssets: HskGrammarAssetRepository(bundle: bundle),
      );

      final seed = await repository.loadHskFeed(levels: const [2]);
      final contexts = seed.items
          .map((item) => item.payload)
          .whereType<ShortVocabContext>()
          .toList(growable: false);

      expect(seed.items.any((item) => item.tags.contains('Câu sinh')), isFalse);
      expect(contexts.any((item) => item.hanzi == '如果有时间，我就学习中文。'), isFalse);
      expect(seed.remediationItems, isEmpty);
    },
  );

  test('splits multi-usage grammar into short variants', () async {
    final bundle = _FakeAssetBundle({
      ..._assets,
      'assets/data/grammar_hsk2.json': jsonEncode([
        {
          'id': 'g2_de',
          'title': 'Bổ ngữ 得',
          'structure': 'V + 得 + Adj',
          'explanation': 'Giải thích dài cho nhiều cách dùng.',
          'level': 2,
          'category': 'complement',
          'formulaParts': [
            {'text': 'V', 'isHighlighted': false},
            {'text': '得', 'isHighlighted': true},
            {'text': 'Adj', 'isHighlighted': false},
          ],
          'usages': [
            {
              'title': 'Đánh giá trình độ',
              'description': 'Đánh giá người làm một việc tốt hay chưa tốt.',
            },
            {
              'title': 'Mức độ hoàn thành',
              'description': 'Nói mức độ hành động đạt được sau khi làm.',
            },
          ],
          'examples': [
            {
              'zh': '他说得很好。',
              'pinyin': 'Tā shuō de hěn hǎo.',
              'vi': 'Anh ấy nói rất tốt.',
            },
            {
              'zh': '她写得很漂亮。',
              'pinyin': 'Tā xiě de hěn piàoliang.',
              'vi': 'Cô ấy viết rất đẹp.',
            },
          ],
        },
      ]),
      ShortsFeedRepository.curatedHsk1Asset: jsonEncode([_curatedDialogue]),
    });
    final repository = ShortsFeedRepository(
      bundle: bundle,
      vocabAssets: HskVocabAssetRepository(bundle: bundle),
      grammarAssets: HskGrammarAssetRepository(bundle: bundle),
    );

    final seed = await repository.loadHskFeed(levels: const [2]);
    final variants = seed.items
        .map((item) => item.payload)
        .whereType<ShortGrammarContext>()
        .where((item) => item.targetGrammarId == 'g2_de')
        .toList(growable: false);

    expect(variants, hasLength(2));
    expect(variants.map((item) => item.title), [
      'Bổ ngữ 得 - Đánh giá trình độ',
      'Bổ ngữ 得 - Mức độ hoàn thành',
    ]);
    expect(variants.every((item) => item.examples.length == 1), isTrue);
    expect(variants.first.explanation, contains('Đánh giá'));
  });

  test('loads curated HSK1 shorts feed', () async {
    final seed = await const ShortsFeedRepository().loadHsk1Feed();
    final items = seed.items;

    expect(items, isNotEmpty);
    expect(items.map((item) => item.id).toSet().length, items.length);
    expect(items.any((item) => item.payload is ShortVocabContext), isTrue);
    expect(items.any((item) => item.payload is ShortGrammarContext), isTrue);
    expect(items.any((item) => item.payload is ShortQuickQuiz), isTrue);
    expect(items.any((item) => item.payload is ShortDialogue), isTrue);
  });

  test(
    'real Shorts feed first 40 is active-level and target diverse',
    () async {
      final seed = await const ShortsFeedRepository().loadHskFeed(
        activeLevel: 2,
      );
      final session = const ShortsSessionBuilder(
        activeLevel: 2,
      ).build(seed.items, remediationItems: seed.remediationItems);
      final first40 = session.items
          .where(shortsIsContentCard)
          .take(40)
          .toList(growable: false);
      final levelCounts = _countBy(first40, (item) => item.level);
      final uniqueTargets = first40
          .map(shortsTargetKeyForItem)
          .whereType<String>()
          .toSet();
      final staticContexts = first40
          .where((item) => item.tags.contains('Câu mẫu'))
          .map((item) => item.payload)
          .whereType<ShortVocabContext>()
          .toList(growable: false);

      expect(levelCounts[2], greaterThanOrEqualTo(20));
      expect(levelCounts[2], greaterThan(levelCounts[1] ?? 0));
      expect(levelCounts[2], greaterThan(levelCounts[3] ?? 0));
      expect(uniqueTargets.length, greaterThanOrEqualTo(28));
      expect(_recentTargetCollisions(first40), 0);
      expect(staticContexts, isNotEmpty);
      expect(staticContexts.every((item) => item.pinyin.isNotEmpty), isTrue);
    },
  );

  test('generates remediation variants with metadata and no audio', () async {
    final bundle = _FakeAssetBundle({
      ..._assets,
      ShortsFeedRepository.curatedHsk1Asset: jsonEncode([_curatedDialogue]),
      LearningAssetRepository.conversationAsset: jsonEncode([]),
      LearningAssetRepository.collocationPoolAsset: jsonEncode([
        for (var index = 0; index < 13; index++)
          _collocation(
            id: 'col_${index.toString().padLeft(2, '0')}',
            textCn: index.isEven ? '我学习中文$index。' : '我介绍朋友$index。',
            textVi: index.isEven
                ? 'Tôi học tiếng Trung $index.'
                : 'Tôi giới thiệu bạn bè $index.',
            targetVocabId: index.isEven ? 'hsk2_学习' : 'hsk2_介绍',
          ),
      ]),
    });
    final repository = ShortsFeedRepository(
      bundle: bundle,
      vocabAssets: HskVocabAssetRepository(bundle: bundle),
      grammarAssets: HskGrammarAssetRepository(bundle: bundle),
    );

    final seed = await repository.loadHskFeed(levels: const [2]);
    final primaryPrompts = seed.items
        .map((item) => item.payload)
        .whereType<ShortQuickQuiz>()
        .map((quiz) => quiz.prompt)
        .toSet();
    final remediationQuiz = seed.remediationItems
        .map((item) => item.payload)
        .whereType<ShortQuickQuiz>()
        .first;

    expect(remediationQuiz.targetVocabId, isIn(['hsk2_学习', 'hsk2_介绍']));
    expect(remediationQuiz.sourceCollocationId, startsWith('col_'));
    expect(remediationQuiz.quizType, isNotEmpty);
    expect(remediationQuiz.audioUrl, isNull);
    expect(primaryPrompts, isNot(contains(remediationQuiz.prompt)));
  });
}

final _assets = {
  'assets/data/hsk1.json': jsonEncode([
    _vocab(
      id: 'hsk1_爱',
      level: 1,
      hanzi: '爱',
      pinyin: 'ài',
      vi: 'yêu',
      exampleCn: '我爱中文。',
      examplePinyin: 'Wǒ ài Zhōngwén.',
      exampleVi: 'Tôi yêu tiếng Trung.',
    ),
    _vocab(id: 'hsk1_水', level: 1, hanzi: '水', pinyin: 'shuǐ', vi: 'nước'),
  ]),
  'assets/data/hsk2.json': jsonEncode([
    _vocab(
      id: 'hsk2_爱好',
      level: 2,
      hanzi: '爱好',
      pinyin: 'àihào',
      vi: 'sở thích',
    ),
    _vocab(
      id: 'hsk2_运动',
      level: 2,
      hanzi: '运动',
      pinyin: 'yùndòng',
      vi: 'vận động',
    ),
  ]),
  'assets/data/hsk3.json': jsonEncode([
    _vocab(
      id: 'hsk3_安排',
      level: 3,
      hanzi: '安排',
      pinyin: 'ānpái',
      vi: 'sắp xếp',
    ),
    _vocab(id: 'hsk3_比较', level: 3, hanzi: '比较', pinyin: 'bǐjiào', vi: 'khá'),
  ]),
  'assets/data/hsk4.json': jsonEncode([
    _vocab(
      id: 'hsk4_安全',
      level: 4,
      hanzi: '安全',
      pinyin: 'ānquán',
      vi: 'an toàn',
    ),
    _vocab(
      id: 'hsk4_办法',
      level: 4,
      hanzi: '办法',
      pinyin: 'bànfǎ',
      vi: 'cách làm',
    ),
  ]),
  'assets/data/grammar_hsk1.json': jsonEncode([
    _grammar(id: 'g1_svo', level: 1, title: 'Câu SVO'),
  ]),
  'assets/data/grammar_hsk2.json': jsonEncode([
    _grammar(id: 'g2_ba', level: 2, title: 'Câu 把'),
  ]),
  'assets/data/grammar_hsk3.json': jsonEncode([
    _grammar(id: 'g3_bi', level: 3, title: 'So sánh 比'),
  ]),
  'assets/data/grammar_hsk4.json': jsonEncode([
    _grammar(id: 'g4_chule', level: 4, title: '除了...以外'),
  ]),
};

Map<String, Object?> _vocab({
  required String id,
  required int level,
  required String hanzi,
  required String pinyin,
  required String vi,
  String? exampleCn,
  String? examplePinyin,
  String? exampleVi,
}) {
  return {
    'id': id,
    'hanzi': hanzi,
    'pinyin': pinyin,
    'meanings': [
      {'pos': 'n', 'vi': vi, 'en': vi},
    ],
    'exampleSentences': [
      if (exampleCn != null)
        {'cn': exampleCn, 'pinyin': examplePinyin, 'vi': exampleVi},
    ],
    'level': level,
    'wordType': 'n',
    'tags': ['test'],
    'frequency': 'high',
  };
}

Map<String, Object?> _grammar({
  required String id,
  required int level,
  required String title,
}) {
  return {
    'id': id,
    'title': title,
    'structure': 'S + V + O',
    'explanation': 'Cấu trúc câu cơ bản.',
    'level': level,
    'category': 'basic',
    'formulaParts': [
      {'text': 'S', 'isHighlighted': false},
      {'text': 'V', 'isHighlighted': true},
      {'text': 'O', 'isHighlighted': false},
    ],
    'examples': [
      {'zh': '我喝水。', 'pinyin': 'Wǒ hē shuǐ.', 'vi': 'Tôi uống nước.'},
    ],
  };
}

Map<String, Object?> _collocation({
  required String id,
  required String textCn,
  required String textVi,
  required String targetVocabId,
}) {
  return {
    'id': id,
    'level': 2,
    'source': 'test',
    'textCn': textCn,
    'pinyin': 'pinyin',
    'textVi': textVi,
    'targetVocabIds': [targetVocabId],
    'targetGrammarIds': ['g_svo'],
    'conversationIds': [],
    'tags': ['test'],
    'difficulty': 2,
  };
}

const _curatedDialogue = {
  'id': 'curated_dialogue',
  'type': 'dialogue',
  'level': 1,
  'tags': ['curated'],
  'payload': {
    'title': 'Chào hỏi',
    'context': 'Một hội thoại ngắn.',
    'lines': [
      {'speaker': 'A', 'hanzi': '你好', 'pinyin': 'nǐ hǎo', 'vi': 'Xin chào'},
    ],
  },
};

const _generatedCollocationsDb = {
  'version': '1.0',
  'generated_at': '2026-05-09',
  'description': 'test',
  'sources': ['test'],
  'verb_object': {
    '学习': {
      'head_hanzi': '学习',
      'head_pinyin': 'xuéxí',
      'head_vi': 'học',
      'head_level': 2,
      'head_pos': 'v',
      'collocations': [
        {
          'object_hanzi': '中文',
          'object_pinyin': 'Zhōngwén',
          'object_vi': 'tiếng Trung',
          'object_level': 2,
          'frequency': 3,
          'sources': ['test'],
          'scenario': 'study',
        },
        {
          'object_hanzi': '汉字',
          'object_pinyin': 'Hànzì',
          'object_vi': 'chữ Hán',
          'object_level': 2,
          'frequency': 2,
          'sources': ['test'],
          'scenario': 'culture',
        },
      ],
    },
  },
  'adj_noun': {},
  'measure_noun': {},
};

const _generatedCollocationsDbMissingPinyin = {
  'version': '1.0',
  'generated_at': '2026-05-09',
  'description': 'test',
  'sources': ['test'],
  'verb_object': {
    '学习': {
      'head_hanzi': '学习',
      'head_pinyin': '',
      'head_vi': 'học',
      'head_level': 2,
      'head_pos': 'v',
      'collocations': [
        {
          'object_hanzi': '中文',
          'object_pinyin': '',
          'object_vi': 'tiếng Trung',
          'object_level': 2,
          'frequency': 3,
          'sources': ['test'],
          'scenario': 'study',
        },
      ],
    },
  },
  'adj_noun': {},
  'measure_noun': {},
};

const _framesBank = {
  'version': '1.0',
  'total_frames': 1,
  'by_level': {'2': 1},
  'description': 'test',
  'frames': [
    {
      'id': 'F-H2-test',
      'zh': '如果有时间，我就{VO}。',
      'pinyin': 'Rúguǒ yǒu shíjiān, wǒ jiù {PVO}.',
      'vi': 'Nếu có thời gian, tôi sẽ {VVO}.',
      'slot_types': ['VO'],
      'time': 'now',
      'mood': 'statement',
      'grammar_focus': 'g_svo',
      'hsk_level_min': 2,
      'complexity': 3,
    },
  ],
};

const _weakFramesBank = {
  'version': '1.0',
  'total_frames': 1,
  'by_level': {'2': 1},
  'description': 'test',
  'frames': [
    {
      'id': 'F-H2-weak',
      'zh': '我{VO}。',
      'vi': 'Tôi {VVO}.',
      'slot_types': ['VO'],
      'time': 'now',
      'mood': 'statement',
      'grammar_focus': 'g_svo',
      'hsk_level_min': 2,
      'complexity': 1,
    },
  ],
};

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

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}
