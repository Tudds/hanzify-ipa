import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';

/// Disable runtime font fetching to prevent network calls in tests.
void disableGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

ThemeData testTheme({AppThemeColors? colors}) {
  return ThemeData(
    useMaterial3: true,
    extensions: [AppThemeExtension(colors: colors ?? AppThemeColors.light)],
  );
}

/// Wrap [child] in ProviderScope + MaterialApp + light theme.
Widget buildTestApp(Widget child, {AppThemeColors? themeColors}) {
  return ProviderScope(
    child: MaterialApp(
      theme: testTheme(colors: themeColors),
      home: Scaffold(body: child),
    ),
  );
}

/// Wrap [scope] (a ProviderScope containing the widget) in MaterialApp.
/// Use this when you need provider overrides.
///
/// ```dart
/// buildTestAppWithScope(
///   ProviderScope(
///     overrides: [quizProvider.overrideWithValue(state)],
///     child: const QuizQuestionView(),
///   ),
/// )
/// ```
Widget buildTestAppWithScope(ProviderScope scope, {AppThemeColors? themeColors}) {
  return MaterialApp(
    theme: testTheme(colors: themeColors),
    home: Scaffold(body: scope),
  );
}

Vocab makeVocab({
  String id = '1',
  String hanzi = '你好',
  String pinyin = 'nǐ hǎo',
  int level = 1,
  List<Meaning>? meanings,
  List<ExampleSentence>? examples,
  bool isMastered = false,
  int repetitions = 0,
  int interval = 0,
}) {
  return Vocab(
    id: id,
    hanzi: hanzi,
    pinyin: pinyin,
    meanings: meanings ?? [const Meaning(pos: 'v', vi: 'xin chào', en: 'hello')],
    exampleSentences: examples ?? [],
    level: level,
    nextReview: DateTime(2026, 1, 1),
    updatedAt: DateTime.now(),
    isMastered: isMastered,
    repetitions: repetitions,
    interval: interval,
  );
}

List<Vocab> makeVocabList({int count = 10}) {
  const hanzis = ['你好', '谢谢', '再见', '学习', '中文', '朋友', '吃饭', '看书', '工作', '生活'];
  const pinyins = ['nǐ hǎo', 'xiè xiè', 'zài jiàn', 'xué xí', 'zhōng wén', 'péng yǒu', 'chī fàn', 'kàn shū', 'gōng zuò', 'shēng huó'];
  const meanings = ['xin chào', 'cảm ơn', 'tạm biệt', 'học tập', 'tiếng Trung', 'bạn bè', 'ăn cơm', 'đọc sách', 'làm việc', 'cuộc sống'];

  return List.generate(
    count,
    (i) => makeVocab(
      id: 'vocab_$i',
      hanzi: hanzis[i % 10],
      pinyin: pinyins[i % 10],
      level: (i % 6) + 1,
      meanings: [Meaning(pos: 'v', vi: meanings[i % 10])],
    ),
  );
}
