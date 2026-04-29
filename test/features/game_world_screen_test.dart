import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/collocation.dart';
import 'package:hanzify/core/learning/learning_asset_repository.dart';
import 'package:hanzify/core/learning/lesson_context.dart';
import 'package:hanzify/core/learning/quiz_generator.dart';
import 'package:hanzify/core/learning/study_session_store.dart';
import 'package:hanzify/features/game_world/presentation/game_world_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSessionFactory extends HskLearningSessionFactory {
  const _FakeSessionFactory();

  @override
  Future<HskLearningSessionSeed> createHsk2Session({
    int quizLimit = 8,
    LessonContext? lessonContext,
  }) async {
    return const HskLearningSessionSeed(
      activeLevel: 2,
      collocations: [
        CollocationItem(
          id: 'c1',
          level: 2,
          source: 'vocab_example',
          textCn: '我学习中文。',
          pinyin: 'Wǒ xuéxí Zhōngwén.',
          textVi: 'Tôi học tiếng Trung.',
          targetVocabIds: ['hsk2_中文'],
          targetGrammarIds: [],
          conversationIds: [],
          tags: [],
          difficulty: 2.4,
        ),
      ],
      quizzes: [
        LearningQuiz(
          id: 'q1',
          type: QuizType.vocabRecognition,
          prompt: '我学习中文。',
          answer: 'Tôi học tiếng Trung.',
          choices: ['Hôm nay rất nóng.', 'Tôi học tiếng Trung.'],
          sourceCollocationId: 'c1',
          targetId: 'hsk2_中文',
        ),
      ],
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  remediationFlowTest();

  testWidgets('game world renders generated HSK2 session', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          child: GameWorldScreen(
            sessionFactory: const _FakeSessionFactory(),
            studySessionStore: StudySessionStore(preferences: preferences),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();

    expect(find.textContaining('HSK2'), findsWidgets);
    expect(find.textContaining('collocations'), findsOneWidget);
    expect(find.text("Today's lesson"), findsOneWidget);
    expect(find.text('Conversation context'), findsOneWidget);
    expect(find.text('Key vocab'), findsOneWidget);
    expect(find.text('Key grammar'), findsOneWidget);
    expect(find.text('你好'), findsNothing);
    expect(find.textContaining('0 reviews'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();

    expect(find.text('我学习中文。'), findsOneWidget);

    await tester.tap(find.text('Tôi học tiếng Trung.'));
    await tester.pump();

    expect(find.textContaining('1 reviews'), findsOneWidget);
    expect(find.text('Last rating: Good'), findsOneWidget);
    expect(find.text('Session passed'), findsOneWidget);
    expect(find.text('Score: 100%'), findsOneWidget);
  });
}

class _TwoQuizSessionFactory extends HskLearningSessionFactory {
  const _TwoQuizSessionFactory();

  @override
  Future<HskLearningSessionSeed> createHsk2Session({
    int quizLimit = 8,
    LessonContext? lessonContext,
  }) async {
    return const HskLearningSessionSeed(
      activeLevel: 2,
      collocations: [
        CollocationItem(
          id: 'c1',
          level: 2,
          source: 'vocab_example',
          textCn: '我学习中文。',
          pinyin: 'Wǒ xuéxí Zhōngwén.',
          textVi: 'Tôi học tiếng Trung.',
          targetVocabIds: ['hsk2_中文'],
          targetGrammarIds: [],
          conversationIds: [],
          tags: [],
          difficulty: 2.4,
        ),
      ],
      quizzes: [
        LearningQuiz(
          id: 'q1',
          type: QuizType.vocabRecognition,
          prompt: '我学习中文。',
          answer: 'Tôi học tiếng Trung.',
          choices: ['Sai 1', 'Tôi học tiếng Trung.'],
          sourceCollocationId: 'c1',
          targetId: 'hsk2_中文',
        ),
        LearningQuiz(
          id: 'q2',
          type: QuizType.vocabRecognition,
          prompt: '今天很热。',
          answer: 'Hôm nay rất nóng.',
          choices: ['Sai 2', 'Hôm nay rất nóng.'],
          sourceCollocationId: 'c1',
          targetId: 'hsk2_今天',
        ),
      ],
    );
  }
}

void remediationFlowTest() {
  testWidgets('failed session shows remediation and retries failed items', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          child: GameWorldScreen(
            sessionFactory: const _TwoQuizSessionFactory(),
            studySessionStore: StudySessionStore(preferences: preferences),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();

    await tester.tap(find.text('Sai 1'));
    await tester.pump();
    await tester.tap(find.text('Sai 2'));
    await tester.pump();

    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Score: 0%'), findsOneWidget);
    expect(find.text('Cần luyện lại 2 câu sai'), findsOneWidget);
    expect(find.text('Từ vựng: 中文 · 1 lỗi'), findsOneWidget);
    expect(find.text('Từ vựng: 今天 · 1 lỗi'), findsOneWidget);

    await tester.tap(find.text('Luyện nhóm này').first);
    await tester.pump();

    expect(find.text('我学习中文。'), findsOneWidget);
  });
}
