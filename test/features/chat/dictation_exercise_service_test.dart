import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/learning_asset_repository.dart';
import 'package:hanzify/features/chat/application/dictation_exercise_service.dart';
import 'package:hanzify/features/chat/domain/dictation.dart';
import 'package:hanzify/features/dictionary/data/library_repository.dart';

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

Map<String, Object?> _collocation({
  required String id,
  required String textCn,
  String textVi = '',
  String source = 'generated',
  List<String> conversationIds = const [],
}) {
  return {
    'id': id,
    'level': 2,
    'source': source,
    'textCn': textCn,
    'pinyin': 'pinyin',
    'textVi': textVi,
    'targetVocabIds': const <String>[],
    'targetGrammarIds': const <String>[],
    'conversationIds': conversationIds,
    'tags': const <String>[],
    'difficulty': 2.0,
  };
}

DictationExerciseService _service(Map<String, String> assets) {
  final bundle = _MemoryAssetBundle(assets);
  return DictationExerciseService(
    assetRepository: LearningAssetRepository(bundle: bundle),
    libraryRepository: LibraryRepository(bundle: bundle),
  );
}

void main() {
  final poolAssets = {
    'assets/data/generated/collocation_pool_hsk2.json': jsonEncode([
      // Câu hội thoại khớp conversation.json -> được gắn audio.
      _collocation(
        id: 'col_audio',
        textCn: '你好吗？',
        textVi: 'Bạn khỏe không?',
        source: 'conversation_line',
        conversationIds: ['conv_greeting_01'],
      ),
      // Câu generated không có audio.
      _collocation(
        id: 'col_no_audio',
        textCn: '我学习中文。',
        textVi: 'Tôi học tiếng Trung.',
      ),
      // Câu quá dài (>16 chữ) phải bị loại.
      _collocation(
        id: 'col_too_long',
        textCn: '这是一个非常非常非常非常非常长的句子啊',
        textVi: 'Câu rất dài.',
        source: 'conversation_line',
        conversationIds: ['conv_greeting_01'],
      ),
    ]),
    LearningAssetRepository.conversationAsset: jsonEncode([
      {
        'id': 'conv_greeting_01',
        'lines': [
          {'zh': '你好吗？'},
        ],
      },
    ]),
  };

  test('listen mode only yields sentences with real audio', () async {
    final service = _service(poolAssets);
    for (var i = 0; i < 5; i++) {
      final exercise = await service.nextExercise(
        mode: DictationMode.listen,
        level: 2,
        rng: Random(i),
      );
      expect(exercise, isNotNull);
      expect(exercise!.id, 'col_audio');
      expect(exercise.audioUrl, contains('conv_greeting_01_L0'));
    }
  });

  test('readVi mode requires Vietnamese text but not audio', () async {
    final service = _service(poolAssets);
    final seen = <String>{};
    for (var i = 0; i < 20; i++) {
      final exercise = await service.nextExercise(
        mode: DictationMode.readVi,
        level: 2,
        rng: Random(i),
      );
      seen.add(exercise!.id);
      expect(exercise.textVi, isNotEmpty);
      expect(exercise.textCn.runes.length, lessThanOrEqualTo(16));
    }
    expect(seen, containsAll({'col_audio', 'col_no_audio'}));
    expect(seen, isNot(contains('col_too_long')));
  });

  test('falls back to vocab examples when pool has no candidates', () async {
    final service = _service({
      // Pool level 1 trống (qua file combined fallback của repository).
      LearningAssetRepository.collocationPoolAsset: jsonEncode([]),
      LearningAssetRepository.conversationAsset: jsonEncode([]),
      'assets/data/hsk1.json': jsonEncode([
        {
          'id': 'hsk1_茶',
          'hanzi': '茶',
          'pinyin': 'chá',
          'pinyinNormalized': 'cha',
          'level': 1,
          'meanings': [
            {'pos': 'n', 'vi': 'trà'},
          ],
          'exampleSentences': [
            {'cn': '我喝茶。', 'pinyin': 'Wǒ hē chá.', 'vi': 'Tôi uống trà.'},
          ],
        },
      ]),
    });

    final exercise = await service.nextExercise(
      mode: DictationMode.listen,
      level: 1,
      rng: Random(1),
    );
    expect(exercise, isNotNull);
    expect(exercise!.textCn, '我喝茶。');
    expect(exercise.audioUrl, contains('hsk1_茶_E0'));
  });

  test('returns null when nothing fits', () async {
    final service = _service({
      LearningAssetRepository.collocationPoolAsset: jsonEncode([]),
      LearningAssetRepository.conversationAsset: jsonEncode([]),
      'assets/data/hsk1.json': jsonEncode([]),
    });

    final exercise = await service.nextExercise(
      mode: DictationMode.listen,
      level: 1,
    );
    expect(exercise, isNull);
  });
}
