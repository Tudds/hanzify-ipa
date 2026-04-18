import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
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
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  static const _weekdays = ['CHỦ NHẬT', 'THỨ HAI', 'THỨ BA', 'THỨ TƯ', 'THỨ NĂM', 'THỨ SÁU', 'THỨ BẢY'];
  static const _months = [
    '', 'THÁNG 1', 'THÁNG 2', 'THÁNG 3', 'THÁNG 4', 'THÁNG 5', 'THÁNG 6',
    'THÁNG 7', 'THÁNG 8', 'THÁNG 9', 'THÁNG 10', 'THÁNG 11', 'THÁNG 12',
  ];

  String _formattedDate() {
    final now = DateTime.now();
    final weekday = _weekdays[now.weekday % 7];
    final day = now.day;
    final month = _months[now.month];
    return '$weekday, $day $month';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng!';
    if (hour < 18) return 'Chào buổi chiều!';
    return 'Chào buổi tối!';
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);

    final totalVocabAsync = ref.watch(allVocabProvider);
    final dueVocabAsync = ref.watch(dueVocabProvider);
    final showPinyin = ref.watch(showPinyinProvider);

    final totalCount = totalVocabAsync.asData?.value.length ?? 0;
    final dueCount = dueVocabAsync.asData?.value.length ?? 0;
    final doneCount = totalCount > 0 ? (totalCount - dueCount).clamp(0, totalCount) : 0;
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;
    final progressPct = (progress * 100).round();

    return Scaffold(
      backgroundColor: c.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _isSearching ? 180 : 120,
              pinned: true,
              floating: true,
              backgroundColor: c.background.withValues(alpha: 0.98),
              elevation: 0,
              centerTitle: false,
              title: (innerBoxIsScrolled && !_isSearching)
                ? Text(
                    'Hanzify',
                    style: AppTypography.headline(
                      fontSize: AppFontSizes.headlineSm,
                      fontWeight: FontWeight.w800,
                      color: c.text,
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
                            if (!_isSearching)
                              Text(
                                'Hanzify',
                                style: AppTypography.headline(
                                  fontSize: AppFontSizes.displaySm,
                                  fontWeight: FontWeight.w900,
                                  color: c.text,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            const Spacer(),
                            // Search Logo/Icon - Toggle Expandable
                            GestureDetector(
                               onTap: () {
                                HanzifyHaptic.action();
                                setState(() {
                                  _isSearching = !_isSearching;
                                  if (!_isSearching) _searchController.clear();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _isSearching ? c.primary : c.surfaceLow,
                                  borderRadius: BorderRadius.circular(AppRadii.xl),
                                ),
                                child: Icon(
                                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                                  color: _isSearching ? c.onPrimary : c.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Dark Theme Toggle
                            HanzifyThemeToggle(),
                            const SizedBox(width: AppSpacing.md),
                            // Profile Avatar
                            GestureDetector(
                              onTap: () {
                                HanzifyHaptic.action();
                                ref.read(navigationProvider.notifier).navigate(AppRoutes.profile);
                              },
                              child: HanzifyIconAvatar.person(
                                size: HanzifyAvatarSize.md,
                                colors: c,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isSearching)
                         Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onSubmitted: (val) {
                              ref.read(navigationProvider.notifier).navigate(AppRoutes.vocabList);
                               // Link to dictionary search? Or just navigate.
                               // Usually user wants to search instantly.
                            },
                            style: AppTypography.body(color: c.text),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm Hán tự...',
                              hintStyle: AppTypography.body(color: c.placeholder),
                              prefixIcon: Icon(Icons.search_rounded, color: c.primary),
                              filled: true,
                              fillColor: c.surfaceLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadii.xl),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ── 2. Greeting area ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formattedDate(),
                      style: AppTypography.label(
                        fontSize: AppFontSizes.labelSm,
                        color: c.text.withValues(alpha: 0.45),
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
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── 3. Progress card ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: HanzifyCard(
                  gradient: c.primaryGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mục tiêu hôm nay',
                        style: AppTypography.label(
                          fontSize: AppFontSizes.labelMd,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        dueCount > 0
                            ? 'Còn $dueCount từ nữa để hoàn thành'
                            : 'Đã hoàn thành tất cả!',
                        style: AppTypography.headline(
                          fontSize: AppFontSizes.titleLg,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            '$progressPct%',
                            style: AppTypography.label(
                              fontSize: AppFontSizes.titleMd,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: AppSpacing.xxl),

              // ── 4. Lessons section (BAI HOC) ───────────────────────────
              HanzifySectionHeader(
                title: 'Bài học',
                emoji: '\u{1F4DA}',
                trailing: GestureDetector(
                  onTap: () => ref.read(navigationProvider.notifier).navigate(AppRoutes.vocabList),
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelMd,
                      color: c.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: 6,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final hskLevel = index + 1;
                    final vocabs = totalVocabAsync.asData?.value ?? [];
                    final levelCount = vocabs.where((v) => v.level == hskLevel).length;
                    final isActive = levelCount > 0;

                    return GestureDetector(
                      onTap: isActive
                          ? () => ref.read(navigationProvider.notifier).navigate(AppRoutes.vocabList, arg: hskLevel.toString())
                          : null,
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: isActive ? c.primaryGradient : null,
                          color: isActive ? null : c.surfaceLow,
                          borderRadius: BorderRadius.circular(AppRadii.xxl),
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
                                  'HSK $hskLevel',
                                  style: AppTypography.label(
                                    fontSize: AppFontSizes.titleSm,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : c.text,
                                  ),
                                ),
                                if (!isActive)
                                  Icon(Icons.lock_rounded, size: 16, color: c.disabled),
                              ],
                            ),
                            Text(
                              isActive ? '$levelCount từ' : 'Chưa mở',
                              style: AppTypography.body(
                                fontSize: AppFontSizes.bodySm,
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : c.placeholder,
                              ),
                            ),
                            if (isActive)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadii.full),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(
                          delay: (80 * index).ms,
                          duration: 350.ms,
                        ).slideX(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── 5. Dialogues section (HOI THOAI) ───────────────────────
              HanzifySectionHeader(
                title: 'Hội thoại',
                emoji: '\u{1F4AC}',
                trailing: GestureDetector(
                  onTap: () {
                    HanzifyHaptic.action();
                    ref.read(navigationProvider.notifier).navigate(AppRoutes.conversation);
                  },
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelMd,
                      color: c.primary,
                    ),
                  ),
                ),
              ),
              ..._buildConversationItems(c, ref, showPinyin),

              const SizedBox(height: AppSpacing.xxl),

              // ── 6. Grammar section (NGU PHAP) ──────────────────────────
              HanzifySectionHeader(
                title: 'Ngữ pháp',
                emoji: '\u{1F4D6}',
                trailing: GestureDetector(
                  onTap: () {
                    HanzifyHaptic.action();
                    ref.read(navigationProvider.notifier).navigate(AppRoutes.grammar);
                  },
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelMd,
                      color: c.primary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(child: _buildGrammarCard(c, '\u7684', 'de', 'Trợ từ sở hữu', showPinyin, ref)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildGrammarCard(c, '\u628A', 'ba', 'Cấu trúc "ba"', showPinyin, ref)),
                  ],
                ),
              ),
            ],
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

  List<Widget> _buildConversationItems(AppThemeColors c, WidgetRef ref, bool showPinyin) {
    final conversationAsync = ref.watch(conversationListProvider);
    final conversations = conversationAsync.asData?.value ?? [];

    // Show first 3 conversations on home screen
    final displayList = conversations.take(3).toList();

    if (displayList.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          child: Text(
            'Chưa có bài hội thoại',
            style: AppTypography.body(
              fontSize: AppFontSizes.bodyMd,
              color: c.placeholder,
            ),
          ),
        ),
      ];
    }

    return displayList.map((conv) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
        child: HanzifyCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          margin: EdgeInsets.zero,
          onTap: () {
            HanzifyHaptic.tap();
            ref.read(navigationProvider.notifier).navigate(AppRoutes.conversation);
          },
          child: Row(
            children: [
              HanzifyIconAvatar.emoji(
                emoji: conv.icon,
                backgroundColor: c.primary.withValues(alpha: 0.1),
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
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                    Text(
                      conv.description,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodySm,
                        color: c.placeholder,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.disabled, size: 24),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildGrammarCard(AppThemeColors c, String hanzi, String pinyin, String subtitle, bool showPinyin, WidgetRef ref) {
    return HanzifyCard(
      onTap: () {
        HanzifyHaptic.tap();
        ref.read(navigationProvider.notifier).navigate(AppRoutes.grammar);
      },
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hanzi,
            style: AppTypography.hanziDisplay(
              fontSize: AppFontSizes.displayMd,
              color: c.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            showPinyin ? pinyin : '',
            style: AppTypography.pinyin(
              fontSize: AppFontSizes.bodySm,
              color: c.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.body(
              fontSize: AppFontSizes.bodySm,
              color: c.placeholder,
            ),
          ),
        ],
      ),
    );
  }
}
