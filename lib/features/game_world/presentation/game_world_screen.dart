import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/learning/learning_asset_repository.dart';
import '../../../core/learning/lesson_context.dart';
import '../../../core/learning/study_session_store.dart';
import '../../../features/review_session/domain/review_challenge.dart';
import '../../../features/review_session/domain/review_challenge_mapper.dart';
import '../../../features/review_session/presentation/review_session_panel.dart';
import '../../../rive/hanzify_rive_scene_controller.dart';
import '../../../rive/rive_scene.dart';
import '../application/game_session_controller.dart';
import 'widgets/session_status_cards.dart';

class GameWorldScreen extends ConsumerStatefulWidget {
  const GameWorldScreen({
    super.key,
    this.sessionFactory = const HskLearningSessionFactory(),
    this.studySessionStore = const StudySessionStore(),
    this.lessonContext,
    this.onQuizAnswered,
    this.onSessionCompleted,
  });

  final HskLearningSessionFactory sessionFactory;
  final StudySessionStore studySessionStore;
  final LessonContext? lessonContext;
  final VoidCallback? onQuizAnswered;
  final ValueChanged<int>? onSessionCompleted;

  @override
  ConsumerState<GameWorldScreen> createState() => _GameWorldScreenState();
}

class _GameWorldScreenState extends ConsumerState<GameWorldScreen> {
  final _riveController = HanzifyRiveSceneController();
  late final GameSessionArgs _args;
  var _introCompleted = false;

  @override
  void initState() {
    super.initState();
    _args = GameSessionArgs(
      sessionFactory: widget.sessionFactory,
      studySessionStore: widget.studySessionStore,
      lessonContext: widget.lessonContext,
    );
  }

  void _handleAnswer(bool isCorrect) {
    _riveController.fire(isCorrect ? 'correct' : 'wrong');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Chính xác!' : 'Thử lại nhé.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(gameSessionControllerProvider(_args));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          RiveScene(
            asset: '',
            stateMachineName: 'GameWorld',
            controller: _riveController,
            placeholder: const _WorldPlaceholder(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: sessionState.when(
                      loading: () => const _LearningSessionLoadingCard(),
                      error: (error, _) =>
                          _LearningSessionErrorCard(error: error),
                      data: (state) {
                        if (state.session.quizzes.isEmpty) {
                          return const _LearningSessionErrorCard();
                        }
                        return _HskReviewCard(
                          state: state,
                          lessonContext: widget.lessonContext,
                          introCompleted: _introCompleted,
                          onStart: () => setState(() => _introCompleted = true),
                          onChoice: _handleChoice,
                          onRetryFailed: _retryFailed,
                          onRetryGroup: _retryGroup,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SupabaseStatus(isConfigured: SupabaseConfig.isConfigured),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleChoice(String selectedChoice) async {
    final controller = ref.read(gameSessionControllerProvider(_args).notifier);
    final before = ref.read(gameSessionControllerProvider(_args)).value;
    final result = await controller.answer(selectedChoice);
    final after = ref.read(gameSessionControllerProvider(_args)).requireValue;

    _handleAnswer(result.isCorrect);
    widget.onQuizAnswered?.call();

    if (before != null && !before.sessionCompleted && after.sessionCompleted) {
      widget.onSessionCompleted?.call(after.score);
    }
  }

  void _retryFailed() {
    ref.read(gameSessionControllerProvider(_args).notifier).retryFailed();
    setState(() => _introCompleted = true);
  }

  void _retryGroup(RemediationGroup group) {
    ref
        .read(gameSessionControllerProvider(_args).notifier)
        .retryQuizIndexes(group.quizIndexes);
    setState(() => _introCompleted = true);
  }
}

class _HskReviewCard extends StatelessWidget {
  const _HskReviewCard({
    required this.state,
    required this.lessonContext,
    required this.introCompleted,
    required this.onStart,
    required this.onChoice,
    required this.onRetryFailed,
    required this.onRetryGroup,
  });

  final GameSessionState state;
  final LessonContext? lessonContext;
  final bool introCompleted;
  final VoidCallback onStart;
  final ValueChanged<String> onChoice;
  final VoidCallback onRetryFailed;
  final ValueChanged<RemediationGroup> onRetryGroup;

  @override
  Widget build(BuildContext context) {
    final isCheckpoint = lessonContext?.lessonUnitId.contains('-C') ?? false;
    final challenge = state.currentQuiz.toReviewChallenge();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SessionSummaryCard(
          session: state.session,
          index: state.index,
          snapshot: state.snapshot,
          lastResult: state.lastResult,
          answeredCount: state.answeredCount,
          correctCount: state.correctCount,
        ),
        const SizedBox(height: 12),
        if (state.sessionCompleted)
          SessionCompleteCard(
            score: state.score,
            failedQuizzes: state.failedQuizzes,
            remediationGroups: state.remediationGroups,
            isCheckpoint: isCheckpoint,
            onRetryFailed: state.failedQuizIndexes.isEmpty
                ? null
                : onRetryFailed,
            onRetryGroup: onRetryGroup,
          )
        else if (!introCompleted)
          LessonIntroCard(
            session: state.session,
            lessonContext: lessonContext,
            isCheckpoint: isCheckpoint,
            onStart: onStart,
          )
        else
          ReviewSessionPanel(challenge: challenge, onChoice: onChoice),
      ],
    );
  }
}

class _LearningSessionLoadingCard extends StatelessWidget {
  const _LearningSessionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LearningSessionErrorCard extends StatelessWidget {
  const _LearningSessionErrorCard({this.error});

  final Object? error;

  static const _fallbackChallenge = ReviewChallenge(
    prompt: '你好',
    answer: 'Xin chào',
    choices: ['Xin chào', 'Cảm ơn', 'Tạm biệt'],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Theme.of(
            context,
          ).colorScheme.errorContainer.withValues(alpha: 0.85),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Không tải được HSK2 session. Đang dùng quiz dự phòng.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ReviewSessionPanel(challenge: _fallbackChallenge, onAnswer: (_) {}),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hanzify', style: Theme.of(context).textTheme.displaySmall),
        Text(
          'HSK2 collocation learning · local FSRS ready',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _WorldPlaceholder extends StatelessWidget {
  const _WorldPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.35),
            const Color(0xFF090B14),
            colors.tertiary.withValues(alpha: 0.25),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryContainer.withValues(alpha: 0.35),
            border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
          ),
          child: const Icon(Icons.smart_toy_outlined, size: 84),
        ),
      ),
    );
  }
}

class _SupabaseStatus extends StatelessWidget {
  const _SupabaseStatus({required this.isConfigured});

  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        isConfigured ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
        size: 18,
      ),
      label: Text(
        isConfigured ? 'Supabase connected' : 'Supabase not configured',
      ),
    );
  }
}
