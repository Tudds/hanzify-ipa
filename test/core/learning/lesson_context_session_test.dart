import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/learning_asset_repository.dart';
import 'package:hanzify/core/learning/lesson_context.dart';

class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) throw Exception('missing asset $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  test(
    'HSK session filters generated collocations by lesson grammar context',
    () async {
      final bundle = _MemoryAssetBundle({
        LearningAssetRepository.collocationsDbAsset: jsonEncode({
          'version': '1.0',
          'verb_object': {
            for (final verb in ['学习', '介绍', '练习', '准备'])
              verb: {
                'head_hanzi': verb,
                'head_pinyin': 'pinyin',
                'head_vi': 'làm',
                'head_level': 2,
                'head_pos': 'v',
                'collocations': [
                  {
                    'object_hanzi': '中文',
                    'object_pinyin': 'Zhōngwén',
                    'object_vi': 'tiếng Trung',
                    'object_level': 2,
                    'frequency': 1,
                    'sources': ['test'],
                    'scenario': 'study',
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
        LearningAssetRepository.conversationAsset: jsonEncode([]),
      });
      final factory = HskLearningSessionFactory(
        repository: LearningAssetRepository(bundle: bundle),
      );

      final session = await factory.createHsk2Session(
        lessonContext: const LessonContext(
          stageId: 'HSK2',
          moduleId: 'H2-M1',
          lessonUnitId: 'H2-M1-L1',
          level: 2,
          conversationIds: ['conv_target'],
          grammarIds: ['basic_SVO'],
        ),
      );

      expect(session.collocations.length, 4);
      expect(
        session.collocations.every(
          (item) => item.targetGrammarIds.contains('basic_SVO'),
        ),
        isTrue,
      );
    },
  );
}
