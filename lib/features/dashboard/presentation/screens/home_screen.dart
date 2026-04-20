import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';
import 'package:hanzify/core/widgets/hanzify_progress_ring.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/vocab/presentation/screens/vocab_detail_screen.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _weekdays = ['CHỦ NHẬT', 'THỨ HAI', 'THỨ BA', 'THỨ TƯ', 'THỨ NĂM', 'THỨ SÁU', 'THỨ BẢY'];
  static const _months = ['', 'THÁNG 1', 'THÁNG 2', 'THÁNG 3', 'THÁNG 4', 'THÁNG 5', 'THÁNG 6', 'THÁNG 7', 'THÁNG 8', 'THÁNG 9', 'THÁNG 10', 'THÁNG 11', 'THÁNG 12'];
  static const _hskEmojis = ['🌱', '🌿', '🌳', '🔥', '💎', '⭐'];

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = themeColorsOf(context);
    final totalVocabAsync = ref.watch(allVocabProvider);
    final dueVocabAsync = ref.watch(dueVocabProvider);
    final showPinyin = ref.watch(showPinyinProvider);

    final totalCount = totalVocabAsync.asData?.value.length ?? 0;
    final dueVocabs = dueVocabAsync.asData?.value ?? <Vocab>[];
    final dueCount = dueVocabs.length;
    final doneCount = (totalCount - dueCount).clamp(0, totalCount);
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const HanzifyScreenHeader(title: 'Hanzify'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // ── Greeting ──
                  Text(_formattedDate(), style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  Text(_greeting(), style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, color: cs.onSurface)),

                  const SizedBox(height: AppSpacing.subsectionGap),

                  // ── Hero Zone (Gradient Banner) ──
                  _HeroZone(cs: cs, c: c, theme: theme, progress: progress, doneCount: doneCount, totalCount: totalCount, dueCount: dueCount),

                  const SizedBox(height: AppSpacing.cardListGap),

                  // ── Study Now CTA ──
                  if (dueCount > 0)
                    _StudyNowCard(dueCount: dueCount, cs: cs, c: c, theme: theme, onTap: () {
                      HanzifyHaptic.action();
                      ref.read(navigationProvider.notifier).navigate(AppRoutes.flashcard);
                    }),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // ── Bài học (HSK Levels) ──
                  HanzifySectionHeader(
                    title: 'Bài học',
                    emoji: '📚',
                    trailing: TextButton(
                      onPressed: () => ref.read(navigationProvider.notifier).navigate(AppRoutes.vocabList),
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 6,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final hskLevel = index + 1;
                        final vocabs = totalVocabAsync.asData?.value ?? [];
                        final levelCount = vocabs.where((v) => v.level == hskLevel).length;
                        final isActive = levelCount > 0;
                        final levelColor = c.hskColors[index % c.hskColors.length];
                        final levelMastered = vocabs.where((v) => v.level == hskLevel && v.isMastered).length;
                        final levelProgress = levelCount > 0 ? levelMastered / levelCount : 0.0;

                        return _HskCard(
                          level: hskLevel,
                          count: levelCount,
                          isActive: isActive,
                          color: levelColor,
                          progress: levelProgress,
                          emoji: _hskEmojis[index],
                          cs: cs,
                          onTap: isActive
                              ? () => ref.read(navigationProvider.notifier).navigate(AppRoutes.vocabList, arg: hskLevel.toString())
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
                          ref.read(navigationProvider.notifier).navigate(AppRoutes.flashcard);
                        },
                        child: const Text('Bắt đầu'),
                      ),
                    ),
                    ...dueVocabs.take(3).map((vocab) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: _DueVocabRow(vocab: vocab, showPinyin: showPinyin, cs: cs, theme: theme),
                        )),
                  ],

                  const SizedBox(height: AppSpacing.sectionGap),

                  // ── Ngữ pháp ──
                  _GrammarSection(cs: cs, theme: theme, ref: ref),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // ── Hội thoại ──
                  HanzifySectionHeader(
                    title: 'Hội thoại',
                    emoji: '💬',
                    trailing: TextButton(
                      onPressed: () {
                        HanzifyHaptic.action();
                        ref.read(navigationProvider.notifier).navigate(AppRoutes.conversation);
                      },
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  _ConversationPreview(cs: cs, theme: theme, ref: ref),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          HanzifyHaptic.action();
          ref.read(navigationProvider.notifier).navigate(AppRoutes.flashcard);
        },
        child: const Icon(Icons.bolt_rounded),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Zone — Gradient Banner
// ─────────────────────────────────────────────────────────────────────────────
class _HeroZone extends StatelessWidget {
  final ColorScheme cs;
  final AppThemeColors c;
  final ThemeData theme;
  final double progress;
  final int doneCount;
  final int totalCount;
  final int dueCount;

  const _HeroZone({required this.cs, required this.c, required this.theme, required this.progress, required this.doneCount, required this.totalCount, required this.dueCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.tertiary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Progress Ring
            SizedBox(
              width: 80,
              height: 80,
              child: HanzifyProgressRing(
                progress: progress,
                color: Colors.white,
                strokeWidth: 6,
              ),
            ),
            const SizedBox(width: 20),
            // Text content
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
                  const SizedBox(height: 4),
                  Text(
                    'Hoàn thành $doneCount/$totalCount từ vựng',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  if (dueCount > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⏰ $dueCount từ cần ôn tập',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Study Now CTA — Gradient Card
// ─────────────────────────────────────────────────────────────────────────────
class _StudyNowCard extends StatelessWidget {
  final int dueCount;
  final ColorScheme cs;
  final AppThemeColors c;
  final ThemeData theme;
  final VoidCallback onTap;

  const _StudyNowCard({required this.dueCount, required this.cs, required this.c, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [cs.secondary, cs.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Học ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                      Text('$dueCount từ đang đợi bạn!', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
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

  const _HskCard({required this.level, required this.count, required this.isActive, required this.color, required this.progress, required this.emoji, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 140,
      decoration: BoxDecoration(
        color: isActive ? color : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: color.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: isActive
            ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
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
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    if (!isActive) Icon(Icons.lock_rounded, size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
                const Spacer(),
                Text(
                  'HSK $level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? '$count từ' : 'Chưa mở',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.white.withValues(alpha: 0.85) : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                if (isActive)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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

  const _DueVocabRow({required this.vocab, required this.showPinyin, required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          HanzifyHaptic.tap();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => VocabDetailScreen(vocab: vocab)));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(vocab.hanzi, style: AppTypography.hanziUi(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showPinyin) Text(vocab.pinyin, style: TextStyle(fontSize: 12, color: cs.primary)),
                    Text(vocab.primaryMeaningVi, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.refresh_rounded, size: 16, color: cs.primary),
              ),
            ],
          ),
        ),
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

  const _ConversationPreview({required this.cs, required this.theme, required this.ref});

  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationListProvider);
    final convs = conversationAsync.asData?.value.take(3).toList() ?? [];

    if (convs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: convs.map((conv) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card.filled(
            color: cs.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                HanzifyHaptic.tap();
                ref.read(navigationProvider.notifier).navigate(AppRoutes.conversation);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(conv.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(conv.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(conv.description, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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

  const _GrammarSection({required this.cs, required this.theme, required this.ref});

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(grammarListProvider);
    final total = statsAsync.asData?.value.length ?? 0;
    final mastered = statsAsync.asData?.value.where((g) => g.isMastered).length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HanzifySectionHeader(
          title: 'Ngữ pháp',
          emoji: '📖',
          trailing: TextButton(
            onPressed: () => ref.read(navigationProvider.notifier).navigate(AppRoutes.grammar),
            child: const Text('Xem tất cả'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card.filled(
            color: cs.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () => ref.read(navigationProvider.notifier).navigate(AppRoutes.grammar),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: cs.secondaryContainer, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(Icons.menu_book, color: cs.onSecondaryContainer),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Điểm ngữ pháp', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Đã nắm vững $mastered/$total điểm ngữ pháp', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: total > 0 ? mastered / total : 0, borderRadius: BorderRadius.circular(4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
