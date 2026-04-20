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
                          (1, 'HSK 1', 'Căn bản'),
                          (2, 'HSK 2', 'Trung cấp'),
                          (3, 'HSK 3', 'Trung cấp'),
                          (4, 'HSK 4', 'Nâng cao'),
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
            : CustomScrollView(
                slivers: [
                  if (filteredList.isEmpty && isSearching)
                    const SliverFillRemaining(
                      child: HanzifyEmptyState.searchNoResults(),
                    )
                  else if (filteredList.isEmpty)
                    const SliverFillRemaining(
                      child: HanzifyEmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Chưa có bài hội thoại cho cấp độ này',
                      ),
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
              ),
      ),
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
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.colors,
    required this.onTap,
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
          child: Row(
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
