import 'learning_path_models.dart';
import 'learning_progress.dart';

class LearningPathUnlocks {
  const LearningPathUnlocks({this.activeLevel = 2});

  final int activeLevel;

  LearningUnitStatus moduleStatus({
    required LearningStage stage,
    required int moduleIndex,
    required LearningProgressSnapshot progress,
  }) {
    if (stage.level < activeLevel) return LearningUnitStatus.completed;
    if (stage.level > activeLevel) return LearningUnitStatus.locked;
    final module = stage.modules[moduleIndex];
    if (_moduleCompleted(stage, module, progress)) return LearningUnitStatus.completed;
    if (moduleIndex == 0) return LearningUnitStatus.available;
    final previous = stage.modules[moduleIndex - 1];
    return _moduleCompleted(stage, previous, progress)
        ? LearningUnitStatus.available
        : LearningUnitStatus.locked;
  }

  LearningUnitStatus lessonStatus({
    required LearningStage stage,
    required LearningModule module,
    required int lessonIndex,
    required LearningProgressSnapshot progress,
  }) {
    final lesson = module.lessons[lessonIndex];
    final unitId = lessonUnitId(module, lesson);
    final saved = progress.unit(unitId);
    if (saved?.status == LearningUnitStatus.completed) return LearningUnitStatus.completed;
    if (stage.level != activeLevel) {
      return stage.level < activeLevel ? LearningUnitStatus.completed : LearningUnitStatus.locked;
    }
    if (lessonIndex == 0) return LearningUnitStatus.available;
    final previous = module.lessons[lessonIndex - 1];
    final previousSaved = progress.unit(lessonUnitId(module, previous));
    return previousSaved?.status == LearningUnitStatus.completed
        ? LearningUnitStatus.available
        : LearningUnitStatus.locked;
  }

  LearningUnitStatus checkpointStatus({
    required LearningStage stage,
    required LearningCheckpoint checkpoint,
    required LearningProgressSnapshot progress,
  }) {
    final saved = progress.unit(checkpointUnitId(checkpoint));
    if (saved?.status == LearningUnitStatus.completed) return LearningUnitStatus.completed;
    if (stage.level != activeLevel) {
      return stage.level < activeLevel ? LearningUnitStatus.completed : LearningUnitStatus.locked;
    }
    final module = _moduleById(stage, checkpoint.afterModule);
    if (module == null) return LearningUnitStatus.locked;
    return _moduleLessonsCompleted(module, progress)
        ? LearningUnitStatus.available
        : LearningUnitStatus.locked;
  }

  String lessonUnitId(LearningModule module, LearningLesson lesson) {
    return '${module.id}-L${lesson.index}';
  }

  String checkpointUnitId(LearningCheckpoint checkpoint) => checkpoint.id;

  bool _moduleCompleted(
    LearningStage stage,
    LearningModule module,
    LearningProgressSnapshot progress,
  ) {
    if (!_moduleLessonsCompleted(module, progress)) return false;
    final checkpoint = _checkpointAfterModule(stage, module.id);
    if (checkpoint == null) return true;
    return progress.unit(checkpointUnitId(checkpoint))?.status == LearningUnitStatus.completed;
  }

  bool _moduleLessonsCompleted(LearningModule module, LearningProgressSnapshot progress) {
    if (module.lessons.isEmpty) return false;
    return module.lessons.every((lesson) {
      return progress.unit(lessonUnitId(module, lesson))?.status == LearningUnitStatus.completed;
    });
  }

  LearningCheckpoint? _checkpointAfterModule(LearningStage stage, String moduleId) {
    for (final checkpoint in stage.checkpoints) {
      if (checkpoint.afterModule == moduleId) return checkpoint;
    }
    return null;
  }

  LearningModule? _moduleById(LearningStage stage, String moduleId) {
    for (final module in stage.modules) {
      if (module.id == moduleId) return module;
    }
    return null;
  }
}
