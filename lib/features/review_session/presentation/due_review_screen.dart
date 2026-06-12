import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/learning/fsrs.dart';
import '../../../core/learning/study_session_controller.dart';
import '../../../core/learning/study_session_store.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/sliver_page_scaffold.dart';
import '../../account/presentation/account_sheet.dart';

final dueReviewSnapshotProvider = FutureProvider.autoDispose
    .family<StudySessionSnapshot, StudySessionStore>((ref, store) {
      return store.load();
    });

class DueReviewScreen extends ConsumerStatefulWidget {
  const DueReviewScreen({
    super.key,
    this.studySessionStore = const StudySessionStore(),
    this.scheduler = const FsrsScheduler(),
  });

  final StudySessionStore studySessionStore;
  final FsrsScheduler scheduler;

  @override
  ConsumerState<DueReviewScreen> createState() => _DueReviewScreenState();
}

class _DueReviewScreenState extends ConsumerState<DueReviewScreen> {
  var _reviewed = 0;

  /// Icon tài khoản — sync sống ở tab Ôn tập vì tiến độ nằm ở đây.
  /// Ẩn hoàn toàn khi Supabase chưa cấu hình (app local-only).
  List<Widget> get _accountActions => [
    if (SupabaseConfig.isConfigured)
      IconButton(
        tooltip: 'Tài khoản',
        icon: const Icon(Icons.account_circle_outlined),
        onPressed: () => showAccountSheet(context),
      ),
  ];

  Future<void> _rate(
    StudySessionSnapshot snapshot,
    SrsCard card,
    SrsRating rating,
  ) async {
    final result = widget.scheduler.review(card, rating, DateTime.now());
    final cards = Map<String, SrsCard>.from(snapshot.cards);
    final logs = List<SrsReviewLog>.from(snapshot.logs);
    cards[result.card.id] = result.card;
    logs.add(result.log);
    await widget.studySessionStore.save(
      StudySessionSnapshot(
        cards: cards,
        logs: logs,
        reviewedCount: logs.length,
      ),
    );
    setState(() => _reviewed += 1);
    ref.invalidate(dueReviewSnapshotProvider(widget.studySessionStore));
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(
      dueReviewSnapshotProvider(widget.studySessionStore),
    );

    return snapshot.when(
      loading: () => SliverPageScaffold(
        title: 'Ôn tập',
        subtitle: 'FSRS review từ tiến độ local.',
        headerAssetPath: 'assets/images/gen_header_review.svg',
        actions: _accountActions,
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (_, _) => SliverPageScaffold(
        title: 'Ôn tập',
        subtitle: 'FSRS review từ tiến độ local.',
        headerAssetPath: 'assets/images/gen_header_review.svg',
        actions: _accountActions,
        slivers: const [
          SliverStateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Không tải được review',
            message: 'Vui lòng thử lại sau.',
          ),
        ],
      ),
      data: (data) {
        final dueCards = widget.scheduler.dueCards(
          data.cards.values,
          DateTime.now(),
        );
        final sessionSize = ref.watch(
          userProfileProvider.select((profile) => profile.sessionSize),
        );
        // Giới hạn phiên theo thời lượng học/ngày user đã chọn; phần còn lại
        // vẫn đến hạn và hiện lại ở phiên kế tiếp.
        final sessionRemaining = (sessionSize - _reviewed).clamp(
          0,
          dueCards.length,
        );
        if (dueCards.isEmpty || sessionRemaining == 0) {
          return SliverPageScaffold(
            title: 'Ôn tập',
            subtitle: 'FSRS review từ tiến độ local.',
            headerAssetPath: 'assets/images/gen_header_review.svg',
            actions: _accountActions,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ReviewDone(reviewed: _reviewed),
              ),
            ],
          );
        }
        final card = dueCards.first;
        return SliverPageScaffold(
          title: 'Ôn tập',
          subtitle:
              '${dueCards.length} thẻ đến hạn · phiên này $sessionRemaining thẻ.',
          headerAssetPath: 'assets/images/gen_header_review.svg',
          actions: _accountActions,
          slivers: [
            SliverToBoxAdapter(
              child: _ReviewCard(
                card: card,
                remaining: sessionRemaining,
                reviewed: _reviewed,
                onRate: (rating) => _rate(data, card, rating),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.card,
    required this.remaining,
    required this.reviewed,
    required this.onRate,
  });

  final SrsCard card;
  final int remaining;
  final int reviewed;
  final ValueChanged<SrsRating> onRate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final targetText = _targetText(card.targetId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phiên ôn tập hôm nay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Còn lại $remaining thẻ · Đã ôn $reviewed',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 44,
                height: 44,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: (reviewed + remaining) == 0 ? 0.0 : reviewed / (reviewed + remaining),
                  ),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: value,
                          strokeWidth: 4.5,
                          backgroundColor: colors.outlineVariant.withValues(alpha:0.24),
                          color: colors.primary,
                        ),
                        Text(
                          '${(value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _cardTypeLabel(card.cardType),
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    targetText,
                    style: AppTypography.hanziDisplay(
                      size: 40,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _ReviewInfoRow(label: 'ID', value: card.targetId),
                  _ReviewInfoRow(label: 'Target', value: card.targetType),
                  _ReviewInfoRow(
                    label: 'Schedule',
                    value: _scheduleLabel(card),
                  ),
                  _ReviewInfoRow(
                    label: 'FSRS',
                    value: 'Reps ${card.reps} · Lapses ${card.lapses}',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _hintLabel(card.cardType),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn nhớ tốt đến đâu?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _RatingButton(
            title: 'Again',
            subtitle: 'Quên hoặc sai — ôn lại sớm.',
            onPressed: () => onRate(SrsRating.again),
          ),
          _RatingButton(
            title: 'Hard',
            subtitle: 'Nhớ khó — kéo giãn ít.',
            onPressed: () => onRate(SrsRating.hard),
          ),
          _RatingButton(
            title: 'Good',
            subtitle: 'Nhớ đúng — lịch ôn bình thường.',
            filled: true,
            onPressed: () => onRate(SrsRating.good),
          ),
          _RatingButton(
            title: 'Easy',
            subtitle: 'Rất dễ — kéo giãn nhiều hơn.',
            filled: true,
            onPressed: () => onRate(SrsRating.easy),
          ),
        ],
      ),
    );
  }

  String _targetText(String id) {
    final separator = id.indexOf('_');
    if (separator == -1 || separator == id.length - 1) return id;
    return id.substring(separator + 1);
  }

  String _cardTypeLabel(String cardType) {
    switch (cardType) {
      case 'recognition':
        return 'Nhận diện nghĩa / cách dùng';
      case 'recall':
        return 'Gợi nhớ chủ động';
      case 'pinyin':
        return 'Ôn pinyin';
      default:
        return 'Ôn tập SRS';
    }
  }

  String _hintLabel(String cardType) {
    switch (cardType) {
      case 'recognition':
        return 'Hãy tự nói nghĩa tiếng Việt hoặc ngữ cảnh dùng trước khi chấm điểm.';
      case 'recall':
        return 'Hãy tự nhớ chữ Hán/cụm từ trước khi chấm điểm.';
      case 'pinyin':
        return 'Hãy đọc pinyin và thanh điệu trước khi chấm điểm.';
      default:
        return 'Tự kiểm tra trước, sau đó chọn mức nhớ thật để FSRS xếp lịch.';
    }
  }

  String _scheduleLabel(SrsCard card) {
    final dueAt = card.dueAt;
    if (dueAt == null) return 'New card';
    final now = DateTime.now();
    if (!dueAt.isAfter(now)) return 'Due now';
    final days = dueAt.difference(now).inDays;
    return days <= 0 ? 'Due today' : 'Due in $days days';
  }
}

class _ReviewInfoRow extends StatelessWidget {
  const _ReviewInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.filled = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: filled
          ? FilledButton(onPressed: onPressed, child: child)
          : FilledButton.tonal(onPressed: onPressed, child: child),
    );
  }
}

class _ReviewDone extends StatelessWidget {
  const _ReviewDone({required this.reviewed});

  final int reviewed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SvgPicture.asset(
                      'assets/images/gen_review_complete.svg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Review complete',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Reviewed $reviewed cards'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
