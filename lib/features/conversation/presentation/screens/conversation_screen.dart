import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/widgets/hanzify_icon_avatar.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/features/conversation/domain/entities/conversation_context.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'conversation_detail_screen.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: cs.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => ref.read(navigationProvider.notifier).goBack(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: innerBoxIsScrolled
                    ? Text('Hội thoại', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                    : null,
                background: _buildHeroSlide(c, allConversations),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Tìm bài hội thoại...',
                      onChanged: (val) => ref.read(conversationSearchQueryProvider.notifier).set(val.trim()),
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(conversationSearchQueryProvider.notifier).set('');
                            },
                          ),
                      ],
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
                    ),
                  ),
                  if (!isSearching)
                    SizedBox(
                      height: 56,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          (0, 'Tất cả'),
                          (1, 'HSK 1'),
                          (2, 'HSK 2'),
                          (3, 'HSK 3'),
                          (4, 'HSK 4'),
                        ].map((t) {
                          final isSelected = _selectedLevel == t.$1;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(t.$2),
                              selected: isSelected,
                              onSelected: (_) {
                                HanzifyHaptic.select();
                                setState(() => _selectedLevel = t.$1);
                              },
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ];
        },
        body: conversationListAsync.isLoading && allConversations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : isSearching
                ? _buildSearchResults(filteredList, c)
                : _selectedLevel == 0
                    ? _buildCategorizedLists(allConversations, c)
                    : _buildSearchResults(filteredList, c),
      ),
    );
  }

  Widget _buildCategorizedLists(List<ConversationContext> conversations, AppThemeColors c) {
    if (conversations.isEmpty) return const SizedBox.shrink();

    // Group by category
    final grouped = <String, List<ConversationContext>>{};
    for (final conv in conversations) {
      grouped.putIfAbsent(conv.category, () => []).add(conv);
    }

    final categoryNames = {
      'greeting': 'Chào hỏi & Giao tiếp cơ bản',
      'shopping': 'Mua sắm',
      'transport': 'Giao thông & Đi lại',
      'restaurant': 'Nhà hàng & Ăn uống',
      'daily': 'Đời sống hàng ngày',
      'school': 'Trường học & Giáo dục',
      'travel': 'Du lịch',
      'phone': 'Điện thoại & Liên lạc',
      'workplace': 'Công sở & Làm việc',
    };

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final categoryKey = grouped.keys.elementAt(index);
        final categoryTitle = categoryNames[categoryKey] ?? categoryKey.toUpperCase();
        final categoryConvs = grouped[categoryKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            HanzifySectionHeader(title: categoryTitle, emoji: '💬'),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categoryConvs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  return SizedBox(
                    width: 280,
                    child: _ConversationCard(
                      conversation: categoryConvs[i],
                      colors: c,
                      isVertical: true,
                      onTap: () {
                        HanzifyHaptic.tap();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConversationDetailScreen(conversation: categoryConvs[i]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(List<ConversationContext> filteredList, AppThemeColors c) {
    return CustomScrollView(
      slivers: [
        if (filteredList.isEmpty)
          const SliverFillRemaining(
            child: HanzifyEmptyState.searchNoResults(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ConversationCard(
                    conversation: filteredList[index],
                    colors: c,
                    isVertical: false,
                    onTap: () {
                      HanzifyHaptic.tap();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConversationDetailScreen(conversation: filteredList[index]),
                        ),
                      );
                    },
                  ),
                ),
                childCount: filteredList.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildHeroSlide(AppThemeColors c, List<ConversationContext> conversations) {
    if (conversations.isEmpty) return Container(color: c.primary);
    
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
            Container(decoration: BoxDecoration(gradient: c.primaryGradient)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'CHỦ ĐỀ GỢI Ý',
                      style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    conv.title,
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conv.description,
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ConversationDetailScreen(conversation: conv)),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: c.primary,
                    ),
                    child: const Text('Học ngay'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final ConversationContext conversation;
  final AppThemeColors colors;
  final bool isVertical;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.colors,
    required this.onTap,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isVertical
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HanzifyIconAvatar.emoji(
                          emoji: conversation.icon,
                          backgroundColor: cs.primaryContainer,
                        ),
                        if (conversation.isMastered)
                          Icon(Icons.check_circle, size: 20, color: colors.success),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      conversation.titleZh,
                      style: AppTypography.hanziUi(fontSize: 16, color: cs.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                )
              : Row(
                  children: [
                    HanzifyIconAvatar.emoji(
                      emoji: conversation.icon,
                      backgroundColor: cs.primaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversation.title,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (conversation.isMastered)
                                Icon(Icons.check_circle, size: 16, color: colors.success),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            conversation.titleZh,
                            style: AppTypography.hanziUi(fontSize: 14, color: cs.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            conversation.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
                  ],
                ),
        ),
      ),
    );
  }
}
