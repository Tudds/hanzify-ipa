import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/features/chat/application/gen_ui_chat_responder.dart';
import 'package:hanzify/features/chat/domain/dictation.dart';
import 'package:hanzify/features/chat/domain/gen_ui_chat.dart';
import 'package:hanzify/features/chat/presentation/chat_screen.dart';
import 'package:hanzify/features/chat/presentation/widgets/dictation_block_view.dart';

import '../support/profile_overrides.dart';

class _FakeDictationResponder implements GenUiChatResponder {
  @override
  Future<List<GenUiBlock>> respond(String prompt) async {
    return const [
      ChatBubbleBlock('Nghe audio rồi gõ lại câu bằng chữ Hán nhé.'),
      DictationBlock(
        DictationExercise(
          id: 'col_audio',
          mode: DictationMode.listen,
          textCn: '我喝茶。',
          pinyin: 'Wǒ hē chá.',
          textVi: 'Tôi uống trà.',
          level: 2,
          audioUrl: 'https://example.com/audio.mp3',
        ),
      ),
    ];
  }
}

class _FakeResponder implements GenUiChatResponder {
  @override
  Future<List<GenUiBlock>> respond(String prompt) async {
    return const [
      ChatBubbleBlock('Đây là phản hồi GenUI.'),
      VocabCardBlock(
        id: 'hsk1_学习',
        hanzi: '学习',
        pinyin: 'xuexi',
        vi: 'học',
        level: 1,
      ),
      GrammarCardBlock(
        id: 'g_le',
        title: 'Trợ từ 了',
        structure: 'V + 了',
        explanation: 'Dùng để nói hành động đã hoàn thành.',
        level: 2,
      ),
      QuickQuizBlock(
        prompt: '学习 nghĩa là gì?',
        choices: ['học', 'ăn', 'uống'],
        answer: 'học',
        explanation: '学习 là học.',
      ),
      SentenceArrangeBlock(
        translation: 'Tôi học tiếng Trung.',
        tokens: ['中', '文', '学', '习'],
        answer: '学习中文',
      ),
      SuggestionActionsBlock([
        GenUiSuggestionAction(label: 'Tạo quiz', prompt: 'Tạo quiz HSK 1'),
      ]),
    ];
  }
}

void main() {
  testWidgets('chat sends prompt and renders GenUI blocks', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          genUiChatResponderProvider.overrideWithValue(_FakeResponder()),
        ],
        child: const MaterialApp(home: Scaffold(body: ChatScreen())),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Tra từ 学习');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Đây là phản hồi GenUI.'), findsOneWidget);
    expect(find.text('学习'), findsWidgets);
    expect(find.text('Trợ từ 了'), findsOneWidget);
    expect(find.text('学习 nghĩa là gì?'), findsOneWidget);
    expect(find.text('Sắp xếp câu'), findsOneWidget);

    final answerButton = find.widgetWithText(OutlinedButton, 'học');
    await tester.ensureVisible(answerButton);
    await tester.pump();
    await tester.tap(answerButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('Đúng rồi'), findsOneWidget);
  });

  testWidgets('dictation block checks typed hanzi with diff feedback', (
    tester,
  ) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          genUiChatResponderProvider.overrideWithValue(
            _FakeDictationResponder(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ChatScreen())),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Luyện nghe chép chính tả');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Nghe viết Hán tự'), findsOneWidget);
    expect(find.text('Kiểm tra'), findsOneWidget);
    expect(find.text('Gợi ý pinyin'), findsOneWidget);
    expect(find.text('Hiện đáp án'), findsOneWidget);

    final dictationField = find.descendant(
      of: find.byType(DictationBlockView),
      matching: find.byType(TextField),
    );

    // Trả lời sai → hiện đối chiếu diff, vẫn sửa được.
    await tester.enterText(dictationField, '我喝水');
    await tester.tap(find.text('Kiểm tra'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa đúng, đối chiếu từng chữ:'), findsOneWidget);

    // Gợi ý pinyin.
    await tester.tap(find.text('Gợi ý pinyin'));
    await tester.pumpAndSettle();
    expect(find.text('Wǒ hē chá.'), findsOneWidget);

    // Sửa thành đúng (dấu câu/khoảng trắng được bỏ qua khi chấm).
    await tester.enterText(dictationField, ' 我喝茶 。');
    await tester.tap(find.text('Kiểm tra'));
    await tester.pumpAndSettle();
    expect(find.text('Chính xác!'), findsOneWidget);
    expect(find.text('Tôi uống trà.'), findsOneWidget);
  });
}
