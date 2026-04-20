import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/utils/pos_labels.dart' show posLabelShort;
import 'package:hanzify/core/enums/filter_enums.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_filter_provider.dart';
import 'package:hanzify/features/vocab/presentation/screens/vocab_detail_screen.dart';

class VocabListScreen extends ConsumerStatefulWidget {
  const VocabListScreen({super.key});

  @override
  ConsumerState<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends ConsumerState<VocabListScreen> {
  late TextEditingController _searchController;
  Timer? _debounceTimer;

  static final List<Vocab> _skeletonVocabs = List.generate(
    8,
    (i) => Vocab(
      id: 'skeleton_$i',
      hanzi: '你好',
      pinyin: 'nǐ hǎo',
      meanings: const [Meaning(pos: 'other', vi: 'Đang tải dữ liệu...')],
      level: 1,
      wordType: 'n',
      nextReview: DateTime.now(),
    ),
  );

  static const _filterChips = [
    {'key': 'all', 'label': 'Tất cả', 'type': 'level', 'value': '0'},
    {'key': 'hsk1', 'label': 'HSK 1', 'type': 'level', 'value': '1'},
    {'key': 'hsk2', 'label': 'HSK 2', 'type': 'level', 'value': '2'},
    {'key': 'hsk3', 'label': 'HSK 3', 'type': 'level', 'value': '3'},
    {'key': 'hsk4', 'label': 'HSK 4', 'type': 'level', 'value': '4'},
    {'key': 'n', 'label': 'Danh từ', 'type': 'wordType', 'value': 'n'},
    {'key': 'v', 'label': 'Động từ', 'type': 'wordType', 'value': 'v'},
    {'key': 'adj', 'label': 'Tính từ', 'type': 'wordType', 'value': 'adj'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final arg = ref.read(navigationProvider).arg;
      if (arg != null) {
        final level = int.tryParse(arg);
        if (level != null && level > 0) {
          ref.read(vocabFilterProvider.notifier).setLevel(level);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(vocabFilterProvider.notifier).setQuery(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = themeColorsOfRef(ref);
    final vocabListAsync = ref.watch(filteredVocabListProvider);
    final filter = ref.watch(vocabFilterProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Từ vựng', style: TextStyle(fontWeight: FontWeight.bold)),
              pinned: true,
              floating: true,
              scrolledUnderElevation: 2,
              backgroundColor: cs.surface,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Tìm kiếm từ vựng...',
                      onChanged: _onSearchChanged,
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                      ],
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: _filterChips.map((chip) {
                        final isActive = _isChipActive(chip, filter);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(chip['label']!),
                            selected: isActive,
                            onSelected: (_) {
                              HanzifyHaptic.select();
                              _onChipTap(chip);
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
        body: vocabListAsync.isLoading && vocabListAsync.value == null
            ? Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: 8,
                  itemBuilder: (_, index) => _VocabCard(vocab: _skeletonVocabs[0], colors: c, cs: cs, theme: theme),
                ),
              )
            : vocabListAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const HanzifyEmptyState.searchNoResults();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _VocabCard(vocab: list[index], colors: c, cs: cs, theme: theme);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => HanzifyEmptyState.errorState(errorText: e.toString()),
              ),
      ),
    );
  }

  bool _isChipActive(Map<String, String> chip, VocabFilter filter) {
    if (chip['key'] == 'all') {
      return filter.level == 0 && filter.wordType == FilterWordType.all;
    }
    if (chip['type'] == 'level') {
      return filter.level == int.parse(chip['value']!) && filter.wordType == FilterWordType.all;
    }
    return filter.wordType == posToFilterWordType(chip['value']!);
  }

  void _onChipTap(Map<String, String> chip) {
    final notifier = ref.read(vocabFilterProvider.notifier);
    if (chip['key'] == 'all') {
      notifier.setLevel(0);
      notifier.setWordType(FilterWordType.all);
    } else if (chip['type'] == 'level') {
      notifier.setLevel(int.parse(chip['value']!));
      notifier.setWordType(FilterWordType.all);
    } else {
      notifier.setLevel(0);
      notifier.setWordType(posToFilterWordType(chip['value']!));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vocab Card — New 2-row layout, solid variant
// ─────────────────────────────────────────────────────────────────────────────
class _VocabCard extends StatelessWidget {
  final Vocab vocab;
  final AppThemeColors colors;
  final ColorScheme cs;
  final ThemeData theme;

  const _VocabCard({
    required this.vocab,
    required this.colors,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final pos = vocab.meanings.isNotEmpty ? vocab.meanings.first.pos : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardListGap),
      child: HanzifyCard(
        variant: HanzifyCardVariant.solid,
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: () {
          HanzifyHaptic.tap();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => VocabDetailScreen(vocab: vocab)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Hanzi + Pinyin + HSK Badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hanzi — large and prominent
                Text(
                  vocab.hanzi,
                  style: AppTypography.hanziUi(
                    fontSize: vocab.hanzi.length > 3 ? AppFontSizes.headlineSm : AppFontSizes.headlineMd,
                    fontWeight: FontWeight.w700,
                    color: c.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Pinyin
                Expanded(
                  child: Text(
                    vocab.pinyin,
                    style: AppTypography.pinyin(
                      fontSize: AppFontSizes.bodyMd,
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ),
                // Mastered indicator
                if (vocab.isMastered) ...[
                  Icon(Icons.check_circle_rounded, size: 16, color: c.success),
                  const SizedBox(width: AppSpacing.xs),
                ],
                // HSK Badge
                HanzifyBadge.hsk(level: vocab.level, colors: c, filled: false),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Row 2: POS Tag + Meaning ──
            Row(
              children: [
                if (pos.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: (c.posColors[pos] ?? c.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                    ),
                    child: Text(
                      posLabelShort(pos).toUpperCase(),
                      style: AppTypography.label(
                        fontSize: AppFontSizes.labelSm,
                        fontWeight: FontWeight.w700,
                        color: c.posColors[pos] ?? c.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    vocab.primaryMeaningVi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      fontSize: AppFontSizes.titleSm,
                      color: c.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
