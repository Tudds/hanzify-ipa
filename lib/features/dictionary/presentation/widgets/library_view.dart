import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/hsk_levels.dart';
import '../../../../core/providers/performance_provider.dart';
import '../../application/library_state.dart';
import '../../domain/grammar_item.dart';
import '../../domain/vocab_item.dart';
import 'grammar_card.dart';
import 'grammar_detail_sheet.dart';
import 'vocab_card.dart';
import 'vocab_detail_sheet.dart';

class LibraryView extends ConsumerStatefulWidget {
  const LibraryView({super.key});

  @override
  ConsumerState<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends ConsumerState<LibraryView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  late final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filter = ref.watch(libraryFilterProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          height: 48,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: LayoutBuilder(
            builder: (context, tabConstraints) {
              final tabWidth = tabConstraints.maxWidth / 2;
              return Stack(
                children: [
                  AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (context, child) {
                      final offset = _tabController.animation!.value * tabWidth;
                      return Positioned(
                        left: offset + 4,
                        top: 4,
                        bottom: 4,
                        width: tabWidth - 8,
                        child: child!,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _tabController.animateTo(0),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _tabController.animation!,
                              builder: (context, _) {
                                final val = _tabController.animation!.value;
                                final color = Color.lerp(
                                  colors.onPrimary,
                                  colors.onSurfaceVariant,
                                  val.clamp(0.0, 1.0),
                                );
                                return Text(
                                  'Từ vựng',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _tabController.animateTo(1),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _tabController.animation!,
                              builder: (context, _) {
                                final val = _tabController.animation!.value;
                                final color = Color.lerp(
                                  colors.onSurfaceVariant,
                                  colors.onPrimary,
                                  val.clamp(0.0, 1.0),
                                );
                                return Text(
                                  'Ngữ pháp',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: ref
                    .read(libraryFilterProvider.notifier)
                    .setQuery,
                decoration: InputDecoration(
                  hintText: 'Tìm Hanzi, pinyin, nghĩa...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: colors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  suffixIcon: filter.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(libraryFilterProvider.notifier)
                                .setQuery('');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _LevelFilterChip(level: null, label: 'Tất cả'),
                    for (final level in kHskLevels)
                      _LevelFilterChip(
                        level: level,
                        label: 'HSK $level',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _VocabTab(),
              _GrammarTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelFilterChip extends ConsumerWidget {
  const _LevelFilterChip({required this.level, required this.label});

  final int? level;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(libraryFilterProvider);
    final selected = filter.level == level;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) =>
            ref.read(libraryFilterProvider.notifier).setLevel(level),
      ),
    );
  }
}

class _VocabTab extends ConsumerWidget {
  const _VocabTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(libraryFilterProvider);
    // When a level is selected, parse only that level's file; otherwise load all.
    final asyncVocab = filter.level == null
        ? ref.watch(vocabLibraryProvider)
        : ref.watch(vocabLibraryForLevelProvider(filter.level!));
    final performance = readPerformance(ref);

    return asyncVocab.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải từ vựng: $e')),
      data: (items) {
        final filtered = _filterVocab(items, filter);
        if (filtered.isEmpty) {
          return const _EmptyState(message: 'Không tìm thấy từ vựng phù hợp');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = filtered[index];
            final card = VocabCard(
              item: item,
              onTap: () => VocabDetailSheet.show(context, item),
            );
            if (performance || index >= 12) return card;
            return card
                .animate()
                .fadeIn(duration: 240.ms, delay: (index * 30).ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
          },
        );
      },
    );
  }

  List<VocabItem> _filterVocab(List<VocabItem> items, LibraryFilter filter) {
    final query = filter.query.trim().toLowerCase();
    return items.where((item) {
      if (filter.level != null && item.level != filter.level) return false;
      if (query.isEmpty) return true;
      if (item.hanzi.contains(query)) return true;
      if (item.pinyin.toLowerCase().contains(query)) return true;
      if (item.pinyinNormalized.toLowerCase().contains(query)) return true;
      for (final m in item.meanings) {
        if (m.vi.toLowerCase().contains(query)) return true;
        if (m.en.toLowerCase().contains(query)) return true;
      }
      return false;
    }).toList(growable: false);
  }
}

class _GrammarTab extends ConsumerWidget {
  const _GrammarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(libraryFilterProvider);
    final asyncGrammar = filter.level == null
        ? ref.watch(grammarLibraryProvider)
        : ref.watch(grammarLibraryForLevelProvider(filter.level!));
    final performance = readPerformance(ref);

    return asyncGrammar.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải ngữ pháp: $e')),
      data: (items) {
        final filtered = _filterGrammar(items, filter);
        if (filtered.isEmpty) {
          return const _EmptyState(message: 'Không tìm thấy điểm ngữ pháp');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = filtered[index];
            final card = GrammarCard(
              item: item,
              onTap: () => GrammarDetailSheet.show(context, item),
            );
            if (performance || index >= 12) return card;
            return card
                .animate()
                .fadeIn(duration: 240.ms, delay: (index * 30).ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
          },
        );
      },
    );
  }

  List<GrammarItem> _filterGrammar(
    List<GrammarItem> items,
    LibraryFilter filter,
  ) {
    final query = filter.query.trim().toLowerCase();
    return items.where((item) {
      if (filter.level != null && item.level != filter.level) return false;
      if (query.isEmpty) return true;
      if (item.title.toLowerCase().contains(query)) return true;
      if (item.structure.toLowerCase().contains(query)) return true;
      if (item.explanation.toLowerCase().contains(query)) return true;
      return false;
    }).toList(growable: false);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: colors.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
