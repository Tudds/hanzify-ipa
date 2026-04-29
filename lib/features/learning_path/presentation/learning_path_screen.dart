import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/learning/fsrs.dart';
import '../../../core/learning/lesson_context.dart';
import '../../../core/learning/study_session_controller.dart';
import '../../../core/learning/study_session_store.dart';
import '../../../core/learning_path/continue_target.dart';
import '../../../core/learning_path/learning_path_models.dart';
import '../../../core/learning_path/learning_path_repository.dart';
import '../../../core/learning_path/learning_path_unlocks.dart';
import '../../../core/learning_path/learning_progress.dart';
import '../../../core/learning_path/learning_progress_store.dart';
import '../../game_world/presentation/game_world_screen.dart';
import '../../review_session/presentation/due_review_screen.dart';

@immutable
class LearningPathScreenArgs {
  const LearningPathScreenArgs({
    required this.repository,
    required this.progressStore,
    required this.studySessionStore,
  });

  final LearningPathRepository repository;
  final LearningProgressStore progressStore;
  final StudySessionStore studySessionStore;
}

class LearningPathViewState {
  const LearningPathViewState({
    required this.path,
    required this.progress,
    required this.studySnapshot,
  });

  final HskLearningPath path;
  final LearningProgressSnapshot progress;
  final StudySessionSnapshot studySnapshot;
}

final learningPathViewStateProvider = FutureProvider.autoDispose
    .family<LearningPathViewState, LearningPathScreenArgs>((ref, args) async {
      final path = await args.repository.load();
      final progress = await args.progressStore.load();
      final studySnapshot = await args.studySessionStore.load();
      return LearningPathViewState(
        path: path,
        progress: progress,
        studySnapshot: studySnapshot,
      );
    });

class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({
    super.key,
    this.repository = const LearningPathRepository(),
    this.progressStore = const LearningProgressStore(),
    this.studySessionStore = const StudySessionStore(),
    this.activeLevel = 2,
  });

  final LearningPathRepository repository;
  final LearningProgressStore progressStore;
  final StudySessionStore studySessionStore;
  final int activeLevel;

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  final _unlocks = const LearningPathUnlocks();
  final _continueResolver = const ContinueTargetResolver();
  final _scheduler = const FsrsScheduler();
  late final LearningPathScreenArgs _args;
  var _selectedLevel = 2;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.activeLevel;
    _args = LearningPathScreenArgs(
      repository: widget.repository,
      progressStore: widget.progressStore,
      studySessionStore: widget.studySessionStore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(learningPathViewStateProvider(_args));

    return Scaffold(
      body: SafeArea(
        child: viewState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('Không tải được learning path.')),
          data: (data) {
            final path = data.path;
            final selectedStage = path.stages.firstWhere(
              (stage) => stage.level == _selectedLevel,
              orElse: () => path.stages.first,
            );
            final dueReviewCount = _dueReviewCount(data.studySnapshot);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: _LearningPathHeader(
                      activeLevel: widget.activeLevel,
                      selectedStage: selectedStage,
                      continueTarget: _continueResolver.resolve(
                        path: path,
                        progress: data.progress,
                        dueReviewCount: dueReviewCount,
                      ),
                      onContinue: () => _continue(path, data),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _StageSelector(
                      stages: path.stages,
                      selectedLevel: _selectedLevel,
                      activeLevel: widget.activeLevel,
                      onSelected: (level) =>
                          setState(() => _selectedLevel = level),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  sliver: SliverList.separated(
                    itemCount: selectedStage.modules.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final module = selectedStage.modules[index];
                      final state = _unlocks.moduleStatus(
                        stage: selectedStage,
                        moduleIndex: index,
                        progress: data.progress,
                      );
                      final checkpoints = selectedStage.checkpoints
                          .where(
                            (checkpoint) => checkpoint.afterModule == module.id,
                          )
                          .toList(growable: false);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ModuleCard(
                            module: module,
                            state: state,
                            lessonStatuses: [
                              for (
                                var lessonIndex = 0;
                                lessonIndex < module.lessons.length;
                                lessonIndex++
                              )
                                _unlocks.lessonStatus(
                                  stage: selectedStage,
                                  module: module,
                                  lessonIndex: lessonIndex,
                                  progress: data.progress,
                                ),
                            ],
                            onStart:
                                state == LearningUnitStatus.available ||
                                    state == LearningUnitStatus.started
                                ? () => _startModule(
                                    selectedStage,
                                    module,
                                    data.progress,
                                  )
                                : null,
                          ),
                          for (final checkpoint in checkpoints) ...[
                            const SizedBox(height: 12),
                            _CheckpointCard(
                              checkpoint: checkpoint,
                              state: _unlocks.checkpointStatus(
                                stage: selectedStage,
                                checkpoint: checkpoint,
                                progress: data.progress,
                              ),
                              onStart:
                                  _unlocks.checkpointStatus(
                                        stage: selectedStage,
                                        checkpoint: checkpoint,
                                        progress: data.progress,
                                      ) ==
                                      LearningUnitStatus.available
                                  ? () => _startCheckpoint(
                                      selectedStage,
                                      module,
                                      checkpoint,
                                    )
                                  : null,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _dueReviewCount(StudySessionSnapshot studySnapshot) {
    return _scheduler
        .dueCards(studySnapshot.cards.values, DateTime.now())
        .length;
  }

  Future<void> _startModule(
    LearningStage stage,
    LearningModule module,
    LearningProgressSnapshot progress,
  ) async {
    final lesson = _nextAvailableLesson(stage, module, progress);
    if (lesson == null) return;
    await _startLesson(stage, module, lesson);
  }

  Future<void> _startLesson(
    LearningStage stage,
    LearningModule module,
    LearningLesson lesson,
  ) async {
    final unitId = _unlocks.lessonUnitId(module, lesson);
    final grammarIds = lesson.focusGrammarIds.isEmpty
        ? module.primaryGrammarIds
        : lesson.focusGrammarIds;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameWorldScreen(
          studySessionStore: widget.studySessionStore,
          lessonContext: LessonContext(
            stageId: stage.id,
            moduleId: module.id,
            lessonUnitId: unitId,
            level: stage.level,
            conversationIds: lesson.conversationIds,
            grammarIds: grammarIds,
          ),
          onSessionCompleted: (score) async {
            final now = DateTime.now();
            final progress = LearningUnitProgress(
              unitId: unitId,
              unitKind: LearningUnitKind.lesson,
              stageId: stage.id,
              moduleId: module.id,
              status: score >= 70
                  ? LearningUnitStatus.completed
                  : LearningUnitStatus.retry,
              score: score,
              startedAt: now,
              completedAt: score >= 70 ? now : null,
              lastOpenedAt: now,
            );
            await widget.progressStore.upsert(progress);
          },
        ),
      ),
    );
    ref.invalidate(learningPathViewStateProvider(_args));
  }

  Future<void> _startCheckpoint(
    LearningStage stage,
    LearningModule module,
    LearningCheckpoint checkpoint,
  ) async {
    final unitId = _unlocks.checkpointUnitId(checkpoint);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameWorldScreen(
          studySessionStore: widget.studySessionStore,
          lessonContext: LessonContext(
            stageId: stage.id,
            moduleId: module.id,
            lessonUnitId: unitId,
            level: stage.level,
            conversationIds: module.sourceConversationIds,
            grammarIds: module.primaryGrammarIds,
          ),
          onSessionCompleted: (score) async {
            final now = DateTime.now();
            await widget.progressStore.upsert(
              LearningUnitProgress(
                unitId: unitId,
                unitKind: LearningUnitKind.checkpoint,
                stageId: stage.id,
                moduleId: checkpoint.afterModule,
                status: score >= 70
                    ? LearningUnitStatus.completed
                    : LearningUnitStatus.retry,
                score: score,
                startedAt: now,
                completedAt: score >= 70 ? now : null,
                lastOpenedAt: now,
              ),
            );
          },
        ),
      ),
    );
    ref.invalidate(learningPathViewStateProvider(_args));
  }

  Future<void> _continue(
    HskLearningPath path,
    LearningPathViewState data,
  ) async {
    final target = _continueResolver.resolve(
      path: path,
      progress: data.progress,
      dueReviewCount: _dueReviewCount(data.studySnapshot),
    );
    switch (target) {
      case ReviewContinueTarget():
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                DueReviewScreen(studySessionStore: widget.studySessionStore),
          ),
        );
        ref.invalidate(learningPathViewStateProvider(_args));
      case LessonContinueTarget():
        await _startLesson(target.stage, target.module, target.lesson);
      case CheckpointContinueTarget():
        await _startCheckpoint(target.stage, target.module, target.checkpoint);
      case NoContinueTarget():
        return;
    }
  }

  LearningLesson? _nextAvailableLesson(
    LearningStage stage,
    LearningModule module,
    LearningProgressSnapshot progress,
  ) {
    for (var index = 0; index < module.lessons.length; index++) {
      final status = _unlocks.lessonStatus(
        stage: stage,
        module: module,
        lessonIndex: index,
        progress: progress,
      );
      if (status == LearningUnitStatus.available ||
          status == LearningUnitStatus.started) {
        return module.lessons[index];
      }
    }
    return null;
  }
}

class _LearningPathHeader extends StatelessWidget {
  const _LearningPathHeader({
    required this.activeLevel,
    required this.selectedStage,
    required this.continueTarget,
    required this.onContinue,
  });

  final int activeLevel;
  final LearningStage selectedStage;
  final ContinueTarget continueTarget;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Learning Path', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          'Current: HSK$activeLevel · ${selectedStage.modules.length} modules · ${selectedStage.checkpoints.length} checkpoints',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(selectedStage.goal, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: continueTarget is NoContinueTarget ? null : onContinue,
            icon: const Icon(Icons.play_arrow),
            label: Text(_continueLabel()),
          ),
        ),
      ],
    );
  }

  String _continueLabel() {
    switch (continueTarget) {
      case ReviewContinueTarget(:final dueCount):
        return 'Ôn tập: $dueCount cards đến hạn';
      case LessonContinueTarget(:final module, :final lesson):
        return 'Tiếp tục: ${module.id} · Lesson ${lesson.index}';
      case CheckpointContinueTarget(:final checkpoint):
        return 'Làm checkpoint: ${checkpoint.id}';
      case NoContinueTarget():
        return 'Không có bài tiếp theo';
    }
  }
}

class _StageSelector extends StatelessWidget {
  const _StageSelector({
    required this.stages,
    required this.selectedLevel,
    required this.activeLevel,
    required this.onSelected,
  });

  final List<LearningStage> stages;
  final int selectedLevel;
  final int activeLevel;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final stage in stages)
          ChoiceChip(
            label: Text('${stage.id} · ${_stageLabel(stage.level)}'),
            selected: stage.level == selectedLevel,
            avatar: Icon(_stageIcon(stage.level), size: 18),
            onSelected: (_) => onSelected(stage.level),
          ),
      ],
    );
  }

  String _stageLabel(int level) {
    if (level < activeLevel) return 'Review';
    if (level == activeLevel) return 'Active';
    return 'Locked';
  }

  IconData _stageIcon(int level) {
    if (level < activeLevel) return Icons.replay_outlined;
    if (level == activeLevel) return Icons.play_circle_outline;
    return Icons.lock_outline;
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.state,
    required this.lessonStatuses,
    required this.onStart,
  });

  final LearningModule module;
  final LearningUnitStatus state;
  final List<LearningUnitStatus> lessonStatuses;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locked = state == LearningUnitStatus.locked;

    return Card(
      color: colors.surface.withValues(alpha: locked ? 0.45 : 0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_stateIcon(), color: _stateColor(colors)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${module.id} · ${module.title}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(module.canDo, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.menu_book_outlined,
                  label: '${module.lessons.length} lessons',
                ),
                _InfoChip(
                  icon: Icons.chat_bubble_outline,
                  label: '${module.sourceConversationIds.length} conversations',
                ),
                _InfoChip(
                  icon: Icons.schema_outlined,
                  label: '${module.primaryGrammarIds.length} grammar',
                ),
                _InfoChip(icon: Icons.flag_outlined, label: _stateText()),
              ],
            ),
            const SizedBox(height: 12),
            _LessonPreview(module: module, lessonStatuses: lessonStatuses),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onStart,
                icon: Icon(locked ? Icons.lock_outline : Icons.play_arrow),
                label: Text(locked ? 'Locked' : 'Start module'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _stateIcon() {
    switch (state) {
      case LearningUnitStatus.locked:
        return Icons.lock_outline;
      case LearningUnitStatus.available:
        return Icons.play_circle_outline;
      case LearningUnitStatus.started:
        return Icons.timelapse_outlined;
      case LearningUnitStatus.completed:
        return Icons.check_circle_outline;
      case LearningUnitStatus.retry:
        return Icons.warning_amber_outlined;
    }
  }

  Color _stateColor(ColorScheme colors) {
    switch (state) {
      case LearningUnitStatus.locked:
        return colors.outline;
      case LearningUnitStatus.available:
      case LearningUnitStatus.started:
        return colors.primary;
      case LearningUnitStatus.completed:
      case LearningUnitStatus.retry:
        return colors.error;
    }
  }

  String _stateText() {
    switch (state) {
      case LearningUnitStatus.locked:
        return 'Locked';
      case LearningUnitStatus.available:
        return 'Available';
      case LearningUnitStatus.started:
        return 'Started';
      case LearningUnitStatus.completed:
        return 'Completed';
      case LearningUnitStatus.retry:
        return 'Retry';
    }
  }
}

class _CheckpointCard extends StatelessWidget {
  const _CheckpointCard({
    required this.checkpoint,
    required this.state,
    required this.onStart,
  });

  final LearningCheckpoint checkpoint;
  final LearningUnitStatus state;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locked = state == LearningUnitStatus.locked;

    return Card(
      color: colors.secondaryContainer.withValues(alpha: locked ? 0.35 : 0.75),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_icon(), color: locked ? colors.outline : colors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${checkpoint.id} · Checkpoint',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(checkpoint.focus),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(onPressed: onStart, child: Text(_buttonText())),
          ],
        ),
      ),
    );
  }

  IconData _icon() {
    switch (state) {
      case LearningUnitStatus.completed:
        return Icons.verified_outlined;
      case LearningUnitStatus.available:
      case LearningUnitStatus.started:
        return Icons.flag_outlined;
      case LearningUnitStatus.retry:
        return Icons.warning_amber_outlined;
      case LearningUnitStatus.locked:
        return Icons.lock_outline;
    }
  }

  String _buttonText() {
    switch (state) {
      case LearningUnitStatus.completed:
        return 'Passed';
      case LearningUnitStatus.available:
      case LearningUnitStatus.started:
        return 'Pass checkpoint';
      case LearningUnitStatus.retry:
        return 'Retry';
      case LearningUnitStatus.locked:
        return 'Locked';
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _LessonPreview extends StatelessWidget {
  const _LessonPreview({required this.module, required this.lessonStatuses});

  final LearningModule module;
  final List<LearningUnitStatus> lessonStatuses;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in module.lessons.take(3).indexed)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 14,
              child: Text(
                '${entry.$2.index}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            title: Text(entry.$2.title),
            subtitle: Text(entry.$2.type),
            trailing: Icon(_lessonIcon(lessonStatuses[entry.$1]), size: 18),
          ),
        if (module.lessons.length > 3)
          Align(
            alignment: Alignment.centerLeft,
            child: Text('+ ${module.lessons.length - 3} more lessons'),
          ),
      ],
    );
  }

  IconData _lessonIcon(LearningUnitStatus status) {
    switch (status) {
      case LearningUnitStatus.completed:
        return Icons.check_circle_outline;
      case LearningUnitStatus.available:
      case LearningUnitStatus.started:
        return Icons.radio_button_unchecked;
      case LearningUnitStatus.retry:
        return Icons.warning_amber_outlined;
      case LearningUnitStatus.locked:
        return Icons.lock_outline;
    }
  }
}
