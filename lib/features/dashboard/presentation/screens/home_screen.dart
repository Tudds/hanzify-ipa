import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/navigation/navigation_actions.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';
import 'package:hanzify/core/widgets/hanzify_progress_ring.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _weekdays = [
    'CHỦ NHẬT',
    'THỨ HAI',
    'THỨ BA',
    'THỨ TƯ',
    'THỨ NĂM',
    'THỨ SÁU',
    'THỨ BẢY',
  ];
  static const _months = [
    '',
    'THÁNG 1',
    'THÁNG 2',
    'THÁNG 3',
    'THÁNG 4',
    'THÁNG 5',
    'THÁNG 6',
    'THÁNG 7',
    'THÁNG 8',
    'THÁNG 9',
    'THÁNG 10',
    'THÁNG 11',
    'THÁNG 12',
  ];
  static const _hskEmojis = ['🌱', '🌿', '🌳', '🔥', '💎', '⭐'];
  static const _contentMaxWidth = 960.0;

  String _formattedDate() {
    final now = DateTime.now();
    return '${_weekdays[now.weekday % 7]}, ${now.day} ${_months[now.month]}';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Chào buổi sáng!';
    if (h < 18) return 'Chào buổi chiều!';
    return 'Chào buổi tối!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = themeColorsOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 840 ? 24.0 : 16.0;
    final totalVocabAsync = ref.watch(allVocabProvider);
    final dueVocabAsync = ref.watch(dueVocabProvider);
    final showPinyin = ref.watch(showPinyinProvider);

    final totalCount = totalVocabAsync.asData?.value.length ?? 0;
    final dueVocabs = dueVocabAsync.asData?.value ?? <Vocab>[];
    final dueCount = dueVocabs.length;
    final learnedCount =
        totalVocabAsync.asData?.value
            .where((v) => v.interval > 0 || v.isMastered)
            .length ??
        0;
    final progress = totalCount > 0 ? learnedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: CustomScrollView(
            slivers: [
              const HanzifyScreenHeader(title: 'Hanzify'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // ── Greeting ──
                      Text(
                        _formattedDate(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _greeting(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.subsectionGap),

                      // ── Hero Zone (Gradient Banner) ──
                      _HeroZone(
                        progress: progress,
                        doneCount: learnedCount,
                        totalCount: totalCount,
                        dueCount: dueCount,
                      ),

                      const SizedBox(height: AppSpacing.cardListGap),

                      // ── Study Now CTA ──
                      if (dueCount > 0)
                        _StudyNowCard(
                          key: const ValueKey('study_now_card'),
                          dueCount: dueCount,
                          onTap: () {
                            HanzifyHaptic.action();
                            Future.delayed(const Duration(milliseconds: 50), () {
                              ref
                                  .read(navigationProvider.notifier)
                                  .navigate(AppRoutes.flashcard);
                            });
                          },
                        ),

                      const SizedBox(height: AppSpacing.sectionGap),

                      // ── Bài học (HSK Levels) ──
                      HanzifySectionHeader(
                        title: 'Từ vựng',
                        emoji: '📚',
                        trailing: TextButton(
                          onPressed: () => ref
                              .read(navigationProvider.notifier)
                              .navigate(AppRoutes.vocabList),
                          child: const Text('Xem tất cả'),
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: 6,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final hskLevel = index + 1;
                            final vocabs = totalVocabAsync.asData?.value ?? [];
                            final levelCount = vocabs
                                .where((v) => v.level == hskLevel)
                                .length;
                            final isActive = levelCount > 0;
                            final levelColor =
                                c.hskColors[index % c.hskColors.length];
                            final levelMastered = vocabs
                                .where(
                                  (v) => v.level == hskLevel && v.isMastered,
                                )
                                .length;
                            final levelProgress = levelCount > 0
                                ? levelMastered / levelCount
                                : 0.0;

                            return _HskCard(
                              level: hskLevel,
                              count: levelCount,
                              isActive: isActive,
                              color: levelColor,
                              progress: levelProgress,
                              emoji: _hskEmojis[index],
                              cs: cs,
                              onTap: isActive
                                  ? () => ref
                                        .read(navigationProvider.notifier)
                                        .navigate(
                                          AppRoutes.vocabList,
                                          arg: hskLevel.toString(),
                                        )
                                  : null,
                            );
                          },
                        ),
                      ),

                      // ── Ôn tập nhanh ──
                      if (dueVocabs.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sectionGap),
                        HanzifySectionHeader(
                          title: 'Ôn tập nhanh',
                          emoji: '⚡',
                          trailing: TextButton(
                            onPressed: () {
                              HanzifyHaptic.action();
                              ref
                                  .read(navigationProvider.notifier)
                                  .navigate(AppRoutes.flashcard);
                            },
                            child: const Text('Bắt đầu'),
                          ),
                        ),
                        ...dueVocabs.take(3).map(
                              (vocab) => Padding(
                                key: ValueKey('due_row_${vocab.id}'),
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: _DueVocabRow(
                                  vocab: vocab,
                                  showPinyin: showPinyin,
                                  cs: cs,
                                  theme: theme,
                                ),
                              ),
                            ),
                      ],

                      const SizedBox(height: AppSpacing.sectionGap),

                      // ── Ngữ pháp ──
                      _GrammarSection(
                        cs: cs,
                        theme: theme,
                        ref: ref,
                      ),

                      const SizedBox(height: AppSpacing.sectionGap),

                      // ── Hội thoại ──
                      HanzifySectionHeader(
                        title: 'Hội thoại',
                        emoji: '💬',
                        trailing: TextButton(
                          onPressed: () {
                            HanzifyHaptic.action();
                            ref
                                .read(navigationProvider.notifier)
                                .navigate(AppRoutes.conversation);
                          },
                          child: const Text('Xem tất cả'),
                        ),
                      ),
                      _ConversationPreview(
                        cs: cs,
                        theme: theme,
                        ref: ref,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Speed Dial Menu — Simplified Material Menu
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Hero Zone — Gradient Banner
// ─────────────────────────────────────────────────────────────────────────────
class _HeroZone extends StatelessWidget {
  final double progress;
  final int doneCount;
  final int totalCount;
  final int dueCount;

  const _HeroZone({
    required this.progress,
    required this.doneCount,
    required this.totalCount,
    required this.dueCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return HanzifyCard(
      variant: HanzifyCardVariant.gradient,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: HanzifyProgressRing(
              progress: progress,
              color: cs.onPrimary,
              strokeWidth: 6,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến độ học tập',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
                Text(
                  'Đã học $doneCount/$totalCount từ vựng',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                if (dueCount > 0) ...[
                  const SizedBox(height: 10),
                  Badge(
                    label: Text('⏰ $dueCount từ cần ôn tập'),
                    backgroundColor: cs.onPrimary.withValues(alpha: 0.16),
                    textColor: cs.onPrimary,
                    largeSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Study Now CTA
// ─────────────────────────────────────────────────────────────────────────────
class _StudyNowCard extends StatelessWidget {
  final int dueCount;
  final VoidCallback onTap;

  const _StudyNowCard({super.key, required this.dueCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      color: cs.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.secondary,
                foregroundColor: cs.onSecondary,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Học ngay',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dueCount từ đang đợi bạn!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSecondaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_rounded,
                color: cs.onSecondaryContainer,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HSK Card — Larger with Emoji
// ─────────────────────────────────────────────────────────────────────────────
class _HskCard extends StatelessWidget {
  final int level;
  final int count;
  final bool isActive;
  final Color color;
  final double progress;
  final String emoji;
  final ColorScheme cs;
  final VoidCallback? onTap;

  const _HskCard({
    required this.level,
    required this.count,
    required this.isActive,
    required this.color,
    required this.progress,
    required this.emoji,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = isActive ? color : cs.surfaceContainerLow;
    final foregroundColor = isActive ? cs.onPrimary : cs.onSurface;
    final secondaryTextColor = isActive
        ? cs.onPrimary.withValues(alpha: 0.85)
        : cs.onSurfaceVariant;
    final progressColor = isActive ? cs.onPrimary : cs.primary;

    return SizedBox(
      width: 140,
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: cardColor,
        elevation: isActive ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isActive
              ? BorderSide(color: color.withValues(alpha: 0.28), width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      emoji,
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (!isActive)
                      Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  'HSK $level',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: foregroundColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? '$count từ' : 'Chưa mở',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                if (isActive)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: progressColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor,
                      ),
                      minHeight: 4,
                    ),
                  )
                else
                  const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Due Vocab Row — unchanged logic, cleaner style
// ─────────────────────────────────────────────────────────────────────────────
class _DueVocabRow extends StatelessWidget {
  final Vocab vocab;
  final bool showPinyin;
  final ColorScheme cs;
  final ThemeData theme;

  const _DueVocabRow({
    required this.vocab,
    required this.showPinyin,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return HanzifyCard(
      onTap: () => navigateTo(context, AppRoutes.vocabDetail, arg: vocab),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: cs.primaryContainer,
          child: Text(
            vocab.hanzi,
            style: AppTypography.hanziUi(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          vocab.primaryMeaningVi,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: showPinyin
            ? Text(
                vocab.pinyin,
                style: theme.textTheme.labelMedium?.copyWith(color: cs.primary),
              )
            : null,
        trailing: Icon(Icons.refresh_rounded, size: 16, color: cs.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversation Preview
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationPreview extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  final WidgetRef ref;

  const _ConversationPreview({
    required this.cs,
    required this.theme,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationListProvider);
    final convs = conversationAsync.asData?.value.take(3).toList() ?? [];

    if (convs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: convs
          .map(
            (conv) => HanzifyCard(
              onTap: () {
                HanzifyHaptic.tap();
                navigateTo(
                  context,
                  AppRoutes.conversationDetail,
                  arg: conv,
                );
              },
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.tertiaryContainer,
                  foregroundColor: cs.onTertiaryContainer,
                  child: Text(
                    conv.icon,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                title: Text(
                  conv.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  conv.description,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grammar Section
// ─────────────────────────────────────────────────────────────────────────────
class _GrammarSection extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  final WidgetRef ref;

  const _GrammarSection({
    required this.cs,
    required this.theme,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(grammarListProvider);
    final total = statsAsync.asData?.value.length ?? 0;
    final mastered =
        statsAsync.asData?.value.where((g) => g.isMastered).length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HanzifySectionHeader(
          title: 'Ngữ pháp',
          emoji: '📖',
          trailing: TextButton(
            onPressed: () => ref
                .read(navigationProvider.notifier)
                .navigate(AppRoutes.grammar),
            child: const Text('Xem tất cả'),
          ),
        ),
        HanzifyCard(
          onTap: () =>
              ref.read(navigationProvider.notifier).navigate(AppRoutes.grammar),
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.secondaryContainer,
                child: Icon(Icons.menu_book, color: cs.onSecondaryContainer),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Điểm ngữ pháp',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Đã nắm vững $mastered/$total điểm ngữ pháp',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: total > 0 ? mastered / total : 0,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
