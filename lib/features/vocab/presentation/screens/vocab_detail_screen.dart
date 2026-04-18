import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/highlighted_text.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/core/utils/pos_labels.dart' show posLabelFull;
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/character/presentation/providers/character_providers.dart';
import 'package:hanzify/features/character/presentation/widgets/stroke_animation_widget.dart';

// POS labels đã được tập trung trong core/utils/pos_labels.dart

class VocabDetailScreen extends ConsumerStatefulWidget {
  final Vocab vocab;

  const VocabDetailScreen({super.key, required this.vocab});

  @override
  ConsumerState<VocabDetailScreen> createState() => _VocabDetailScreenState();
}

class _VocabDetailScreenState extends ConsumerState<VocabDetailScreen> {
  int? _activeCharIndex;

  Vocab get vocab => widget.vocab;

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final vocab = widget.vocab;
    final showPinyin = ref.watch(showPinyinProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          // Watermark hanzi at bottom right
          Positioned(
            bottom: -40,
            right: -20,
            child: Text(
              vocab.hanzi,
              style: AppTypography.hanziDisplay(
                fontSize: 240,
                color: c.text.withValues(alpha: 0.04),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // Safe area top padding
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + AppSpacing.sm,
                ),
              ),

              // ── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context, ref, c)),

              // ── Hero Section ────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeroSection(context, ref, c, showPinyin),
              ),

              // ── Writing Guide ───────────────────────────────────────
              SliverToBoxAdapter(child: _buildWritingGuide(context, ref, c)),

              // ── Meanings & POS ──────────────────────────────────────
              SliverToBoxAdapter(child: _buildMeanings(c)),

              // ── Examples ────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildExamples(c, showPinyin)),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + AppSpacing.xxxl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, WidgetRef ref, AppThemeColors c) {
    return HanzifyAppBar(
      backStyle: HanzifyBackButtonStyle.rounded,
      backBoxShadow: c.cardShadow,
      trailing: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(allVocabProvider.notifier).toggleBookmark(vocab);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: vocab.isBookmarked
                ? c.primary.withValues(alpha: 0.12)
                : c.surfaceLowest,
            borderRadius: BorderRadius.circular(AppRadii.full),
            boxShadow: c.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                vocab.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: vocab.isBookmarked ? c.primary : c.placeholder,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Lưu',
                style: AppTypography.label(
                  color: vocab.isBookmarked ? c.primary : c.placeholder,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Section ────────────────────────────────────────────────────────────
  Widget _buildHeroSection(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors c,
    bool showPinyin,
  ) {
    final fontSize = vocab.hanzi.length > 3 ? 80.0 : 120.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: vocab.hanzi.split('').map((char) {
              return Hero(
                tag: 'char_$char',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    char,
                    style: AppTypography.hanziDisplay(
                      fontSize: fontSize,
                      color: c.text,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '(${vocab.pinyin})',
            style: AppTypography.pinyin(
              fontSize: AppFontSizes.titleLg,
              color: c.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Writing Guide ───────────────────────────────────────────────────────────
  Widget _buildWritingGuide(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors c,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HanzifySectionHeader(
          title: 'Chi tiết từng chữ',
          icon: Icons.draw_rounded,
        ),
        if (vocab.characters.isNotEmpty)
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: vocab.characters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, index) {
                return _CharacterStrokeCard(
                  char: vocab.characters[index],
                  colors: c,
                  isSelected: _activeCharIndex == index,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      if (_activeCharIndex == index) {
                        _activeCharIndex = null;
                      } else {
                        _activeCharIndex = index;
                      }
                    });
                  },
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ── Meanings & POS ──────────────────────────────────────────────────────────
  Widget _buildMeanings(AppThemeColors c) {
    // Use centralized VocabMeaningHelper extension for grouping
    final groupedMeanings = vocab.groupedByPos;
    final posKeys = groupedMeanings.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HanzifySectionHeader(
          title: 'Nghĩa & từ loại',
          icon: Icons.menu_book_rounded,
        ),
        // HSK badge exclusively at top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: HanzifyBadge.hsk(level: vocab.level, colors: c),
        ),
        const SizedBox(height: AppSpacing.md),

        // Meanings grouped by POS
        if (vocab.meanings.isNotEmpty)
          ...posKeys.map((pos) {
            final meanings = groupedMeanings[pos]!;
            final posLabel = posLabelFull(pos);
            final posColor = c.posColors[pos] ?? c.primary;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xs,
              ).copyWith(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // POS Badge as header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: posColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(
                            color: posColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          posLabel,
                          style: AppTypography.label(
                            fontSize: AppFontSizes.labelSm,
                            color: posColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Divider(
                          color: posColor.withValues(alpha: 0.1),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Content card for this POS
                  HanzifyCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < meanings.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          _buildMeaningRow(meanings[i], c),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildMeaningRow(Meaning m, AppThemeColors c) {
    final posColor = c.posColors[m.pos] ?? c.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: posColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            m.vi,
            style: AppTypography.body(
              fontSize: AppFontSizes.bodyLg,
              color: c.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Examples ────────────────────────────────────────────────────────────────
  Widget _buildExamples(AppThemeColors c, bool showPinyin) {
    if (vocab.exampleSentences.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HanzifySectionHeader(
          title: 'Câu ví dụ',
          icon: Icons.format_quote_rounded,
        ),
        ...vocab.exampleSentences.map(
          (ex) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
            ).copyWith(bottom: AppSpacing.md),
            child: HanzifyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chinese text
                  HanzifyHighlightedText(
                    text: ex.cn,
                    highlight: vocab.hanzi,
                    baseStyle: AppTypography.hanziUi(
                      fontSize: AppFontSizes.titleLg,
                      color: c.text,
                    ),
                    colors: c,
                  ),
                  // Pinyin
                  const SizedBox(height: AppSpacing.xs),
                  HanzifyHighlightedText(
                    text: ex.pinyin,
                    highlight: vocab.pinyin,
                    baseStyle: AppTypography.pinyin(
                      fontSize: AppFontSizes.bodySm,
                      color: c.primary,
                    ),
                    colors: c,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Vietnamese with left border accent
                  Container(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      top: AppSpacing.xs,
                      bottom: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: c.primary.withValues(alpha: 0.4),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      ex.vi,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodyMd,
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _CharacterStrokeCard extends ConsumerWidget {
  final String char;
  final AppThemeColors colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterStrokeCard({
    required this.char,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = colors;
    final charAsync = ref.watch(characterDetailProvider(char));

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop();
        ref
            .read(navigationProvider.notifier)
            .navigate(AppRoutes.charDetail, arg: char);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
        width: isSelected ? 200 : 100,
        child: HanzifyCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isSelected) ...[
                Text(
                  char,
                  style: AppTypography.hanziDisplay(
                    fontSize: AppFontSizes.displaySm,
                    color: c.text,
                  ),
                ),
                charAsync.maybeWhen(
                  data: (character) => character?.pinyin != null
                      ? Text(
                          character!.pinyin!,
                          style: AppTypography.pinyin(
                            fontSize: 12,
                            color: c.primary,
                          ),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Nét ✍️',
                  style: AppTypography.label(fontSize: 10, color: c.primary),
                ),
              ] else
                charAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(color: c.primary),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      char,
                      style: AppTypography.hanziDisplay(
                        fontSize: AppFontSizes.displaySm,
                        color: c.text,
                      ),
                    ),
                  ),
                  data: (character) {
                    if (character == null || character.strokes.isEmpty) {
                      return Center(
                        child: Text(
                          char,
                          style: AppTypography.hanziDisplay(
                            fontSize: AppFontSizes.displaySm,
                            color: c.text,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Column(
                          children: [
                            Text(
                              char,
                              style: AppTypography.hanziDisplay(
                                fontSize: AppFontSizes.titleMd,
                                color: c.text,
                              ),
                            ),
                            if (character.pinyin != null)
                              Text(
                                character.pinyin!,
                                style: AppTypography.pinyin(
                                  fontSize: 10,
                                  color: c.primary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        StrokeAnimationWidget(
                          svgStrokes: character.strokes,
                          colors: c,
                          size: 120,
                          autoPlay: true,
                          showControls: false,
                          loop: true,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
