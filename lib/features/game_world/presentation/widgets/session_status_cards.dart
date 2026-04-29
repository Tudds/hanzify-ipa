import 'package:flutter/material.dart';

import '../../../../core/learning/lesson_context.dart';
import '../../../../core/learning/learning_asset_repository.dart';
import '../../../../core/learning/quiz_generator.dart';
import '../../../../core/learning/study_session_controller.dart';
import 'lesson_detail_card.dart';
import '../../application/game_session_controller.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    super.key,
    required this.session,
    required this.index,
    required this.snapshot,
    required this.lastResult,
    required this.answeredCount,
    required this.correctCount,
  });

  final HskLearningSessionSeed session;
  final int index;
  final StudySessionSnapshot snapshot;
  final StudyAnswerResult? lastResult;
  final int answeredCount;
  final int correctCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HSK${session.activeLevel} · ${session.collocations.length} collocations · Quiz ${index + 1}/${session.quizzes.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'FSRS local · ${snapshot.cards.length} cards · ${snapshot.reviewedCount} reviews · Score $correctCount/$answeredCount',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (lastResult != null) ...[
              const SizedBox(height: 4),
              Text(
                lastResult!.isCorrect
                    ? 'Last rating: Good'
                    : 'Last rating: Again',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SessionCompleteCard extends StatelessWidget {
  const SessionCompleteCard({
    super.key,
    required this.score,
    required this.failedQuizzes,
    required this.remediationGroups,
    required this.isCheckpoint,
    required this.onRetryFailed,
    required this.onRetryGroup,
  });

  final int score;
  final List<LearningQuiz> failedQuizzes;
  final List<RemediationGroup> remediationGroups;
  final bool isCheckpoint;
  final VoidCallback? onRetryFailed;
  final ValueChanged<RemediationGroup> onRetryGroup;

  @override
  Widget build(BuildContext context) {
    final passed = score >= 70;
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.verified_outlined : Icons.replay_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              passed ? 'Session passed' : 'Needs review',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Score: $score%'),
            if (passed) ...[
              const SizedBox(height: 12),
              Text(
                isCheckpoint
                    ? 'Reward unlocked: checkpoint badge + path progress.'
                    : 'Recap: bài học đã được lưu vào tiến độ học.',
                textAlign: TextAlign.center,
              ),
            ],
            if (!passed && failedQuizzes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Cần luyện lại ${failedQuizzes.length} câu sai'),
              const SizedBox(height: 4),
              Text(
                'Ưu tiên nhóm có nhiều lỗi trước, hoặc luyện lại tất cả câu sai.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final group in remediationGroups.take(4))
                _RemediationGroupTile(
                  group: group,
                  onRetry: () => onRetryGroup(group),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetryFailed,
                icon: const Icon(Icons.replay),
                label: const Text('Luyện lại câu sai'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LessonIntroCard extends StatelessWidget {
  const LessonIntroCard({
    super.key,
    required this.session,
    required this.lessonContext,
    required this.isCheckpoint,
    required this.onStart,
  });

  final HskLearningSessionSeed session;
  final LessonContext? lessonContext;
  final bool isCheckpoint;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCheckpoint ? Icons.flag_outlined : Icons.route_outlined,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCheckpoint ? 'Checkpoint' : 'Bắt đầu bài học',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Đi theo 4 bước từ trên xuống, rồi mới làm quiz.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _IntroStep(
              index: 1,
              title: 'Nghe hội thoại',
              body:
                  'Đọc Hán tự, pinyin và nghĩa Việt từng dòng. Bấm loa ở từng dòng để nghe đúng audio.',
            ),
            _IntroStep(
              index: 2,
              title: 'Nhìn từ khóa',
              body:
                  'Ưu tiên các từ HSK${session.activeLevel} trong bài; đây là từ sẽ xuất hiện trong quiz.',
            ),
            _IntroStep(
              index: 3,
              title: 'Nhận mẫu câu',
              body:
                  'Xem ý nghĩa grammar bằng tiếng Việt, không cần nhớ mã kỹ thuật.',
            ),
            _IntroStep(
              index: 4,
              title: isCheckpoint ? 'Vượt checkpoint' : 'Làm quiz',
              body: isCheckpoint
                  ? 'Đạt từ 70% để mở reward và tiếp tục learning path.'
                  : 'Đạt từ 70% để lưu tiến độ và tạo thẻ ôn SRS.',
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: SingleChildScrollView(
                child: LessonDetailCard(
                  session: session,
                  lessonContext: lessonContext,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bắt đầu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            child: Text('$index'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemediationGroupTile extends StatelessWidget {
  const _RemediationGroupTile({required this.group, required this.onRetry});

  final RemediationGroup group;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final example = group.quizzes.first;
    return Card.filled(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${group.kind}: ${group.label} · ${group.quizzes.length} lỗi',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text('Gợi ý: xem lại “${example.prompt}”'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Luyện nhóm này'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
