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
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/features/grammar/domain/entities/grammar_point.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';
import 'package:hanzify/features/grammar/presentation/screens/grammar_detail_screen.dart';

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
  String? _expandedId;
  int _selectedLevel = 1;

  static final List<GrammarPoint> _skeletonGrammar = List.generate(
    6,
    (i) => GrammarPoint(
      id: 'sk_$i',
      title: 'Đang tải điểm ngữ pháp',
      structure: 'S + 是 + N',
      explanation: 'Mô tả ngữ pháp đang được tải...',
      level: 1,
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

    final allGrammar = grammarListAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <GrammarPoint>[],
    );

    final filteredList = isSearching
        ? allGrammar
        : allGrammar.where((g) {
            if (_selectedLevel == 3) return g.level >= 3;
            return g.level == _selectedLevel;
          }).toList();

    return Scaffold(
      backgroundColor: c.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
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
                title: Text(
                  'Ngữ pháp',
                  style: AppTypography.headline(
                    fontSize: AppFontSizes.headlineSm,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        c.primary.withValues(alpha: 0.1),
                        c.background,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: 40,
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 180,
                          color: c.primary.withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
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
        body: grammarListAsync.isLoading && allGrammar.isEmpty
            ? Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildGrammarList(c, _skeletonGrammar),
                ),
              )
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
                          _buildGrammarList(c, filteredList),
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
                      'T\u00ECm ki\u1EBFm \u0111i\u1EC3m ng\u1EEF ph\u00E1p',
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
                  setState(() {
                    _selectedLevel = t.$1;
                    _expandedId = null;
                  });
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

  // ── Grammar List ────────────────────────────────────────────────────────

  List<Widget> _buildGrammarList(
    AppThemeColors c,
    List<GrammarPoint> points,
  ) {
    return points.map((gp) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: _GrammarCard(
          grammar: gp,
          colors: c,
          isSelected: _expandedId == gp.id,
          onTap: () {
            HanzifyHaptic.select();
            setState(() {
              _expandedId = _expandedId == gp.id ? null : gp.id;
            });
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
          Icon(Icons.auto_awesome_motion_rounded,
              size: 64, color: c.placeholder.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ch\u01B0a c\u00F3 d\u1EEF li\u1EC7u cho c\u1EA5p \u0111\u1ED9 n\u00E0y',
            style: AppTypography.body(color: c.placeholder),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Premium Expandable Grammar Card
// ---------------------------------------------------------------------------

class _GrammarCard extends StatelessWidget {
  final GrammarPoint grammar;
  final AppThemeColors colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _GrammarCard({
    required this.grammar,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

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
    final c = colors;

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutQuart,
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: HanzifyCard(
          variant: HanzifyCardVariant.glass,
          borderRadius: isSelected ? AppRadii.xxxl : AppRadii.xxl,
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              isSelected ? AppRadii.xxxl : AppRadii.xxl,
            ),
            child: Padding(
              padding: isSelected
                  ? const EdgeInsets.all(AppSpacing.xl)
                  : const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
              child: isSelected ? _buildExpanded(context, c) : _buildCompact(c),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(AppThemeColors c) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: c.accentGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            _iconChar,
            style: AppTypography.hanziUi(
              fontSize: AppFontSizes.headlineSm,
              fontWeight: FontWeight.w800,
              color: c.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                grammar.title,
                style: AppTypography.label(
                  fontSize: AppFontSizes.titleSm,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                grammar.explanation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(
                  fontSize: AppFontSizes.bodySm,
                  color: c.placeholder,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_drop_down_rounded, size: 24, color: c.disabled),
      ],
    );
  }

  Widget _buildExpanded(BuildContext context, AppThemeColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'C\u1EA4U TR\u00DAC NG\u1EEE PH\u00C1P',
              style: AppTypography.label(
                fontSize: AppFontSizes.labelSm,
                fontWeight: FontWeight.w800,
                color: c.secondary,
                letterSpacing: 1.2,
              ),
            ),
            Icon(Icons.arrow_drop_up_rounded, color: c.placeholder, size: 24),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: c.accentGradient,
              borderRadius: BorderRadius.circular(AppRadii.xxl),
              boxShadow: [
                BoxShadow(
                  color: c.primary.withValues(alpha: 0.25),
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
                color: c.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          grammar.title,
          style: AppTypography.headline(
            fontSize: AppFontSizes.titleLg,
            fontWeight: FontWeight.w700,
            color: c.text,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          grammar.explanation,
          style: AppTypography.body(
            fontSize: AppFontSizes.bodyMd,
            color: c.placeholder,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // "Học ngay" button
        InkWell(
          onTap: () {
            HanzifyHaptic.tap();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GrammarDetailScreen(grammar: grammar),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: c.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'H\u1ECDc ngay',
                  style: AppTypography.label(
                    fontSize: AppFontSizes.labelLg,
                    fontWeight: FontWeight.w700,
                    color: c.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward_rounded, size: 18, color: c.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
