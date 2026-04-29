import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning_path/continue_target.dart';
import 'package:hanzify/core/learning_path/learning_path_models.dart';
import 'package:hanzify/core/learning_path/learning_progress.dart';

void main() {
  const lesson1 = LearningLesson(
    index: 1,
    type: 'preview',
    title: 'Preview',
    conversationIds: [],
    focusGrammarIds: [],
  );
  const lesson2 = LearningLesson(
    index: 2,
    type: 'input',
    title: 'Input',
    conversationIds: [],
    focusGrammarIds: [],
  );
  const module = LearningModule(
    id: 'H2-M1',
    title: 'Module',
    type: 'conversation',
    canDo: 'Can do',
    sourceConversationIds: [],
    primaryGrammarIds: [],
    lessons: [lesson1, lesson2],
  );
  const checkpoint = LearningCheckpoint(id: 'H2-C1', afterModule: 'H2-M1', focus: 'Focus');
  const path = HskLearningPath(
    version: 'test',
    title: 'Path',
    stages: [
      LearningStage(id: 'HSK2', goal: 'Goal', modules: [module], checkpoints: [checkpoint]),
    ],
  );
  const resolver = ContinueTargetResolver();

  test('due reviews take priority over lessons', () {
    final target = resolver.resolve(
      path: path,
      progress: const LearningProgressSnapshot(units: {}),
      dueReviewCount: 3,
    );

    expect(target, isA<ReviewContinueTarget>());
    expect((target as ReviewContinueTarget).dueCount, 3);
  });

  test('fresh progress continues to first lesson', () {
    final target = resolver.resolve(path: path, progress: const LearningProgressSnapshot(units: {}));

    expect(target, isA<LessonContinueTarget>());
    expect((target as LessonContinueTarget).lesson.index, 1);
  });

  test('completed first lesson continues to second lesson', () {
    final target = resolver.resolve(
      path: path,
      progress: LearningProgressSnapshot(
        units: {
          'H2-M1-L1': LearningUnitProgress(
            unitId: 'H2-M1-L1',
            unitKind: LearningUnitKind.lesson,
            stageId: 'HSK2',
            moduleId: 'H2-M1',
            status: LearningUnitStatus.completed,
          ),
        },
      ),
    );

    expect(target, isA<LessonContinueTarget>());
    expect((target as LessonContinueTarget).lesson.index, 2);
  });

  test('completed module lessons continues to checkpoint', () {
    final target = resolver.resolve(
      path: path,
      progress: LearningProgressSnapshot(
        units: {
          for (final id in ['H2-M1-L1', 'H2-M1-L2'])
            id: LearningUnitProgress(
              unitId: id,
              unitKind: LearningUnitKind.lesson,
              stageId: 'HSK2',
              moduleId: 'H2-M1',
              status: LearningUnitStatus.completed,
            ),
        },
      ),
    );

    expect(target, isA<CheckpointContinueTarget>());
    expect((target as CheckpointContinueTarget).checkpoint.id, 'H2-C1');
  });
}
