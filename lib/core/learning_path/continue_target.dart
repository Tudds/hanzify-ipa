import 'learning_path_models.dart';
import 'learning_path_unlocks.dart';
import 'learning_progress.dart';

sealed class ContinueTarget {
  const ContinueTarget();
}

class ReviewContinueTarget extends ContinueTarget {
  const ReviewContinueTarget({required this.dueCount});

  final int dueCount;
}

class LessonContinueTarget extends ContinueTarget {
  const LessonContinueTarget({
    required this.stage,
    required this.module,
    required this.lesson,
  });

  final LearningStage stage;
  final LearningModule module;
  final LearningLesson lesson;
}

class CheckpointContinueTarget extends ContinueTarget {
  const CheckpointContinueTarget({
    required this.stage,
    required this.module,
    required this.checkpoint,
  });

  final LearningStage stage;
  final LearningModule module;
  final LearningCheckpoint checkpoint;
}

class NoContinueTarget extends ContinueTarget {
  const NoContinueTarget();
}

class ContinueTargetResolver {
  const ContinueTargetResolver({this.activeLevel = 2});

  final int activeLevel;

  ContinueTarget resolve({
    required HskLearningPath path,
    required LearningProgressSnapshot progress,
    int dueReviewCount = 0,
  }) {
    if (dueReviewCount > 0) {
      return ReviewContinueTarget(dueCount: dueReviewCount);
    }
    final unlocks = LearningPathUnlocks(activeLevel: activeLevel);
    final stage = _activeStage(path);
    if (stage == null) return const NoContinueTarget();

    for (var moduleIndex = 0; moduleIndex < stage.modules.length; moduleIndex++) {
      final module = stage.modules[moduleIndex];
      final moduleStatus = unlocks.moduleStatus(
        stage: stage,
        moduleIndex: moduleIndex,
        progress: progress,
      );
      if (moduleStatus == LearningUnitStatus.locked || moduleStatus == LearningUnitStatus.completed) {
        continue;
      }

      for (var lessonIndex = 0; lessonIndex < module.lessons.length; lessonIndex++) {
        final lessonStatus = unlocks.lessonStatus(
          stage: stage,
          module: module,
          lessonIndex: lessonIndex,
          progress: progress,
        );
        if (lessonStatus == LearningUnitStatus.available ||
            lessonStatus == LearningUnitStatus.started ||
            lessonStatus == LearningUnitStatus.retry) {
          return LessonContinueTarget(
            stage: stage,
            module: module,
            lesson: module.lessons[lessonIndex],
          );
        }
      }

      final checkpoint = _checkpointAfterModule(stage, module.id);
      if (checkpoint != null) {
        final checkpointStatus = unlocks.checkpointStatus(
          stage: stage,
          checkpoint: checkpoint,
          progress: progress,
        );
        if (checkpointStatus == LearningUnitStatus.available ||
            checkpointStatus == LearningUnitStatus.started ||
            checkpointStatus == LearningUnitStatus.retry) {
          return CheckpointContinueTarget(stage: stage, module: module, checkpoint: checkpoint);
        }
      }
    }

    return const NoContinueTarget();
  }

  LearningStage? _activeStage(HskLearningPath path) {
    for (final stage in path.stages) {
      if (stage.level == activeLevel) return stage;
    }
    return null;
  }

  LearningCheckpoint? _checkpointAfterModule(LearningStage stage, String moduleId) {
    for (final checkpoint in stage.checkpoints) {
      if (checkpoint.afterModule == moduleId) return checkpoint;
    }
    return null;
  }
}
