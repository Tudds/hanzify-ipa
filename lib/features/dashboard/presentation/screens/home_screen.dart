import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/hanzify_theme_toggle.dart';
import 'package:hanzify/core/widgets/hanzify_gradient_fab.dart';
import 'package:hanzify/core/widgets/hanzify_icon_avatar.dart';
import 'package:hanzify/core/widgets/hanzify_progress_ring.dart';
import 'package:hanzify/core/widgets/hanzify_streak_badge.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _visible = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  static const _weekdays = [
    'CHỦ NHẬT', 'THỨ HAI', 'THỨ BA', 'THỨ TƯ', 'THỨ NĂM', 'THỨ SÁU', 'THỨ BẢY'
  ];
  static const _months = [
    '', 'THÁNG 1', 'THÁNG 2', 'THÁNG 3', 'THÁNG 4', 'THÁNG 5', 'THÁNG 6',
    'THÁNG 7', 'THÁNG 8', 'THÁNG 9', 'THÁNG 10', 'THÁNG 11', 'THÁNG 12',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          setState(() => _visible = true);
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      backgroundColor: c.background,
      extendBody: true,
      body: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: AppDurations.fast,
        curve: AppCurves.enter,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _AppHeader(
              colors: c,
              isSearching: _isSearching,
              innerBoxIsScrolled: innerBoxIsScrolled,
              searchController: _searchController,
              onToggleSearch: () => setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              }),
              onProfileTap: () => ref
                  .read(navigationProvider.notifier)
                  .navigate(AppRoutes.profile),
              onSearchSubmit: () => ref
                  .read(navigationProvider.notifier)
                  .navigate(AppRoutes.vocabList),
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Greeting ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formattedDate(),
                        style: AppTypography.label(
                          fontSize: AppFontSizes.labelSm,
                          color: c.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _greeting(),
                        style: AppTypography.headline(
                          fontSize: AppFontSizes.headlineLg,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Hero zone: ring + streak + stats ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: _HeroZone(
                    colors: c,
                    progress: progress,
                    doneCount: doneCount,
                    totalCount: totalCount,
                    dueCount: dueCount,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── "Học hôm nay" action card ──────────────────────────────
                if (dueCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: _StudyNowCard(
                      dueCount: dueCount,
                      colors: c,
                      onTap: () {
                        HanzifyHaptic.action();
                        ref.read(navigationProvider.notifier).navigate(AppRoutes.flashcard);
                      },
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl),

                // ── HSK level carousel ────────────────────────────────────
                HanzifySectionHeader(
                  title: 'Bài học',
                  emoji: '📚',
                  trailing: GestureDetector(
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .navigate(AppRoutes.vocabList),
                    child: Text('Xem tất cả',
                        style: AppTypography.label(
                            fontSize: AppFontSizes.labelMd, color: c.primary)),
                  ),
                ),
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: 6,
                    separatorBuilder: (ctx, i) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final hskLevel = index + 1;
                      final vocabs = totalVocabAsync.asData?.value ?? [];
                      final levelCount =
                          vocabs.where((v) => v.level == hskLevel).length;
                      final isActive = levelCount > 0;
                      final levelColor = c.hskColors[index % c.hskColors.length];

                      return _HskCard(
                        level: hskLevel,
                        count: levelCount,
                        isActive: isActive,
                        color: levelColor,
                        progress: progress,
                        colors: c,
                        onTap: isActive
                            ? () => ref
                                .read(navigationProvider.notifier)
                                .navigate(AppRoutes.vocabList,
                                    arg: hskLevel.toString())
                            : null,
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── Quick review (due vocab preview) ─────────────────────
                if (dueVocabs.isNotEmpty) ...[
                  HanzifySectionHeader(
                    title: 'Ôn tập nhanh',
                    emoji: '⚡',
                    trailing: GestureDetector(
                      onTap: () {
                        HanzifyHaptic.action();
                        ref.read(navigationProvider.notifier).navigate(AppRoutes.flashcard);
                      },
                      child: Text('Bắt đầu',
                          style: AppTypography.label(
                              fontSize: AppFontSizes.labelMd, color: c.primary)),
                    ),
                  ),
                  ...dueVocabs.take(3).map(
                    (vocab) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                      child: _DueVocabRow(vocab: vocab, showPinyin: showPinyin, colors: c),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // ── Grammar ──────────────────────────────────────────────
                _GrammarSection(colors: c, ref: ref),

                // ── Conversations ─────────────────────────────────────────
                HanzifySectionHeader(
                  title: 'Hội thoại',
                  emoji: '💬',
                  trailing: GestureDetector(
                    onTap: () {
                      HanzifyHaptic.action();
                      ref.read(navigationProvider.notifier).navigate(AppRoutes.conversation);
                    },
                    child: Text('Xem tất cả',
                        style: AppTypography.label(
                            fontSize: AppFontSizes.labelMd, color: c.primary)),
                  ),
                ),
                _ConversationPreview(colors: c, ref: ref),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: HanzifyGradientFab(
        icon: Icons.bolt_rounded,
        onTap: () {
          HanzifyHaptic.action();
          ref.read(navigationProvider.notifier).navigate(AppRoutes.flashcard);
        },
      ),
    );
  }
}

// ── App header (SliverAppBar) ─────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  final AppThemeColors colors;
  final bool isSearching;
  final bool innerBoxIsScrolled;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;
  final VoidCallback onProfileTap;
  final VoidCallback onSearchSubmit;

  const _AppHeader({
    required this.colors,
    required this.isSearching,
    required this.innerBoxIsScrolled,
    required this.searchController,
    required this.onToggleSearch,
    required this.onProfileTap,
    required this.onSearchSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return SliverAppBar(
      expandedHeight: isSearching ? 180 : 120,
      pinned: true,
      floating: true,
      backgroundColor: innerBoxIsScrolled
          ? c.background.withValues(alpha: 0.92)
          : Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: (innerBoxIsScrolled && !isSearching)
          ? Text(
              'Hanzify',
              style: AppTypography.headline(
                fontSize: AppFontSizes.headlineSm,
                fontWeight: FontWeight.w900,
                color: c.primary,
                letterSpacing: -0.3,
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isSearching)
                      Text(
                        'Hanzify',
                        style: AppTypography.headline(
                          fontSize: AppFontSizes.displaySm,
                          fontWeight: FontWeight.w900,
                          color: c.primary,
                          letterSpacing: -1.2,
                        ),
                      ),
                    const Spacer(),
                    _IconBtn(
                      colors: c,
                      active: isSearching,
                      icon: isSearching
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      onTap: () {
                        HanzifyHaptic.action();
                        onToggleSearch();
                      },
                    ),
                    const SizedBox(width: AppSpacing.md),
                    HanzifyThemeToggle(),
                    const SizedBox(width: AppSpacing.md),
                    GestureDetector(
                      onTap: () {
                        HanzifyHaptic.action();
                        onProfileTap();
                      },
                      child: HanzifyIconAvatar.person(
                        size: HanzifyAvatarSize.md,
                        colors: c,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSearching)
                AnimatedOpacity(
                  opacity: isSearching ? 1.0 : 0.0,
                  duration: AppDurations.fast,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      onSubmitted: (_) => onSearchSubmit(),
                      style: AppTypography.body(color: c.text),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm Hán tự...',
                        hintStyle: AppTypography.body(color: c.placeholder),
                        prefixIcon:
                            Icon(Icons.search_rounded, color: c.primary),
                        filled: true,
                        fillColor: c.glassSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          borderSide: BorderSide(color: c.glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          borderSide: BorderSide(color: c.glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          borderSide:
                              BorderSide(color: c.primary, width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
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

// ── Hero zone ─────────────────────────────────────────────────────────────────

class _HeroZone extends StatelessWidget {
  final AppThemeColors colors;
  final double progress;
  final int doneCount;
  final int totalCount;
  final int dueCount;

  const _HeroZone({
    required this.colors,
    required this.progress,
    required this.doneCount,
    required this.totalCount,
    required this.dueCount,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: c.glassSurface,
        borderRadius: BorderRadius.circular(AppRadii.xxxl),
        border: Border.all(color: c.glassBorder),
        boxShadow: c.cardShadow,
      ),
      child: Row(
        children: [
          // Progress ring
          HanzifyProgressRing(
            progress: progress,
            size: 96,
            strokeWidth: 8,
            color: c.primary,
            label: '$pct%',
            sublabel: 'xong',
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'MỤC TIÊU HÔM NAY',
                      style: AppTypography.sectionTitle(color: c.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    HanzifyStreakBadge(count: 0, compact: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dueCount > 0 ? 'Còn $dueCount từ nữa' : 'Đã hoàn thành! 🎉',
                  style: AppTypography.headline(
                    fontSize: AppFontSizes.titleLg,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  totalCount > 0
                      ? '$doneCount / $totalCount đã học'
                      : 'Bắt đầu hành trình',
                  style: AppTypography.body(
                    fontSize: AppFontSizes.bodySm,
                    color: c.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Study now card ────────────────────────────────────────────────────────────

class _StudyNowCard extends StatelessWidget {
  final int dueCount;
  final AppThemeColors colors;
  final VoidCallback onTap;

  const _StudyNowCard({
    required this.dueCount,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return HanzifyCard(
      color: c.primary.withValues(alpha: 0.06),
      borderRadius: AppRadii.xxl,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Icon(Icons.local_fire_department_rounded,
                color: c.primary, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ôn tập hôm nay',
                  style: AppTypography.body(
                    fontSize: AppFontSizes.bodyLg,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                Text(
                  '$dueCount thẻ đang chờ',
                  style: AppTypography.body(
                      fontSize: AppFontSizes.bodySm, color: c.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              'Bắt đầu',
              style: AppTypography.label(
                fontSize: AppFontSizes.labelMd,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── HSK card ──────────────────────────────────────────────────────────────────

class _HskCard extends StatelessWidget {
  final int level;
  final int count;
  final bool isActive;
  final Color color;
  final double progress;
  final AppThemeColors colors;
  final VoidCallback? onTap;

  const _HskCard({
    required this.level,
    required this.count,
    required this.isActive,
    required this.color,
    required this.progress,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 120,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [color, c.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : c.glassSurface,
          border: Border.all(
            color: isActive ? Colors.transparent : c.glassBorder,
          ),
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HSK $level',
                  style: AppTypography.headline(
                    fontSize: AppFontSizes.titleMd,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : c.text,
                  ),
                ),
                if (!isActive)
                  Icon(Icons.lock_rounded, size: 14, color: c.placeholder),
              ],
            ),
            Text(
              isActive ? '$count từ' : 'Chưa mở',
              style: AppTypography.body(
                fontSize: AppFontSizes.bodySm,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.88)
                    : c.placeholder,
              ),
            ),
            if (isActive)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── Due vocab row (quick review) ──────────────────────────────────────────────

class _DueVocabRow extends StatelessWidget {
  final Vocab vocab;
  final bool showPinyin;
  final AppThemeColors colors;

  const _DueVocabRow({
    required this.vocab,
    required this.showPinyin,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return HanzifyCard(
      variant: HanzifyCardVariant.outlined,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          // Hanzi
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.studyDue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Text(
              vocab.hanzi,
              style: AppTypography.hanziUi(
                fontSize: AppFontSizes.headlineSm,
                fontWeight: FontWeight.w700,
                color: c.studyDue,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showPinyin)
                  Text(
                    vocab.pinyin,
                    style: AppTypography.pinyin(
                        fontSize: AppFontSizes.bodySm, color: c.primary),
                  ),
                Text(
                  vocab.primaryMeaningVi,
                  style: AppTypography.body(
                    fontSize: AppFontSizes.bodyMd,
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.refresh_rounded, size: 18, color: c.studyDue),
        ],
      ),
    );
  }
}

// ── Conversation preview ──────────────────────────────────────────────────────

class _ConversationPreview extends StatelessWidget {
  final AppThemeColors colors;
  final WidgetRef ref;

  const _ConversationPreview({required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final conversationAsync = ref.watch(conversationListProvider);
    final convs = conversationAsync.asData?.value.take(3).toList() ?? [];

    if (convs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        child: Text(
          'Chưa có bài hội thoại',
          style: AppTypography.body(
              fontSize: AppFontSizes.bodyMd, color: c.placeholder),
        ),
      );
    }

    return Column(
      children: convs.map((conv) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
          child: HanzifyCard(
            variant: HanzifyCardVariant.glass,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            onTap: () {
              HanzifyHaptic.tap();
              ref.read(navigationProvider.notifier).navigate(AppRoutes.conversation);
            },
            child: Row(
              children: [
                HanzifyIconAvatar.emoji(
                  emoji: conv.icon,
                  backgroundColor: c.primary.withValues(alpha: 0.12),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.title,
                        style: AppTypography.body(
                          fontSize: AppFontSizes.bodyLg,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                      Text(
                        conv.description,
                        style: AppTypography.body(
                            fontSize: AppFontSizes.bodySm,
                            color: c.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: c.placeholder, size: 24),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Grammar section ───────────────────────────────────────────────────────────

class _GrammarSection extends StatelessWidget {
  final AppThemeColors colors;
  final WidgetRef ref;

  const _GrammarSection({required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final statsAsync = ref.watch(grammarListProvider);
    final total = statsAsync.asData?.value.length ?? 0;
    final mastered = statsAsync.asData?.value.where((g) => g.isMastered).length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HanzifySectionHeader(
          title: 'Ngữ pháp',
          emoji: '📖',
          trailing: GestureDetector(
            onTap: () {
              HanzifyHaptic.action();
              ref.read(navigationProvider.notifier).navigate(AppRoutes.grammar);
            },
            child: Text(
              'Xem tất cả',
              style: AppTypography.label(
                  fontSize: AppFontSizes.labelMd, color: c.primary),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: HanzifyCard(
            variant: HanzifyCardVariant.glass,
            padding: const EdgeInsets.all(AppSpacing.xl),
            onTap: () {
              HanzifyHaptic.action();
              ref.read(navigationProvider.notifier).navigate(AppRoutes.grammar);
            },
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: c.accentGradient,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    boxShadow: [
                      BoxShadow(
                        color: c.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '把',
                    style: AppTypography.hanziUi(
                      fontSize: AppFontSizes.headlineSm,
                      fontWeight: FontWeight.w800,
                      color: c.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cấu trúc ngữ pháp',
                        style: AppTypography.body(
                          fontSize: AppFontSizes.bodyLg,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total > 0
                            ? '$mastered / $total điểm đã thành thạo'
                            : 'Khám phá quy tắc ngôn ngữ',
                        style: AppTypography.body(
                          fontSize: AppFontSizes.bodySm,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.placeholder, size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final AppThemeColors colors;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({
    required this.colors,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.enter,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? c.primary.withValues(alpha: 0.12)
              : c.glassSurface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: c.glassBorder),
        ),
        child: Icon(
          icon,
          color: active ? c.primary : c.primary,
          size: 22,
        ),
      ),
    );
  }
}
