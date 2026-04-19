import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';
import 'package:hanzify/core/widgets/hanzify_snack.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';


import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_filter_chip.dart';
import 'package:hanzify/core/widgets/search_bar_widget.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/utils/pos_labels.dart' show posLabelShort;
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';
import 'package:hanzify/core/enums/filter_enums.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_filter_provider.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
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
      meanings: const [Meaning(pos: 'other', vi: 'xin chào — đang tải dữ liệu')],
      level: 1,
      wordType: 'n',
      nextReview: DateTime.now(),
    ),
  );

  /// Merged filter chips: "Tat ca" + HSK levels + word types
  /// Uses centralized posLabelShort() for Vietnamese POS labels
  static const _filterChips = [
    {'key': 'all', 'label': 'Tất cả', 'type': 'level', 'value': '0'},
    {'key': 'hsk1', 'label': 'HSK 1', 'type': 'level', 'value': '1'},
    {'key': 'hsk2', 'label': 'HSK 2', 'type': 'level', 'value': '2'},
    {'key': 'hsk3', 'label': 'HSK 3', 'type': 'level', 'value': '3'},
    {'key': 'n', 'label': 'Danh từ', 'type': 'wordType', 'value': 'n'},
    {'key': 'v', 'label': 'Động từ', 'type': 'wordType', 'value': 'v'},
    {'key': 'adj', 'label': 'Tính từ', 'type': 'wordType', 'value': 'adj'},
    {'key': 'adv', 'label': 'Trạng từ', 'type': 'wordType', 'value': 'adv'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Kiểm tra xem có tham số HSK được truyền vào từ navigationProvider không
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

  /// Debounced search — đợi 300ms sau khi user ngừng gõ mới trigger query.
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(vocabFilterProvider.notifier).setQuery(query);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final filter = ref.watch(vocabFilterProvider);
    // filteredVocabProvider đã watch vocabSearchProvider nội bộ
    // → không cần watch vocabSearchProvider riêng, tránh double DB query.
    final filteredList = ref.watch(filteredVocabProvider);
    final isLoading = ref.watch(vocabSearchProvider).isLoading;

    if (filter.query.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    return Scaffold(
      backgroundColor: c.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const HanzifyScreenHeader(title: 'Từ Điển'),
            SliverToBoxAdapter(
              child: Column(
                children: [
                   // ── Search bar ──────────────────────────────────────────────────
                  SearchBarWidget(
                    value: filter.query,
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    colors: c,
                    placeholder: 'Tìm kiếm Hán tự, Pinyin, hoặc tiếng Việt...',
                  ),

                  // ── Filter chips (single row, horizontal scroll) ────────────────
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                      children: _filterChips.map((chip) {
                        final active = _isChipActive(chip, filter);
                        return HanzifyFilterChip(
                          label: chip['label']!,
                          isActive: active,
                          onTap: () {
                            HanzifyHaptic.select();
                            _onChipTap(chip);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: Skeletonizer(
          enabled: isLoading,
          child: _buildBody(
            isLoading && filteredList.isEmpty ? _skeletonVocabs : filteredList,
            c,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<Vocab> filteredList, AppThemeColors c) {
    if (filteredList.isEmpty) {
      return const HanzifyEmptyState.noVocab();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildVocabResultCard(filteredList[index], c);
      },
    );
  }

  Widget _buildVocabResultCard(Vocab vocab, AppThemeColors c) {
    final displayMeaning = vocab.primaryMeaningVi;
    final displayPos = vocab.primaryPos;

    return Slidable(
      key: ValueKey(vocab.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) {
              HanzifyHaptic.select();
              ref.read(allVocabProvider.notifier).toggleBookmark(vocab);
              HanzifySnack.success(
                context,
                vocab.isBookmarked ? 'Đã bỏ đánh dấu' : 'Đã đánh dấu',
              );
            },
            backgroundColor: c.primary,
            foregroundColor: Colors.white,
            icon: vocab.isBookmarked ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
            label: vocab.isBookmarked ? 'Bỏ' : 'Lưu',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(AppRadii.xxl)),
          ),
          SlidableAction(
            onPressed: (_) {
              HanzifyHaptic.select();
              ref.read(allVocabProvider.notifier).toggleMastered(vocab);
              HanzifySnack.success(
                context,
                vocab.isMastered ? 'Đã bỏ trạng thái thuộc' : 'Đã đánh dấu thuộc lòng',
              );
            },
            backgroundColor: c.success,
            foregroundColor: Colors.white,
            icon: vocab.isMastered ? Icons.restart_alt_rounded : Icons.verified_rounded,
            label: vocab.isMastered ? 'Chưa thuộc' : 'Thuộc',
          ),
        ],
      ),
      child: HanzifyCard(
        variant: HanzifyCardVariant.solid,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 5),
        padding: EdgeInsets.zero,
        borderRadius: AppRadii.xxl,
        onTap: () {
          HanzifyHaptic.tap();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VocabDetailScreen(vocab: vocab),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Level color stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _levelColor(c, vocab.level),
                      _levelColor(c, vocab.level).withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.xxl)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'hanzi_${vocab.id}',
                        child: ShaderMask(
                          shaderCallback: (r) => LinearGradient(
                            colors: [c.text, c.text.withValues(alpha: 0.85)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(r),
                          child: Text(
                            vocab.hanzi,
                            style: AppTypography.hanziUi(
                              fontSize: AppFontSizes.displaySm,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    vocab.pinyin,
                                    style: AppTypography.pinyin(
                                      fontSize: AppFontSizes.bodySm,
                                      color: c.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                HanzifyBadge.hsk(
                                  level: vocab.level,
                                  colors: c,
                                  filled: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayMeaning,
                              style: AppTypography.body(
                                fontSize: AppFontSizes.titleMd,
                                fontWeight: FontWeight.w800,
                                color: c.text,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (displayPos != 'other')
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.surfaceLow.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(AppRadii.full),
                                    border: Border.all(color: c.glassBorder, width: 1),
                                  ),
                                  child: Text(
                                    _posLabel(displayPos),
                                    style: AppTypography.label(
                                      fontSize: AppFontSizes.labelSm,
                                      fontWeight: FontWeight.w700,
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(allVocabProvider.notifier).toggleBookmark(vocab);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: vocab.isBookmarked
                                ? c.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            vocab.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 22,
                            color: vocab.isBookmarked ? c.primary : c.placeholder,
                          ),
                        ),
                      ),
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

  String _posLabel(String pos) => posLabelShort(pos);

  Color _levelColor(AppThemeColors c, int level) {
    if (level <= 0 || level > c.hskColors.length) return c.primary;
    return c.hskColors[level - 1];
  }
}
