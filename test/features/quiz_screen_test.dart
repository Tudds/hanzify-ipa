import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/features/dictionary/data/library_repository.dart';
import 'package:hanzify/features/quiz/presentation/drills/flashcard_drill_screen.dart';
import 'package:hanzify/features/quiz/presentation/drills/multiple_choice_drill_screen.dart';
import 'package:hanzify/features/quiz/presentation/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      libraryRepositoryProvider.overrideWithValue(
        LibraryRepository(bundle: _FakeAssetBundle(_assets)),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('quiz launcher renders five modes', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(_wrap(const QuizScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Chọn từ'), findsOneWidget);
    expect(find.text('Flashcard'), findsOneWidget);
    expect(find.text('Điền từ'), findsOneWidget);
    expect(find.text('Nối từ'), findsOneWidget);
    expect(find.text('Sắp xếp'), findsOneWidget);
  });

  testWidgets('multiple choice scores answers and shows summary', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(_wrap(const MultipleChoiceDrillScreen(level: 2)));
    await tester.pumpAndSettle();

    for (var i = 0; i < _answers.length; i++) {
      final prompt = _answers.keys.firstWhere(
        (hanzi) => find.text(hanzi).evaluate().isNotEmpty,
      );
      final answer = _answers[prompt]!;
      await tester.tap(find.widgetWithText(FilledButton, answer));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(i == _answers.length - 1 ? 'Hoàn thành' : 'Tiếp theo'),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('Xuất sắc!'), findsOneWidget);
    expect(find.text('Đúng 4 trên 4 câu'), findsOneWidget);
  });

  testWidgets('multiple choice shows empty data state', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(_wrap(const MultipleChoiceDrillScreen(level: 4)));
    await tester.pumpAndSettle();

    expect(find.text('Không đủ dữ liệu để luyện.'), findsOneWidget);
  });

  testWidgets('flashcard flip reveals the back face', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(_wrap(const FlashcardDrillScreen(level: 2)));
    // The front face hint animates with `.repeat()`, so pumpAndSettle would
    // never settle — advance time with fixed pumps instead.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // The front shows a hanzi; the pinyin is rendered only on the back face.
    const pinyinByHanzi = {
      '学习': 'xuéxí',
      '中文': 'Zhōngwén',
      '老师': 'lǎoshī',
      '喝': 'hē',
    };
    final frontHanzi = pinyinByHanzi.keys.firstWhere(
      (hanzi) => find.text(hanzi).evaluate().isNotEmpty,
    );
    final pinyin = pinyinByHanzi[frontHanzi]!;
    expect(find.text(pinyin), findsNothing);

    // Tap the card to flip; the back face must actually be in the tree (the
    // 3D transform previously hid it, leaving a blank card after flipping).
    await tester.tap(find.text(frontHanzi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(pinyin), findsOneWidget);
    expect(find.text('Nhớ rõ'), findsOneWidget);
  });
}

const _answers = {
  '学习': 'học',
  '中文': 'tiếng Trung',
  '老师': 'giáo viên',
  '喝': 'uống',
};

final _assets = {
  'assets/data/hsk2.json': jsonEncode([
    _vocab('hsk2_学习', '学习', 'xuéxí', 'xuexi', 'học', '我学习中文。'),
    _vocab('hsk2_中文', '中文', 'Zhōngwén', 'zhongwen', 'tiếng Trung', '我学习中文。'),
    _vocab('hsk2_老师', '老师', 'lǎoshī', 'laoshi', 'giáo viên', '老师很好。'),
    _vocab('hsk2_喝', '喝', 'hē', 'he', 'uống', '我喝水。'),
  ]),
};

Map<String, Object?> _vocab(
  String id,
  String hanzi,
  String pinyin,
  String normalized,
  String vi,
  String example,
) {
  return {
    'id': id,
    'hanzi': hanzi,
    'pinyin': pinyin,
    'pinyinNormalized': normalized,
    'characters': [hanzi],
    'meanings': [
      {'pos': 'verb', 'vi': vi, 'en': vi},
    ],
    'exampleSentences': [
      {'cn': example, 'pinyin': '', 'vi': vi},
    ],
    'level': 2,
    'wordType': 'verb',
    'tags': ['test'],
    'frequency': '',
  };
}

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
