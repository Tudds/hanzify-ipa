import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/data/dialogue_scene_repository.dart';
import 'package:hanzify/core/learning/domain/dialogue_scene.dart';

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
  test('loadScenes parses scenes, speakers, lines from JSON', () async {
    final bundle = _MemoryAssetBundle({
      DialogueSceneRepository.conversationAsset: jsonEncode([
        {
          'id': 'conv_test_01',
          'title': 'Chào hỏi',
          'titleZh': '你好',
          'titlePinyin': 'Nǐ hǎo',
          'description': 'Lần đầu gặp.',
          'level': 1,
          'category': 'greeting',
          'icon': '👋',
          'lines': [
            {'speaker': 'A', 'zh': '你好！', 'pinyin': 'Nǐ hǎo!', 'vi': 'Chào!'},
            {
              'speaker': 'B',
              'zh': '我是明。',
              'pinyin': 'Wǒ shì Míng.',
              'vi': 'Tôi là Minh.',
            },
          ],
          'speakers': [
            {
              'code': 'A',
              'nameVi': 'Phương',
              'role': 'Người Việt Nam',
              'avatarColor': '#6C63FF',
            },
            {
              'code': 'B',
              'nameVi': 'Minh',
              'role': 'Người Trung Quốc',
              'avatarColor': '#FF6B6B',
            },
          ],
          'cultureTip': 'Người Trung Quốc thường hỏi quốc tịch khi gặp.',
          'relatedGrammar': ['g_shi'],
        },
      ]),
    });

    final repo = DialogueSceneRepository(bundle: bundle);
    final scenes = await repo.loadScenes();

    expect(scenes.keys, ['conv_test_01']);
    final scene = scenes['conv_test_01']!;
    expect(scene.titleZh, '你好');
    expect(scene.icon, '👋');
    expect(scene.cultureTip, isNotNull);
    expect(scene.speakers, hasLength(2));
    expect(scene.speakers.first.nameVi, 'Phương');
    expect(scene.speakers.first.avatarColor, const Color(0xFF6C63FF));
    expect(scene.speakers.last.avatarColor, const Color(0xFFFF6B6B));
    expect(scene.lines, hasLength(2));
    expect(scene.lines[0].index, 0);
    expect(scene.lines[1].index, 1);
    expect(scene.lines[1].speakerCode, 'B');
    expect(scene.relatedGrammar, ['g_shi']);
  });

  test('loadScenes is cached on second call', () async {
    var loadCalls = 0;
    final bundle = _CountingBundle(
      assets: {DialogueSceneRepository.conversationAsset: '[]'},
      onLoad: () => loadCalls += 1,
    );
    final repo = DialogueSceneRepository(bundle: bundle);

    await repo.loadScenes();
    await repo.loadScenes();

    expect(loadCalls, 1);
  });

  test('parseHexColor handles #RRGGBB and invalid input', () {
    expect(parseHexColor('#6C63FF'), const Color(0xFF6C63FF));
    expect(parseHexColor('6C63FF'), const Color(0xFF6C63FF));
    expect(parseHexColor('#FF6C63FF'), const Color(0xFF6C63FF));
    expect(parseHexColor(null), isNull);
    expect(parseHexColor(''), isNull);
    expect(parseHexColor('not-a-color'), isNull);
    expect(parseHexColor('#XYZ'), isNull);
  });

  test('DialogueSpeaker.fallback gives default name and null color', () {
    final fallback = DialogueSpeaker.fallback('B');
    expect(fallback.code, 'B');
    expect(fallback.nameVi, 'Người B');
    expect(fallback.avatarColor, isNull);
    expect(fallback.initial, 'N');
  });

  test('scene with missing speakers returns fallback via speakerOf', () {
    final scene = DialogueScene.fromJson({
      'id': 'conv_no_speakers',
      'lines': [
        {'speaker': 'A', 'zh': 'x', 'pinyin': 'x', 'vi': 'x'},
      ],
    });
    final speaker = scene.speakerOf('A');
    expect(speaker.nameVi, 'Người A');
    expect(speaker.avatarColor, isNull);
  });
}

class _CountingBundle extends CachingAssetBundle {
  _CountingBundle({required this.assets, required this.onLoad});

  final Map<String, String> assets;
  final VoidCallback onLoad;

  @override
  Future<ByteData> load(String key) async {
    onLoad();
    final value = assets[key];
    if (value == null) {
      throw Exception('missing asset $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}
