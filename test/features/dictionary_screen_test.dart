import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/features/dictionary/data/library_repository.dart';
import 'package:hanzify/features/dictionary/presentation/dictionary_screen.dart';
import 'package:hanzify/features/dictionary/presentation/widgets/grammar_detail_sheet.dart';
import 'package:hanzify/features/dictionary/presentation/widgets/vocab_detail_sheet.dart';

import '../support/profile_overrides.dart';

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: [
      ...overrides,
      libraryRepositoryProvider.overrideWithValue(
        LibraryRepository(bundle: _FakeAssetBundle(_assets)),
      ),
    ],
    child: const MaterialApp(home: Scaffold(body: DictionaryScreen())),
  );
}

void main() {
  testWidgets('dictionary defaults to profile level and filters vocab', (
    tester,
  ) async {
    // Profile mặc định activeLevel = 2 → mở từ điển là thấy filter HSK 2.
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(overrides));
    await tester.pumpAndSettle();

    expect(find.text('学习'), findsOneWidget);
    expect(find.text('奶茶'), findsNothing);

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();

    expect(find.text('奶茶'), findsOneWidget);
    expect(find.text('学习'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'naicha');
    await tester.pumpAndSettle();

    expect(find.text('奶茶'), findsOneWidget);
    expect(find.text('学习'), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HSK 2'));
    await tester.pumpAndSettle();

    expect(find.text('奶茶'), findsNothing);
    expect(find.text('学习'), findsOneWidget);
  });

  testWidgets('dictionary opens vocab and grammar detail sheets', (
    tester,
  ) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('奶茶'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(VocabDetailSheet), findsOneWidget);
    expect(find.text('nǎichá'), findsWidgets);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ngữ pháp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Câu chủ-vị SVO'));
    await tester.pumpAndSettle();

    expect(find.byType(GrammarDetailSheet), findsOneWidget);
    expect(find.text('Cách dùng'), findsOneWidget);
  });
}

final _assets = {
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
  'assets/data/hsk2.json': jsonEncode([
    {
      'id': 'hsk2_学习',
      'hanzi': '学习',
      'pinyin': 'xuéxí',
      'pinyinNormalized': 'xuexi',
      'characters': ['学', '习'],
      'meanings': [
        {'pos': 'verb', 'vi': 'học', 'en': 'study'},
      ],
      'exampleSentences': [
        {
          'cn': '我学习中文。',
          'pinyin': 'Wǒ xuéxí Zhōngwén.',
          'vi': 'Tôi học tiếng Trung.',
        },
      ],
      'level': 2,
      'wordType': 'verb',
      'tags': ['study'],
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
