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
  test('HSK session filters collocations by lesson grammar context', () async {
    final bundle = _MemoryAssetBundle({
      LearningAssetRepository.collocationPoolAsset: jsonEncode([
        for (final verb in ['学习', '介绍', '练习', '准备'])
          _collocation(
            id: 'col_$verb',
            textCn: '我$verb中文。',
            textVi: 'Tôi $verb tiếng Trung.',
            targetVocabId: 'hsk2_$verb',
          ),
      ]),
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
  });
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
    'targetGrammarIds': ['basic_SVO'],
    'conversationIds': [],
    'tags': ['test'],
    'difficulty': 2,
  };
}
