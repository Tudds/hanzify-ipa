import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/features/chat/application/gen_ui_chat_responder.dart';
import 'package:hanzify/features/chat/domain/gen_ui_chat.dart';
import 'package:hanzify/features/chat/presentation/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
}
