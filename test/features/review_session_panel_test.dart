import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/features/review_session/domain/review_challenge.dart';
import 'package:hanzify/features/review_session/presentation/review_session_panel.dart';

const _challenge = ReviewChallenge(
  prompt: '我喜欢茶。',
  answer: 'Tôi thích trà.',
  choices: ['Tôi thích trà.', 'Tôi mua trà.'],
  promptPinyin: 'Wǒ xǐhuān chá.',
  promptMeaning: 'Tôi thích trà.',
  quizType: 'vocabRecognition',
);

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('counts down from configured duration', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ReviewSessionPanel(
          challenge: _challenge,
          duration: Duration(seconds: 30),
        ),
      ),
    );

    expect(find.text('30s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('29s'), findsOneWidget);
  });

  testWidgets('correct choice shows explanation before callback', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      _wrap(
        ReviewSessionPanel(
          challenge: _challenge,
          onChoice: (choice) => selected = choice,
        ),
      ),
    );

    await tester.tap(find.text('Tôi thích trà.'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.text('Chính xác'), findsOneWidget);
    expect(find.text('Wǒ xǐhuān chá.'), findsWidgets);
    expect(find.text('Bạn chọn'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(selected, 'Tôi thích trà.');
  });

  testWidgets('wrong choice shows the correct answer', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _wrap(
        ReviewSessionPanel(
          challenge: _challenge,
          onChoice: (choice) => selected = choice,
        ),
      ),
    );

    await tester.tap(find.text('Tôi mua trà.'));
    await tester.pumpAndSettle();

    expect(find.text('Chưa đúng'), findsOneWidget);
    expect(find.text('Đáp án đúng'), findsOneWidget);
    expect(find.text('Tôi thích trà.'), findsWidgets);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(selected, 'Tôi mua trà.');
  });

  testWidgets('timeout opens feedback and calls timeout after continue', (
    tester,
  ) async {
    var timedOut = false;
    await tester.pumpWidget(
      _wrap(
        ReviewSessionPanel(
          challenge: _challenge,
          duration: const Duration(seconds: 1),
          onTimeout: () => timedOut = true,
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(timedOut, isFalse);
    expect(find.text('Hết giờ'), findsOneWidget);
    expect(find.text('Chưa chọn đáp án'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(timedOut, isTrue);
  });
}
