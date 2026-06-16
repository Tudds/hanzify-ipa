import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hanzify/features/shorts/data/remote_shorts_repository.dart';
import 'package:hanzify/features/shorts/data/shorts_feed_repository.dart';
import 'package:hanzify/features/shorts/domain/short_feed_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteShortsRepository', () {
    test('parses manifest with {items:[...]} wrapper into typed payloads', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(utf8.encode(jsonEncode(_manifest)), 200);
      });
      final repo = RemoteShortsRepository(
        client: client,
        manifestUrl: 'https://example.com/shorts/manifest.json',
      );

      final items = await repo.fetchRemote();

      expect(items.length, 3);
      final dialogue =
          items.firstWhere((i) => i.type == ShortCardType.dialogue).payload
              as ShortDialogue;
      expect(dialogue.hasSyncedSubtitles, isTrue);
      expect(dialogue.lines.first.startMs, 0);
      expect(dialogue.lines.first.endMs, 1900);

      final scene =
          items.firstWhere((i) => i.type == ShortCardType.scene).payload
              as ShortScene;
      expect(scene.captionHanzi, '这是市场。');
      expect(scene.labels.first.targetVocabId, 'hsk1_苹果');

      final reader =
          items.firstWhere((i) => i.type == ShortCardType.reader).payload
              as ShortReader;
      expect(reader.kind, ShortReaderKind.poem);
      expect(reader.paragraphs.length, 2);
      expect(reader.hasSyncedSubtitles, isTrue);
    });

    test('parses bare-list manifest form', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(utf8.encode(jsonEncode(_manifest['items'])), 200);
      });
      final repo = RemoteShortsRepository(
        client: client,
        manifestUrl: 'https://example.com/m.json',
      );

      final items = await repo.fetchRemote();
      expect(items.length, 3);
    });

    test('returns empty on non-200', () async {
      final repo = RemoteShortsRepository(
        client: MockClient((_) async => http.Response('nope', 503)),
        manifestUrl: 'https://example.com/m.json',
      );
      expect(await repo.fetchRemote(), isEmpty);
    });

    test('returns empty (does not throw) on network error', () async {
      final repo = RemoteShortsRepository(
        client: MockClient((_) async => throw Exception('offline')),
        manifestUrl: 'https://example.com/m.json',
      );
      expect(await repo.fetchRemote(), isEmpty);
    });

    test('skips malformed entries, keeps valid ones', () async {
      final client = MockClient((_) async {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'items': [
                {'broken': true},
                _manifest['items']![1],
              ],
            }),
          ),
          200,
        );
      });
      final repo = RemoteShortsRepository(
        client: client,
        manifestUrl: 'https://example.com/m.json',
      );
      final items = await repo.fetchRemote();
      expect(items.length, 1);
      expect(items.single.type, ShortCardType.scene);
    });
  });

  group('ShortsFeedRepository remote merge', () {
    test('merges remote items only when includeRemote is true', () async {
      final bundle = _FakeBundle({
        ShortsFeedRepository.curatedHsk1Asset: jsonEncode(const []),
      });
      final remote = RemoteShortsRepository(
        client: MockClient((_) async => http.Response.bytes(utf8.encode(jsonEncode(_manifest)), 200)),
        manifestUrl: 'https://example.com/m.json',
      );
      final repo = ShortsFeedRepository(bundle: bundle, remoteShorts: remote);

      final withoutRemote = await repo.loadHskFeed(
        levels: const [1, 2],
        options: const ShortsFeedLoadOptions(
          staticItemsPerLevel: 0,
          vocabItemsPerLevel: 0,
          grammarItemsPerLevel: 0,
          includeRemediation: false,
        ),
      );
      expect(
        withoutRemote.items.any((i) => i.type == ShortCardType.scene),
        isFalse,
      );

      final withRemote = await repo.loadHskFeed(
        levels: const [1, 2],
        options: const ShortsFeedLoadOptions(
          staticItemsPerLevel: 0,
          vocabItemsPerLevel: 0,
          grammarItemsPerLevel: 0,
          includeRemediation: false,
          includeRemote: true,
        ),
      );
      expect(
        withRemote.items.any((i) => i.type == ShortCardType.scene),
        isTrue,
      );
      expect(
        withRemote.items.any((i) => i.type == ShortCardType.reader),
        isTrue,
      );
    });

    test('filters remote items outside requested levels', () async {
      final bundle = _FakeBundle({
        ShortsFeedRepository.curatedHsk1Asset: jsonEncode(const []),
      });
      final remote = RemoteShortsRepository(
        client: MockClient((_) async => http.Response.bytes(utf8.encode(jsonEncode(_manifest)), 200)),
        manifestUrl: 'https://example.com/m.json',
      );
      final repo = ShortsFeedRepository(bundle: bundle, remoteShorts: remote);

      final seed = await repo.loadHskFeed(
        levels: const [1],
        options: const ShortsFeedLoadOptions(
          staticItemsPerLevel: 0,
          vocabItemsPerLevel: 0,
          grammarItemsPerLevel: 0,
          includeRemediation: false,
          includeRemote: true,
        ),
      );
      // Level-1 scene kept; level-2 dialogue & reader dropped.
      expect(seed.items.any((i) => i.type == ShortCardType.scene), isTrue);
      expect(seed.items.any((i) => i.type == ShortCardType.dialogue), isFalse);
      expect(seed.items.any((i) => i.type == ShortCardType.reader), isFalse);
    });
  });
}

final Map<String, List<Map<String, dynamic>>> _manifest = {
  'items': [
    {
      'id': 'rich_dialogue_cafe',
      'type': 'dialogue',
      'level': 2,
      'payload': {
        'title': 'Ở quán cà phê',
        'context': 'Một đoạn thoại ngắn.',
        'audioUrl': 'https://cdn/shorts/audio/cafe.mp3',
        'lines': [
          {
            'speaker': 'A',
            'hanzi': '你要喝什么？',
            'pinyin': 'nǐ yào hē shénme',
            'vi': 'Bạn muốn uống gì?',
            'startMs': 0,
            'endMs': 1900,
          },
          {
            'speaker': 'B',
            'hanzi': '我要一杯咖啡。',
            'pinyin': 'wǒ yào yì bēi kāfēi',
            'vi': 'Tôi muốn một ly cà phê.',
            'startMs': 1900,
            'endMs': 4200,
          },
        ],
      },
    },
    {
      'id': 'rich_scene_market',
      'type': 'scene',
      'level': 1,
      'payload': {
        'imageUrl': 'https://cdn/shorts/images/market.webp',
        'caption': {
          'hanzi': '这是市场。',
          'pinyin': 'zhè shì shìchǎng',
          'vi': 'Đây là cái chợ.',
        },
        'labels': [
          {'hanzi': '苹果', 'pinyin': 'píngguǒ', 'vi': 'táo', 'targetVocabId': 'hsk1_苹果'},
        ],
      },
    },
    {
      'id': 'rich_reader_poem',
      'type': 'reader',
      'level': 2,
      'payload': {
        'kind': 'poem',
        'titleZh': '静夜思',
        'title': 'Tĩnh dạ tứ',
        'audioUrl': 'https://cdn/shorts/audio/poem.mp3',
        'paragraphs': [
          {'zh': '床前明月光，', 'pinyin': 'chuáng qián míng yuè guāng', 'vi': 'Đầu giường ánh trăng sáng,', 'startMs': 0, 'endMs': 2600},
          {'zh': '疑是地上霜。', 'pinyin': 'yí shì dì shàng shuāng', 'vi': 'Ngỡ là sương trên mặt đất.', 'startMs': 2600, 'endMs': 5200},
        ],
        'glossary': [
          {'hanzi': '明月', 'pinyin': 'míngyuè', 'vi': 'trăng sáng'},
        ],
        'sourceName': 'Lý Bạch',
      },
    },
  ],
};

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._values);

  final Map<String, String> _values;

  @override
  Future<ByteData> load(String key) async {
    final value = _values[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}
