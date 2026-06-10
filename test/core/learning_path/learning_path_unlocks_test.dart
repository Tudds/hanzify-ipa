import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning_path/learning_path_models.dart';
import 'package:hanzify/core/learning_path/learning_path_unlocks.dart';
import 'package:hanzify/core/learning_path/learning_progress.dart';

void main() {
  checkpointUnlockTests();
  const unlocks = LearningPathUnlocks();
  const firstLesson = LearningLesson(
    index: 1,
    type: 'preview',
    title: 'Preview',
    conversationIds: [],
    focusGrammarIds: [],
  );
  const secondLesson = LearningLesson(
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
    phases: [
      LearningPhase(
        id: 'legacy',
        title: 'Lessons',
        type: 'legacy',
        lessons: [firstLesson, secondLesson],
      ),
    ],
  );
  const stage = LearningStage(
    id: 'HSK2',
    goal: 'Goal',
    modules: [module],
    checkpoints: [],
  );

  test('first HSK2 lesson is available by default and second is locked', () {
    const progress = LearningProgressSnapshot(units: {});

    expect(
      unlocks.lessonStatus(
        stage: stage,
        module: module,
        lessonIndex: 0,
        progress: progress,
      ),
      LearningUnitStatus.available,
    );
    expect(
      unlocks.lessonStatus(
        stage: stage,
        module: module,
        lessonIndex: 1,
        progress: progress,
      ),
      LearningUnitStatus.locked,
    );
  });

  test('completing lesson 1 unlocks lesson 2', () {
    final progress = LearningProgressSnapshot(
      units: {
        'H2-M1-L1': LearningUnitProgress(
          unitId: 'H2-M1-L1',
          unitKind: LearningUnitKind.lesson,
          stageId: 'HSK2',
          moduleId: 'H2-M1',
          status: LearningUnitStatus.completed,
        ),
      },
    );

    expect(
      unlocks.lessonStatus(
        stage: stage,
        module: module,
        lessonIndex: 1,
        progress: progress,
      ),
      LearningUnitStatus.available,
    );
  });

  test('phase status follows first lesson availability and completion', () {
    expect(
      unlocks.phaseStatus(
        stage: stage,
        module: module,
        phase: module.phases.first,
        progress: const LearningProgressSnapshot(units: {}),
      ),
      LearningUnitStatus.available,
    );

    final progress = LearningProgressSnapshot(
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
    );

    expect(
      unlocks.phaseStatus(
        stage: stage,
        module: module,
        phase: module.phases.first,
        progress: progress,
      ),
      LearningUnitStatus.completed,
    );
  });

  test('later phase is locked until previous phase final lesson completes', () {
    const phasedModule = LearningModule(
      id: 'H2-M2',
      title: 'Phased Module',
      type: 'conversation',
      canDo: 'Can do',
      sourceConversationIds: [],
      primaryGrammarIds: [],
      phases: [
        LearningPhase(
          id: 'intake',
          title: 'Intake',
          type: 'intake',
          lessons: [firstLesson],
        ),
        LearningPhase(
          id: 'practice',
          title: 'Practice',
          type: 'practice',
          lessons: [secondLesson],
        ),
      ],
    );
    const phasedStage = LearningStage(
      id: 'HSK2',
      goal: 'Goal',
      modules: [phasedModule],
      checkpoints: [],
    );

    expect(
      unlocks.phaseStatus(
        stage: phasedStage,
        module: phasedModule,
        phase: phasedModule.phases.last,
        progress: const LearningProgressSnapshot(units: {}),
      ),
      LearningUnitStatus.locked,
    );

    final progress = LearningProgressSnapshot(
      units: {
        'H2-M2-L1': LearningUnitProgress(
          unitId: 'H2-M2-L1',
          unitKind: LearningUnitKind.lesson,
          stageId: 'HSK2',
          moduleId: 'H2-M2',
          status: LearningUnitStatus.completed,
        ),
      },
    );

    expect(
      unlocks.phaseStatus(
        stage: phasedStage,
        module: phasedModule,
        phase: phasedModule.phases.last,
        progress: progress,
      ),
      LearningUnitStatus.available,
    );
  });
}

void checkpointUnlockTests() {
  const unlocks = LearningPathUnlocks();
  const lesson = LearningLesson(
    index: 1,
    type: 'preview',
    title: 'Preview',
    conversationIds: [],
    focusGrammarIds: [],
  );
  const firstModule = LearningModule(
    id: 'H2-M1',
    title: 'First',
    type: 'conversation',
    canDo: 'First module',
    sourceConversationIds: [],
    primaryGrammarIds: [],
    phases: [
      LearningPhase(
        id: 'legacy',
        title: 'Lessons',
        type: 'legacy',
        lessons: [lesson],
      ),
    ],
  );
  const secondModule = LearningModule(
    id: 'H2-M2',
    title: 'Second',
    type: 'conversation',
    canDo: 'Second module',
    sourceConversationIds: [],
    primaryGrammarIds: [],
    phases: [
      LearningPhase(
        id: 'legacy',
        title: 'Lessons',
        type: 'legacy',
        lessons: [lesson],
      ),
    ],
  );
  const checkpoint = LearningCheckpoint(
    id: 'H2-C1',
    afterModule: 'H2-M1',
    focus: 'Checkpoint focus',
  );
  const stage = LearningStage(
    id: 'HSK2',
    goal: 'Goal',
    modules: [firstModule, secondModule],
    checkpoints: [checkpoint],
  );

  test(
    'completed module lessons unlock checkpoint but not next module until checkpoint passes',
    () {
      final progress = LearningProgressSnapshot(
        units: {
          'H2-M1-L1': LearningUnitProgress(
            unitId: 'H2-M1-L1',
            unitKind: LearningUnitKind.lesson,
            stageId: 'HSK2',
            moduleId: 'H2-M1',
            status: LearningUnitStatus.completed,
          ),
        },
      );

      expect(
        unlocks.checkpointStatus(
          stage: stage,
          checkpoint: checkpoint,
          progress: progress,
        ),
        LearningUnitStatus.available,
      );
      expect(
        unlocks.moduleStatus(stage: stage, moduleIndex: 1, progress: progress),
        LearningUnitStatus.locked,
      );
    },
  );

  test('passed checkpoint unlocks next module', () {
    final progress = LearningProgressSnapshot(
      units: {
        'H2-M1-L1': LearningUnitProgress(
          unitId: 'H2-M1-L1',
          unitKind: LearningUnitKind.lesson,
          stageId: 'HSK2',
          moduleId: 'H2-M1',
          status: LearningUnitStatus.completed,
        ),
        'H2-C1': LearningUnitProgress(
          unitId: 'H2-C1',
          unitKind: LearningUnitKind.checkpoint,
          stageId: 'HSK2',
          moduleId: 'H2-M1',
          status: LearningUnitStatus.completed,
        ),
      },
    );

    expect(
      unlocks.moduleStatus(stage: stage, moduleIndex: 1, progress: progress),
      LearningUnitStatus.available,
    );
  });
}
