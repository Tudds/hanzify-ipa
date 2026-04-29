import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/learning/fsrs.dart';
import '../../../core/learning/study_session_controller.dart';
import '../../../core/learning/study_session_store.dart';
import '../../../core/learning_path/continue_target.dart';
import '../../../core/learning_path/learning_path_repository.dart';
import '../../../core/learning_path/learning_progress.dart';
import '../../../core/learning_path/learning_progress_store.dart';
import '../../learning_path/presentation/learning_path_screen.dart';
import '../../review_session/presentation/due_review_screen.dart';

class HomeDashboardState {
  const HomeDashboardState({
    required this.progress,
    required this.studySnapshot,
    required this.dueReviewCount,
    required this.completedUnits,
    required this.todayReviews,
    required this.streakDays,
    required this.dailyGoalProgress,
    required this.continueLabel,
  });

  final LearningProgressSnapshot progress;
  final StudySessionSnapshot studySnapshot;
  final int dueReviewCount;
  final int completedUnits;
  final int todayReviews;
  final int streakDays;
  final double dailyGoalProgress;
  final String continueLabel;
}

final homeDashboardStateProvider =
    FutureProvider.autoDispose<HomeDashboardState>((ref) async {
      const pathRepository = LearningPathRepository();
      const progressStore = LearningProgressStore();
      const studyStore = StudySessionStore();
      const scheduler = FsrsScheduler();
      const continueResolver = ContinueTargetResolver();

      final path = await pathRepository.load();
      final progress = await progressStore.load();
      final studySnapshot = await studyStore.load();
      final dueReviewCount = scheduler
          .dueCards(studySnapshot.cards.values, DateTime.now())
          .length;
      final continueTarget = continueResolver.resolve(
        path: path,
        progress: progress,
        dueReviewCount: dueReviewCount,
      );

      final todayReviews = _reviewsOnDay(studySnapshot, DateTime.now());
      return HomeDashboardState(
        progress: progress,
        studySnapshot: studySnapshot,
        dueReviewCount: dueReviewCount,
        completedUnits: progress.units.values
            .where((unit) => unit.status == LearningUnitStatus.completed)
            .length,
        todayReviews: todayReviews,
        streakDays: _streakDays(studySnapshot),
        dailyGoalProgress: (todayReviews / 10).clamp(0, 1),
        continueLabel: _continueLabel(continueTarget),
      );
    });

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hanzify')),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('Không tải được dashboard.')),
          data: (data) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(homeDashboardStateProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Hôm nay học gì?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  data.continueLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                _DashboardStats(data: data),
                const SizedBox(height: 12),
                _DailyGoalCard(data: data),
                const SizedBox(height: 20),
                _ActionCard(
                  icon: Icons.route_outlined,
                  title: 'Learning Path',
                  subtitle:
                      'Đi theo lộ trình HSK, mở khóa bài học và checkpoint.',
                  actionLabel: 'Mở lộ trình',
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LearningPathScreen(),
                      ),
                    );
                    ref.invalidate(homeDashboardStateProvider);
                  },
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.replay_outlined,
                  title: 'Ôn tập đến hạn',
                  subtitle: '${data.dueReviewCount} thẻ cần ôn theo FSRS.',
                  actionLabel: 'Ôn ngay',
                  onPressed: data.dueReviewCount == 0
                      ? null
                      : () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const DueReviewScreen(),
                            ),
                          );
                          ref.invalidate(homeDashboardStateProvider);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardStats extends StatelessWidget {
  const _DashboardStats({required this.data});

  final HomeDashboardState data;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatCard(
          label: 'Due reviews',
          value: '${data.dueReviewCount}',
          icon: Icons.schedule_outlined,
        ),
        _StatCard(
          label: 'SRS cards',
          value: '${data.studySnapshot.cards.length}',
          icon: Icons.style_outlined,
        ),
        _StatCard(
          label: 'Completed',
          value: '${data.completedUnits}',
          icon: Icons.check_circle_outline,
        ),
        _StatCard(
          label: 'Streak',
          value: '${data.streakDays}d',
          icon: Icons.local_fire_department_outlined,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.data});

  final HomeDashboardState data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_outlined),
                const SizedBox(width: 8),
                Text(
                  'Mục tiêu hôm nay',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: data.dailyGoalProgress),
            const SizedBox(height: 8),
            Text(
              '${data.todayReviews}/10 lượt ôn · ${data.completedUnits} unit đã hoàn thành',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String _continueLabel(ContinueTarget target) {
  switch (target) {
    case ReviewContinueTarget(:final dueCount):
      return 'Bạn có $dueCount thẻ cần ôn trước khi học mới.';
    case LessonContinueTarget(:final module, :final lesson):
      return 'Tiếp tục ${module.id} · Lesson ${lesson.index}.';
    case CheckpointContinueTarget(:final checkpoint):
      return 'Sẵn sàng làm checkpoint ${checkpoint.id}.';
    case NoContinueTarget():
      return 'Không có bài tiếp theo trong lộ trình hiện tại.';
  }
}

int _reviewsOnDay(StudySessionSnapshot snapshot, DateTime day) {
  return snapshot.logs.where((log) => _sameDay(log.reviewedAt, day)).length;
}

int _streakDays(StudySessionSnapshot snapshot) {
  if (snapshot.logs.isEmpty) return 0;
  var streak = 0;
  var day = DateTime.now();
  while (_reviewsOnDay(snapshot, day) > 0) {
    streak += 1;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
