import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/learning_asset_repository.dart';

class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw Exception('missing asset $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  test('HSK2 session factory loads collocations and quizzes', () async {
    final bundle = _MemoryAssetBundle({
      LearningAssetRepository.collocationsDbAsset: jsonEncode({
        'version': '1.0',
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
            ],
          },
          '介绍': {
            'head_hanzi': '介绍',
            'head_pinyin': 'jièshào',
            'head_vi': 'giới thiệu',
            'head_level': 2,
            'head_pos': 'v',
            'collocations': [
              {
                'object_hanzi': '朋友',
                'object_pinyin': 'péngyou',
                'object_vi': 'bạn bè',
                'object_level': 2,
                'frequency': 2,
                'sources': ['test'],
                'scenario': 'social',
              },
            ],
          },
        },
        'adj_noun': {},
        'measure_noun': {},
      }),
      LearningAssetRepository.framesBankAsset: jsonEncode({
        'version': '1.0',
        'frames': [
          {
            'id': 'F-H2-test-1',
            'zh': '我{VO}。',
            'vi': 'Tôi {VVO}.',
            'slot_types': ['VO'],
            'time': 'habitual',
            'mood': 'statement',
            'grammar_focus': 'basic_SVO',
            'hsk_level_min': 2,
            'complexity': 1,
          },
        ],
      }),
    });
    final factory = HskLearningSessionFactory(
      repository: LearningAssetRepository(bundle: bundle),
    );

    final session = await factory.createHsk2Session(quizLimit: 4);

    expect(session.activeLevel, 2);
    expect(session.collocations.length, 2);
    expect(session.quizzes, isNotEmpty);
    expect(
      session.quizzes.every((quiz) => quiz.choices.contains(quiz.answer)),
      isTrue,
    );
  });
}
