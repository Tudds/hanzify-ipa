import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_filter_provider.dart';
import 'package:hanzify/features/vocab/presentation/widgets/vocab_card.dart';
import 'package:hanzify/core/widgets/search_bar_widget.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';

class VocabListScreen extends ConsumerStatefulWidget {
  const VocabListScreen({super.key});

  @override
  ConsumerState<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends ConsumerState<VocabListScreen> {
  late TextEditingController _searchController;

  static const _levels = [0, 1, 2, 3, 4, 5, 6];

  // Keys khớp với POS codes trong MeaningEmbedded.pos
  static const _wordTypes = [
    {'key': 'all', 'label': 'Tất cả', 'emoji': '📚'},
    {'key': 'n', 'label': 'Danh từ', 'emoji': '📦'},
    {'key': 'v', 'label': 'Động từ', 'emoji': '⚡'},
    {'key': 'adj', 'label': 'Tính từ', 'emoji': '🎨'},
    {'key': 'adv', 'label': 'Trạng từ', 'emoji': '🔄'},
    {'key': 'mw', 'label': 'Lượng từ', 'emoji': '📏'},
    {'key': 'aux', 'label': 'Trợ động', 'emoji': '✨'},
    {'key': 'prep', 'label': 'Giới từ', 'emoji': '🔗'},
    {'key': 'conj', 'label': 'Liên từ', 'emoji': '🔀'},
    {'key': 'interj', 'label': 'Thán từ', 'emoji': '❗'},
  ];

  static const _statuses = [
    {'key': 'all', 'label': 'Tất cả', 'emoji': '📋'},
    {'key': 'bookmarked', 'label': 'Đã Lưu', 'emoji': '⭐'},
    {'key': 'mastered', 'label': 'Đã Nhớ', 'emoji': '🏆'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeColorsProvider);
    final filter = ref.watch(vocabFilterProvider);
    final filteredVocabList = ref.watch(filteredVocabProvider);
    final allVocabAsync = ref.watch(allVocabProvider);

    // Sync controller with state if cleared from elsewhere
    if (filter.query.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              4,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(navigationProvider.notifier).navigate('home'),
                    child: Text(
                      '← Về',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.primary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Từ Điển',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
          ),

          // Search bar
          SearchBarWidget(
            value: filter.query,
            controller: _searchController,
            onChanged: (q) =>
                ref.read(vocabFilterProvider.notifier).setQuery(q),
            colors: c,
            placeholder: 'Tìm hanzi, pinyin hoặc nghĩa...',
          ),

          // Level chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: _levels.map((level) {
                final isActive = filter.level == level;
                return GestureDetector(
                  onTap: () =>
                      ref.read(vocabFilterProvider.notifier).setLevel(level),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? c.primary : c.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? c.primary
                            : c.disabled.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      level == 0 ? 'Tất cả' : 'HSK $level',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : c.text,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Word Type Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: _wordTypes.map((type) {
                final isActive = filter.wordType == type['key'];
                return GestureDetector(
                  onTap: () => ref
                      .read(vocabFilterProvider.notifier)
                      .setWordType(type['key']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? c.accent.withValues(alpha: 0.15)
                          : c.surfaceLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? c.accent
                            : c.disabled.withValues(alpha: 0.3),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type['emoji']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive ? c.accent : c.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Status Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: _statuses.map((status) {
                final isActive = filter.status == status['key'];
                return GestureDetector(
                  onTap: () => ref
                      .read(vocabFilterProvider.notifier)
                      .setStatus(status['key']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? c.success.withValues(alpha: 0.15)
                          : c.surfaceLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? c.success
                            : c.disabled.withValues(alpha: 0.3),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status['emoji']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive ? c.success : c.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Count & Clear filters
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              10,
              AppSpacing.lg,
              4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allVocabAsync.when(
                    data: (all) => '${filteredVocabList.length} từ vựng',
                    loading: () => 'Đang tải...',
                    error: (_, _) => 'Lỗi',
                  ),
                  style: TextStyle(fontSize: 13, color: c.placeholder),
                ),
                if (filter.level > 0 ||
                    filter.wordType != 'all' ||
                    filter.status != 'all' ||
                    filter.query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      ref.read(vocabFilterProvider.notifier).clear();
                      _searchController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, size: 14, color: c.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Xóa bộ lọc',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Vocab list
          Expanded(
            child: allVocabAsync.when(
              data: (all) {
                if (filteredVocabList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy từ vựng nào',
                          style: TextStyle(fontSize: 16, color: c.placeholder),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredVocabList.length,
                  padding: const EdgeInsets.only(bottom: 32),
                  itemBuilder: (_, i) =>
                      VocabCardWidget(item: filteredVocabList[i], colors: c),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
