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

import '../support/profile_overrides.dart';

Widget _wrap(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: [
      ...overrides,
      libraryRepositoryProvider.overrideWithValue(
        LibraryRepository(bundle: _FakeAssetBundle(_assets)),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('quiz launcher renders five modes', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(const QuizScreen(), overrides));
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
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      _wrap(const MultipleChoiceDrillScreen(level: 2), overrides),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < _answers.length; i++) {
      final prompt = _answers.keys.firstWhere(
        (hanzi) => find.text(hanzi).evaluate().isNotEmpty,
      );
      final answer = _answers[prompt]!;
      await tester.tap(find.widgetWithText(FilledButton, answer));
      await tester.pumpAndSettle();
      final isLast = i == _answers.length - 1;
      await tester.tap(find.text(isLast ? 'Hoàn thành' : 'Tiếp theo'));
      if (isLast) {
        // Màn summary bắn confetti; từ confetti 0.8 ticker chạy liên tục nên
        // pumpAndSettle không bao giờ settle — pump theo thời gian cố định.
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
      } else {
        await tester.pumpAndSettle();
      }
    }

    expect(find.text('Xuất sắc!'), findsOneWidget);
    expect(find.text('Đúng 4 trên 4 câu'), findsOneWidget);
  });

  testWidgets('multiple choice shows empty data state', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      _wrap(const MultipleChoiceDrillScreen(level: 4), overrides),
    );
    await tester.pumpAndSettle();

    expect(find.text('Không đủ dữ liệu để luyện.'), findsOneWidget);
  });

  testWidgets('flashcard flip reveals the back face', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      _wrap(const FlashcardDrillScreen(level: 2), overrides),
    );
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
    const meaningByHanzi = {
      '学习': 'học',
      '中文': 'tiếng Trung',
      '老师': 'giáo viên',
      '喝': 'uống',
    };
    const exampleByHanzi = {
      '学习': '我学习中文。',
      '中文': '我学习中文。',
      '老师': '老师很好。',
      '喝': '我喝水。',
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
    // 4 nút chấm FSRS xuất hiện sau khi lật.
    expect(find.text('Được'), findsOneWidget);
    expect(find.text('Quên'), findsOneWidget);
    // The back face shows the meaning grouped by part of speech + an example.
    expect(find.text(meaningByHanzi[frontHanzi]!), findsWidgets);
    expect(find.text(exampleByHanzi[frontHanzi]!), findsWidgets);
  });

  testWidgets('quiz level selection persists across rebuilds', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(_wrap(const QuizScreen(), overrides));
    await tester.pumpAndSettle();

    // Dropdown mặc định theo profile (activeLevel = 2). "HSK n" xuất hiện ở
    // nhiều card chế độ nên phải nhắm đúng dropdown.
    final dropdown = find.byType(DropdownButton<int>);
    DropdownButton<int> dropdownWidget() =>
        tester.widget<DropdownButton<int>>(dropdown);
    expect(dropdownWidget().value, 2);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('HSK 3').last);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('quiz_level'), 3);

    // Mount lại màn Quiz với cùng prefs → vẫn giữ HSK 3.
    await tester.pumpWidget(_wrap(const QuizScreen(), overrides));
    await tester.pumpAndSettle();
    expect(dropdownWidget().value, 3);
  });

  testWidgets('flashcard level chip switches level and syncs quiz level', (
    tester,
  ) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      _wrap(const FlashcardDrillScreen(level: 2), overrides),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Hint mặt trước flashcard lặp animation vô hạn nên không dùng
    // pumpAndSettle được — pump theo thời gian cố định.
    await tester.tap(find.text('HSK 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('HSK 1').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Fixture không có vocab HSK 1 → drill resample và báo thiếu dữ liệu,
    // chứng tỏ level đã đổi thật.
    expect(find.text('Chưa có từ vựng để luyện.'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('quiz_level'), 1);
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
