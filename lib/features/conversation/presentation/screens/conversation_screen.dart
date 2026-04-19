import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/widgets/hanzify_icon_avatar.dart';
import 'package:hanzify/features/conversation/domain/entities/conversation_context.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';
import 'conversation_detail_screen.dart';


// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _searchController = TextEditingController();
  int _selectedLevel = 1;
  late PageController _heroPageController;
  Timer? _heroTimer;
  int _currentHeroPage = 0;

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController();
    _startHeroTimer();
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_heroPageController.hasClients) {
        _currentHeroPage++;
        _heroPageController.animateToPage(
          _currentHeroPage % 3,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _heroTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOfRef(ref);
    final conversationListAsync = ref.watch(conversationListProvider);
    final isSearching = ref.watch(conversationSearchQueryProvider).isNotEmpty;

    final allConversations = conversationListAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <ConversationContext>[],
    );

    final filteredList = isSearching
        ? allConversations
        : allConversations.where((conv) {
            if (_selectedLevel == 3) return conv.level >= 3;
            return conv.level == _selectedLevel;
          }).toList();

    return Scaffold(
      backgroundColor: c.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: c.background,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.glassSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: c.text),
                ),
                onPressed: () => ref
                    .read(navigationProvider.notifier)
                    .navigate(AppRoutes.home),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                centerTitle: false,
                title: innerBoxIsScrolled
                    ? Text(
                        'Hội thoại',
                        style: AppTypography.headline(
                          fontSize: AppFontSizes.headlineSm,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      )
                    : null,
                background: _buildHeroSlide(c, allConversations),
              ),
            ),
            SliverAppBar(
              pinned: true,
              backgroundColor: c.background,
              elevation: 0,
              toolbarHeight: 0,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isSearching ? 90 : 156),
                child: Container(
                  color: c.background,
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSearchBar(c),
                      if (!isSearching) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildHskTabs(c),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: conversationListAsync.isLoading && allConversations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  if (filteredList.isEmpty && isSearching)
                    const SliverFillRemaining(
                      child: HanzifyEmptyState.searchNoResults(),
                    )
                  else if (filteredList.isEmpty)
                    SliverFillRemaining(
                      child: _buildNoDataState(c),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          _buildConversationList(c, filteredList),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.scrollBottom),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Tabs ────────────────────────────────────────────────────────────────

  Widget _buildHskTabs(AppThemeColors c) {
    final tabs = [
      (1, 'HSK 1', 'C\u0103n b\u1EA3n'),
      (2, 'HSK 2', 'Trung c\u1EA5p'),
      (3, 'HSK 3+', 'N\u00E2ng cao'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: tabs.map((t) {
          final isSelected = _selectedLevel == t.$1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: t.$1 == 3 ? 0 : AppSpacing.sm,
              ),
              child: GestureDetector(
                onTap: () {
                  HanzifyHaptic.select();
                  setState(() => _selectedLevel = t.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? c.primary : c.glassSurface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(
                      color: isSelected ? c.primary : c.glassBorder,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: c.primary.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        t.$2,
                        style: AppTypography.label(
                          fontSize: AppFontSizes.labelMd,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? c.onPrimary : c.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.$3,
                        style: AppTypography.label(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? c.onPrimary.withValues(alpha: 0.8)
                              : c.placeholder,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Conversation List ───────────────────────────────────────────────────

  List<Widget> _buildConversationList(
    AppThemeColors c,
    List<ConversationContext> conversations,
  ) {
    return conversations.map((conv) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: _ConversationCard(
          conversation: conv,
          colors: c,
          onTap: () {
            HanzifyHaptic.tap();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConversationDetailScreen(conversation: conv),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildNoDataState(AppThemeColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: c.placeholder.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ch\u01B0a c\u00F3 b\u00E0i h\u1ED9i tho\u1EA1i cho c\u1EA5p \u0111\u1ED9 n\u00E0y',
            style: AppTypography.body(color: c.placeholder),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(AppThemeColors c, List<ConversationContext> conversations) {
    if (conversations.isEmpty) return const SizedBox.shrink();
    
    // Pick 3 random conversations for the hero slide
    final heroItems = (conversations.toList()..shuffle()).take(3).toList();
    
    return PageView.builder(
      controller: _heroPageController,
      itemCount: heroItems.length,
      onPageChanged: (index) => _currentHeroPage = index,
      itemBuilder: (context, index) {
        final conv = heroItems[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: BoxDecoration(gradient: c.accentGradient)),
            // Violet glow orb
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      c.secondary.withValues(alpha: 0.35),
                      c.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(
                      'CHỦ ĐỀ GỢI Ý',
                      style: AppTypography.label(
                        fontSize: AppFontSizes.labelSm,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    conv.title,
                    style: AppTypography.headline(
                      fontSize: AppFontSizes.headlineMd,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    conv.description,
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodyMd,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ConversationDetailScreen(conversation: conv)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: c.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
                      elevation: 0,
                    ),
                    child: const Text('Học ngay'),
                  ),
                  const SizedBox(height: 40), // Space for indicator
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar(AppThemeColors c) {
    final query = ref.watch(conversationSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: c.glassSurface,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: c.glassBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: c.placeholder),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => ref.read(conversationSearchQueryProvider.notifier).set(val.trim()),
                style: AppTypography.body(
                    fontSize: AppFontSizes.bodyMd, color: c.text),
                decoration: InputDecoration(
                  hintText: 'Tìm bài hội thoại...',
                  hintStyle: AppTypography.body(
                    fontSize: AppFontSizes.bodyMd,
                    color: c.placeholder,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            if (query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  ref
                      .read(conversationSearchQueryProvider.notifier)
                      .set('');
                },
                child: Icon(Icons.close_rounded,
                    size: 18, color: c.placeholder),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conversation card — icon + title + description + category badge
// ---------------------------------------------------------------------------

class _ConversationCard extends StatelessWidget {
  final ConversationContext conversation;
  final AppThemeColors colors;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HanzifyCard(
      variant: HanzifyCardVariant.glass,
      borderRadius: AppRadii.xxl,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          HanzifyIconAvatar.emoji(
            emoji: conversation.icon,
            backgroundColor: colors.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(width: AppSpacing.md),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.title,
                        style: AppTypography.label(
                          fontSize: AppFontSizes.titleSm,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (conversation.isMastered)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: Icon(Icons.check_circle_rounded,
                            size: 16, color: colors.success),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  conversation.titleZh,
                  style: AppTypography.hanziUi(
                    fontSize: AppFontSizes.bodySm,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conversation.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    fontSize: AppFontSizes.bodySm,
                    color: colors.placeholder,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Lines count
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: colors.surfaceLow,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(
              '${conversation.lines.length} câu',
              style: AppTypography.label(
                fontSize: AppFontSizes.labelSm,
                color: colors.placeholder,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right_rounded, size: 20, color: colors.disabled),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------


