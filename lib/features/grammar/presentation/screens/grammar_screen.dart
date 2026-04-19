import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/features/grammar/domain/entities/grammar_point.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';
import 'package:hanzify/features/grammar/presentation/screens/grammar_detail_screen.dart';

// ---------------------------------------------------------------------------
// HSK group descriptor
// ---------------------------------------------------------------------------

class _HskGroup {
  final int level;
  final String label;
  final String sublabel;
  final List<GrammarPoint> points;

  const _HskGroup({
    required this.level,
    required this.label,
    required this.sublabel,
    required this.points,
  });
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class GrammarScreen extends ConsumerStatefulWidget {
  const GrammarScreen({super.key});

  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  final _searchController = TextEditingController();

  static final List<GrammarPoint> _skeletonGrammar = List.generate(
    6,
    (i) => GrammarPoint(
      id: 'sk_$i',
      title: 'Đang tải điểm ngữ pháp',
      structure: 'S + 是 + N',
      explanation: 'Mô tả ngữ pháp đang được tải...',
      level: (i ~/ 2) + 1,
      category: 'basic',
      examples: const [],
    ),
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(grammarSearchQueryProvider.notifier).set(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOfRef(ref);
    final grammarListAsync = ref.watch(grammarListProvider);
    final isSearching = ref.watch(grammarSearchQueryProvider).isNotEmpty;

    // DB search: grammarListProvider tự rebuild khi search query thay đổi
    final grammarList = grammarListAsync.when(
      data: (list) => list,
      loading: () => <GrammarPoint>[],
      error: (_, _) => <GrammarPoint>[],
    );

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          HanzifyScreenHeader(
            title: 'Ngữ pháp',
            subtitle: 'Khám phá cấu trúc câu và quy tắc ngôn ngữ tinh hoa.',
            variant: HanzifyHeaderVariant.detail,
            onBack: () =>
                ref.read(navigationProvider.notifier).navigate(AppRoutes.home),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildSearchBar(c),
                const SizedBox(height: AppSpacing.xl),
                if (grammarListAsync.isLoading && grammarList.isEmpty)
                  Skeletonizer(
                    enabled: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildGroupSections(c, _skeletonGrammar),
                    ),
                  )
                else if (grammarList.isEmpty && isSearching)
                  const HanzifyEmptyState.searchNoResults()
                else if (grammarList.isEmpty)
                  const SizedBox.shrink()
                else
                  ..._buildGroupSections(c, grammarList),
                const SizedBox(height: AppSpacing.scrollBottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar(AppThemeColors c) {
    final query = ref.watch(grammarSearchQueryProvider);

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
                onChanged: _onSearchChanged,
                style: AppTypography.body(
                  fontSize: AppFontSizes.bodyMd,
                  color: c.text,
                ),
                decoration: InputDecoration(
                  hintText:
                      'T\u00ECm ki\u1EBFm \u0111i\u1EC3m ng\u1EEF ph\u00E1p (v\u00ED d\u1EE5: \u628A)',
                  hintStyle: AppTypography.body(
                    fontSize: AppFontSizes.bodyMd,
                    color: c.placeholder,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
            if (query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  ref.read(grammarSearchQueryProvider.notifier).set('');
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: c.placeholder,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Group sections ──────────────────────────────────────────────────────

  List<Widget> _buildGroupSections(
    AppThemeColors c,
    List<GrammarPoint> grammarList,
  ) {
    final groups = _groupPoints(grammarList);
    final widgets = <Widget>[];

    for (final group in groups) {
      // Section header row: badge + heading
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              HanzifyBadge.hsk(level: group.level, colors: c, filled: true),
              const SizedBox(width: AppSpacing.md),
              Text(
                group.label,
                style: AppTypography.headline(
                  fontSize: AppFontSizes.titleLg,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
            ],
          ),
        ),
      );

      // Cards — first is featured, rest are compact
      for (var i = 0; i < group.points.length; i++) {
        final gp = group.points[i];
        final isFeatured = i == 0;
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GestureDetector(
              onTap: () {
                HanzifyHaptic.tap();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GrammarDetailScreen(grammar: gp),
                  ),
                );
              },
              child: isFeatured
                  ? _FeaturedGrammarCard(grammar: gp, colors: c)
                  : _CompactGrammarCard(grammar: gp, colors: c),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  /// Group grammar points by HSK level for display.
  List<_HskGroup> _groupPoints(List<GrammarPoint> list) {
    final Map<int, List<GrammarPoint>> byLevel = {};
    for (final g in list) {
      final key = g.level >= 3 ? 3 : g.level;
      byLevel.putIfAbsent(key, () => []).add(g);
    }

    const meta = <int, (String, String)>{
      1: ('C\u0103n b\u1EA3n', 'HSK 1'),
      2: ('Trung c\u1EA5p th\u1EA5p', 'HSK 2'),
      3: ('N\u00E2ng cao', 'HSK 3+'),
    };

    return [
      for (final level in [1, 2, 3])
        if (byLevel.containsKey(level))
          _HskGroup(
            level: level,
            label: meta[level]?.$1 ?? 'Khác',
            sublabel: meta[level]?.$2 ?? 'Khác',
            points: byLevel[level]!,
          ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Featured card (large) — shows Hanzi structure prominently
// ---------------------------------------------------------------------------

class _FeaturedGrammarCard extends StatelessWidget {
  final GrammarPoint grammar;
  final AppThemeColors colors;

  const _FeaturedGrammarCard({required this.grammar, required this.colors});

  @override
  Widget build(BuildContext context) {
    return HanzifyCard(
      variant: HanzifyCardVariant.glass,
      borderRadius: AppRadii.xxxl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: colors.accentGradient,
                borderRadius: BorderRadius.circular(AppRadii.xxl),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                grammar.structure,
                style: AppTypography.hanziDisplay(
                  fontSize: AppFontSizes.displayMd,
                  fontWeight: FontWeight.w800,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Title
          Text(
            grammar.title,
            style: AppTypography.headline(
              fontSize: AppFontSizes.titleLg,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Description
          Text(
            grammar.explanation,
            style: AppTypography.body(
              fontSize: AppFontSizes.bodyMd,
              color: colors.placeholder,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // "Học ngay" link
          Row(
            children: [
              Text(
                'H\u1ECDc ngay',
                style: AppTypography.label(
                  fontSize: AppFontSizes.labelLg,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact card — circular icon left, text right
// ---------------------------------------------------------------------------

class _CompactGrammarCard extends StatelessWidget {
  final GrammarPoint grammar;
  final AppThemeColors colors;

  const _CompactGrammarCard({required this.grammar, required this.colors});

  /// Extract the core Hanzi character(s) from the structure for the icon.
  String get _iconChar {
    final s = grammar.structure;
    for (final c in s.runes) {
      if (c >= 0x4E00 && c <= 0x9FFF) return String.fromCharCode(c);
    }
    return s.length > 2 ? s.substring(0, 2) : s;
  }

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: colors.accentGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _iconChar,
              style: AppTypography.hanziUi(
                fontSize: AppFontSizes.headlineSm,
                fontWeight: FontWeight.w800,
                color: colors.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grammar.title,
                  style: AppTypography.label(
                    fontSize: AppFontSizes.titleSm,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  grammar.explanation,
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
          Icon(Icons.chevron_right_rounded, size: 20, color: colors.disabled),
        ],
      ),
    );
  }
}
