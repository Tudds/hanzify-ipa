import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/learning_path/learning_path_models.dart';
import 'package:hanzify/core/learning/study_session_store.dart';
import 'package:hanzify/core/learning_path/learning_path_repository.dart';
import 'package:hanzify/core/learning_path/learning_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanzify/features/learning_path/presentation/learning_path_screen.dart';

class _FakeLearningPathRepository extends LearningPathRepository {
  const _FakeLearningPathRepository();

  @override
  Future<HskLearningPath> load() async {
    return const HskLearningPath(
      version: 'test',
      title: 'Test Path',
      stages: [
        LearningStage(
          id: 'HSK1',
          goal: 'Review basics',
          modules: [],
          checkpoints: [],
        ),
        LearningStage(
          id: 'HSK2',
          goal: 'Active daily life',
          checkpoints: [],
          modules: [
            LearningModule(
              id: 'H2-M1',
              title: 'Lựa chọn, miêu tả và so sánh',
              type: 'conversation',
              canDo: 'Chọn đồ và so sánh lựa chọn.',
              sourceConversationIds: ['conv_shopping_02'],
              primaryGrammarIds: ['g_bi'],
              lessons: [
                LearningLesson(
                  index: 1,
                  type: 'preview',
                  title: 'Từ vựng mục tiêu',
                  conversationIds: ['conv_shopping_02'],
                  focusGrammarIds: [],
                ),
              ],
            ),
          ],
        ),
        LearningStage(
          id: 'HSK3',
          goal: 'Locked future',
          modules: [],
          checkpoints: [],
        ),
        LearningStage(
          id: 'HSK4',
          goal: 'Locked future',
          modules: [],
          checkpoints: [],
        ),
      ],
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('learning path shows HSK2 active and locked future stages', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          child: LearningPathScreen(
            repository: const _FakeLearningPathRepository(),
            progressStore: LearningProgressStore(preferences: preferences),
            studySessionStore: StudySessionStore(preferences: preferences),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Learning Path'), findsOneWidget);
    expect(find.textContaining('Current: HSK2'), findsOneWidget);
    expect(find.textContaining('HSK2 · Active'), findsOneWidget);
    expect(find.textContaining('HSK3 · Locked'), findsOneWidget);
    expect(find.textContaining('H2-M1'), findsWidgets);
    expect(find.text('Start module'), findsOneWidget);
    expect(find.textContaining('Tiếp tục: H2-M1 · Lesson 1'), findsOneWidget);
  });
}
