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

class _ConversationSessionFactory extends HskLearningSessionFactory {
  const _ConversationSessionFactory();

  @override
  Future<HskLearningSessionSeed> createHsk2Session({
    int quizLimit = 8,
    LessonContext? lessonContext,
  }) async {
    return const HskLearningSessionSeed(
      activeLevel: 2,
      collocations: [
        CollocationItem(
          id: 'line1',
          level: 2,
          source: 'conversation_line',
          textCn: '这个菜怎么样？',
          pinyin: 'Zhège cài zěnmeyàng?',
          textVi: 'Món này thế nào?',
          targetVocabIds: ['hsk2_怎么样'],
          targetGrammarIds: ['g_zěnmeyàng'],
          conversationIds: ['conv_restaurant_02'],
          tags: ['restaurant'],
          difficulty: 2.3,
          audioUrl: 'https://example.test/conv/conv_restaurant_02_L0.mp3',
        ),
      ],
      quizzes: [
        LearningQuiz(
          id: 'q1',
          type: QuizType.vocabRecognition,
          prompt: '这个菜怎么样？',
          answer: 'Món này thế nào?',
          choices: ['Món này thế nào?', 'Tôi học tiếng Trung.'],
          sourceCollocationId: 'line1',
          targetId: 'hsk2_怎么样',
          targetGrammarIds: ['g_zěnmeyàng'],
          audioUrl: 'https://example.test/conv/conv_restaurant_02_L0.mp3',
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
    expect(find.text('Bài học hội thoại'), findsOneWidget);
    expect(find.text('Bước 1/2 · Mục tiêu bài'), findsOneWidget);
    expect(find.text('Mục tiêu bài'), findsOneWidget);
    expect(find.text('你好'), findsNothing);
    expect(find.textContaining('0 reviews'), findsOneWidget);

    await tester.ensureVisible(find.text('Tiếp tục'));
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    expect(find.text('Bước 2/2 · Hội thoại đầy đủ'), findsOneWidget);
    await tester.ensureVisible(find.text('Bắt đầu quiz'));
    await tester.tap(find.text('Bắt đầu quiz'));
    await tester.pump();

    expect(find.text('我学习中文。'), findsOneWidget);

    await tester.tap(find.text('Tôi học tiếng Trung.'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 reviews'), findsOneWidget);
    expect(find.text('Last rating: Good'), findsOneWidget);
    expect(find.text('Session passed'), findsOneWidget);
    expect(find.text('Score: 100%'), findsOneWidget);
  });

  testWidgets(
    'lesson intro shows conversation, clear vocab and grammar labels',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: GameWorldScreen(
              sessionFactory: const _ConversationSessionFactory(),
              studySessionStore: StudySessionStore(preferences: preferences),
              lessonContext: const LessonContext(
                stageId: 'HSK2',
                moduleId: 'H2-M1',
                lessonUnitId: 'H2-M1-L1',
                level: 2,
                conversationIds: ['conv_restaurant_02'],
                grammarIds: ['g_zěnmeyàng'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Mục tiêu bài'), findsOneWidget);
      await tester.ensureVisible(find.text('Tiếp tục'));
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();
      expect(find.text('Hội thoại đầy đủ'), findsOneWidget);
      expect(find.text('这个菜怎么样？'), findsOneWidget);
      expect(find.text('Món này thế nào?'), findsWidgets);
      await tester.ensureVisible(find.text('Tiếp tục'));
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();
      expect(find.text('Câu 1/1'), findsOneWidget);
      expect(find.text('Zhège cài zěnmeyàng?'), findsOneWidget);
      expect(find.text('怎么样'), findsOneWidget);
      expect(find.text('怎么样 — thế nào?'), findsOneWidget);
      expect(find.text('g_zěnmeyàng'), findsNothing);
    },
  );
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

    await tester.ensureVisible(find.text('Tiếp tục'));
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    await tester.ensureVisible(find.text('Bắt đầu quiz'));
    await tester.tap(find.text('Bắt đầu quiz'));
    await tester.pump();

    await tester.tap(find.text('Sai 1'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Sai 2'));
    await tester.pump(const Duration(milliseconds: 300));

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
