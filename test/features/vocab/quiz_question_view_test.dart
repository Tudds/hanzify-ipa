import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/quiz_state.dart';
import 'package:hanzify/features/vocab/presentation/screens/quiz/widgets/quiz_question_view.dart';
import 'package:hanzify/core/widgets/hanzify_quiz_option.dart';

import '../../test_helpers.dart';

// ── Fake notifier — preset state, full method inheritance ────────────────────

class _FakeQuizNotifier extends QuizNotifier {
  final QuizState _preset;
  _FakeQuizNotifier(this._preset);

  @override
  QuizState build() => _preset;
}

// ── Test data ────────────────────────────────────────────────────────────────

Vocab _vocab(String id, String hanzi, String pinyin, String meaning) => makeVocab(
      id: id,
      hanzi: hanzi,
      pinyin: pinyin,
      meanings: [Meaning(pos: 'v', vi: meaning)],
    );

QuizQuestion _makeQuestion({
  QuizMode mode = QuizMode.hanziToMeaning,
  int correctIndex = 0,
}) {
  final vocab = _vocab('q1', '你好', 'nǐ hǎo', 'xin chào');
  final options = mode == QuizMode.hanziToMeaning
      ? ['xin chào', 'cảm ơn', 'tạm biệt', 'yêu']
      : ['你好', '谢谢', '再见', '爱'];
  return QuizQuestion(
    vocab: vocab,
    options: options,
    correctIndex: correctIndex,
    mode: mode,
  );
}

QuizState _makeState({
  QuizMode mode = QuizMode.hanziToMeaning,
  int? selectedAnswer,
  bool? answerFeedback,
  int streak = 0,
  int currentIndex = 0,
  bool showPinyin = true,
}) {
  return QuizState(
    mode: mode,
    questions: [_makeQuestion(mode: mode)],
    currentIndex: currentIndex,
    selectedAnswer: selectedAnswer,
    answerFeedback: answerFeedback,
    streak: streak,
    showPinyin: showPinyin,
  );
}

Widget buildQuizView(QuizState state) {
  return buildTestAppWithScope(
    ProviderScope(
      overrides: [
        quizProvider.overrideWith(() => _FakeQuizNotifier(state)),
      ],
      child: const QuizQuestionView(),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(disableGoogleFonts);

  group('QuizQuestionView — hanziToMeaning mode', () {
    testWidgets('shows hanzi on question card', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState()));
      await tester.pump();
      expect(find.text('你好'), findsOneWidget);
    });

    testWidgets('shows pinyin when showPinyin=true', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState(showPinyin: true)));
      await tester.pump();
      expect(find.text('nǐ hǎo'), findsOneWidget);
    });

    testWidgets('hides pinyin when showPinyin=false', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState(showPinyin: false)));
      await tester.pump();
      expect(find.text('nǐ hǎo'), findsNothing);
      // Shows dots placeholder instead
      expect(find.text('• • •'), findsOneWidget);
    });

    testWidgets('renders 4 answer options', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState()));
      await tester.pump();
      expect(find.byType(HanzifyQuizOption), findsNWidgets(4));
    });

    testWidgets('shows mode label in header', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState()));
      await tester.pump();
      expect(find.text('🀄 Hanzi → Nghĩa'), findsOneWidget);
    });

    testWidgets('shows streak badge', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState(streak: 5)));
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });
  });

  group('QuizQuestionView — meaningToHanzi mode', () {
    testWidgets('shows Vietnamese meaning as question', (tester) async {
      await tester.pumpWidget(
        buildQuizView(_makeState(mode: QuizMode.meaningToHanzi)),
      );
      await tester.pump();
      expect(find.text('xin chào'), findsOneWidget);
    });

    testWidgets('shows mode label for meaningToHanzi', (tester) async {
      await tester.pumpWidget(
        buildQuizView(_makeState(mode: QuizMode.meaningToHanzi)),
      );
      await tester.pump();
      expect(find.text('🇻🇳 Nghĩa → Hanzi'), findsOneWidget);
    });
  });

  group('QuizQuestionView — answer selection', () {
    testWidgets('selecting an answer updates selected state', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState()));
      await tester.pump();

      expect(find.byType(HanzifyQuizOption), findsNWidgets(4));

      // Tap first option
      await tester.tap(find.byType(HanzifyQuizOption).first);
      await tester.pump();

      // Advance past the 1400ms auto-advance timer so it completes cleanly
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
    });

    testWidgets('correct option shows correct state', (tester) async {
      // State with selectedAnswer=0 and it is correct (correctIndex=0)
      final state = _makeState(selectedAnswer: 0, answerFeedback: true);
      await tester.pumpWidget(buildQuizView(state));
      await tester.pump();

      final options = tester.widgetList<HanzifyQuizOption>(
        find.byType(HanzifyQuizOption),
      ).toList();
      expect(options[0].state, QuizOptionState.correct);
      expect(options[1].state, QuizOptionState.disabled);
    });

    testWidgets('wrong option shows wrong state + others disabled', (tester) async {
      // selectedAnswer=1 but correctIndex=0 → wrong
      final state = _makeState(selectedAnswer: 1, answerFeedback: false);
      await tester.pumpWidget(buildQuizView(state));
      await tester.pump();

      final options = tester.widgetList<HanzifyQuizOption>(
        find.byType(HanzifyQuizOption),
      ).toList();
      expect(options[0].state, QuizOptionState.correct);
      expect(options[1].state, QuizOptionState.wrong);
      expect(options[2].state, QuizOptionState.disabled);
      expect(options[3].state, QuizOptionState.disabled);
    });
  });

  group('QuizQuestionView — pinyin toggle', () {
    testWidgets('toggle pinyin button visible in hanziToMeaning mode', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState()));
      await tester.pump();
      // Toggle button shows "🙈 Ẩn" when pinyin is visible
      expect(find.text('🙈 Ẩn'), findsOneWidget);
    });

    testWidgets('toggle label changes when pinyin hidden', (tester) async {
      await tester.pumpWidget(buildQuizView(_makeState(showPinyin: false)));
      await tester.pump();
      expect(find.text('👁 Hiện'), findsOneWidget);
    });
  });

  group('QuizQuestionView — empty state', () {
    testWidgets('renders nothing when questions list is empty', (tester) async {
      const emptyState = QuizState();
      await tester.pumpWidget(buildQuizView(emptyState));
      await tester.pump();
      // QuizQuestionView returns SizedBox.shrink() — no quiz content rendered
      expect(find.byType(HanzifyQuizOption), findsNothing);
      expect(find.text('🀄 Hanzi → Nghĩa'), findsNothing);
    });
  });
}
