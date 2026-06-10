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
      LearningAssetRepository.collocationPoolAsset: jsonEncode([
        _collocation(
          id: 'col_study',
          textCn: '我学习中文。',
          pinyin: 'Wǒ xuéxí Zhōngwén.',
          textVi: 'Tôi học tiếng Trung.',
          targetVocabId: 'hsk2_学习',
        ),
        _collocation(
          id: 'col_intro',
          textCn: '我介绍朋友。',
          pinyin: 'Wǒ jièshào péngyou.',
          textVi: 'Tôi giới thiệu bạn bè.',
          targetVocabId: 'hsk2_介绍',
        ),
      ]),
      LearningAssetRepository.conversationAsset: jsonEncode([]),
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

  test('HSK2 lesson uses curated conversation lines with line audio', () async {
    final bundle = _MemoryAssetBundle({
      LearningAssetRepository.collocationPoolAsset: jsonEncode([
        for (var index = 0; index < 4; index++)
          {
            'id': 'col_$index',
            'level': 2,
            'source': 'conversation_line',
            'textCn': 'line $index',
            'pinyin': 'pinyin $index',
            'textVi': 'nghĩa $index',
            'targetVocabIds': ['hsk2_target_$index'],
            'targetGrammarIds': ['g_you'],
            'conversationIds': ['conv_shopping_02'],
            'tags': ['shopping'],
            'difficulty': 2,
          },
      ]),
      LearningAssetRepository.conversationAsset: jsonEncode([
        {
          'id': 'conv_shopping_02',
          'lines': [
            for (var index = 0; index < 4; index++) {'zh': 'line $index'},
          ],
        },
      ]),
    });
    final factory = HskLearningSessionFactory(
      repository: LearningAssetRepository(bundle: bundle),
    );

    final session = await factory.createHsk2Session(quizLimit: 4);

    expect(session.collocations.map((item) => item.source).toSet(), {
      'conversation_line',
    });
    expect(session.quizzes.first.prompt, 'line 0');
    expect(
      session.quizzes.first.audioUrl,
      endsWith('/conv/conv_shopping_02_L0.mp3'),
    );
  });
}

Map<String, Object?> _collocation({
  required String id,
  required String textCn,
  required String pinyin,
  required String textVi,
  required String targetVocabId,
  List<String> targetGrammarIds = const ['basic_SVO'],
}) {
  return {
    'id': id,
    'level': 2,
    'source': 'test',
    'textCn': textCn,
    'pinyin': pinyin,
    'textVi': textVi,
    'targetVocabIds': [targetVocabId],
    'targetGrammarIds': targetGrammarIds,
    'conversationIds': [],
    'tags': ['test'],
    'difficulty': 2,
  };
}
