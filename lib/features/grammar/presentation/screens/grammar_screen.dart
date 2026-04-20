import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/features/grammar/domain/entities/grammar_point.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/features/grammar/presentation/screens/grammar_detail_screen.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Ngữ pháp', style: TextStyle(fontWeight: FontWeight.bold)),
              pinned: true,
              floating: true,
              scrolledUnderElevation: 2,
              backgroundColor: cs.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => ref.read(navigationProvider.notifier).goBack(),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Tìm kiếm điểm ngữ pháp...',
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
                                setState(() {
                                  _selectedLevel = t.$1;
                                  _expandedId = null;
                                });
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
        body: grammarListAsync.isLoading && allGrammar.isEmpty
            ? Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildGrammarList(themeColorsOfRef(ref), _skeletonGrammar),
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
                      child: _buildNoDataState(themeColorsOfRef(ref)),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 8),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          _buildGrammarList(themeColorsOfRef(ref), filteredList),
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

  List<Widget> _buildGrammarList(
    AppThemeColors c,
    List<GrammarPoint> points,
  ) {
    return points.map((gp) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
    return const HanzifyEmptyState(
      icon: Icons.auto_awesome_motion_rounded,
      title: 'Chưa có dữ liệu cho cấp độ này',
    );
  }
}

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

  String get _iconChar {
    final s = grammar.structure;
    for (final c in s.runes) {
      if (c >= 0x4E00 && c <= 0x9FFF) return String.fromCharCode(c);
    }
    return s.length > 2 ? s.substring(0, 2) : s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      alignment: Alignment.topCenter,
      child: Card.filled(
        color: isSelected ? cs.surfaceContainerHigh : cs.surfaceContainerLow,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSelected ? 24 : 16),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isSelected ? 20 : 12),
            child: isSelected ? _buildExpanded(context, theme, cs) : _buildCompact(theme, cs),
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(ThemeData theme, ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _iconChar,
            style: AppTypography.hanziUi(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                grammar.title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                grammar.explanation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Icon(isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
            size: 20, color: cs.onSurfaceVariant),
      ],
    );
  }

  Widget _buildExpanded(BuildContext context, ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CẤU TRÚC NGỮ PHÁP',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.secondary,
                letterSpacing: 1.2,
              ),
            ),
            Icon(Icons.keyboard_arrow_up, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: colors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              grammar.structure,
              style: AppTypography.hanziDisplay(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: cs.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          grammar.title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          grammar.explanation,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: () {
            HanzifyHaptic.tap();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GrammarDetailScreen(grammar: grammar)),
            );
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Học ngay', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
