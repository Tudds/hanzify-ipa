import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/features/grammar/domain/entities/grammar_point.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';

class GrammarDetailScreen extends ConsumerWidget {
  final GrammarPoint grammar;

  const GrammarDetailScreen({super.key, required this.grammar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = themeColorsOf(context);
    final showPinyin = ref.watch(showPinyinProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.of(context).padding.top + AppSpacing.sm),
              ),
              // ── Header ─────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context, c)),

              // ── Hero card ──────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeroCard(c)),

              // ── Công thức ──────────────────────────────────────────────
              if (grammar.formulaParts.isNotEmpty)
                SliverToBoxAdapter(child: _buildFormula(c)),

              // ── Cách dùng ──────────────────────────────────────────────
              if (grammar.usages.isNotEmpty)
                SliverToBoxAdapter(child: _buildUsages(c)),

              // ── Ví dụ minh họa ─────────────────────────────────────────
              SliverToBoxAdapter(
                  child: _buildExamples(c, showPinyin)),

              // ── Ngữ pháp liên quan ─────────────────────────────────────
              if (grammar.relatedGrammar.isNotEmpty)
                SliverToBoxAdapter(child: _buildRelatedGrammar(c, ref, context)),

              // ── Bottom CTA ─────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildCTA(c)),

              SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + AppSpacing.xxl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppThemeColors c) {
    return HanzifyAppBar(
      backStyle: HanzifyBackButtonStyle.rounded,
      backBoxShadow: c.cardShadow,
      title: 'Chi tiết ngữ pháp',
    );
  }

  // ── Hero card ────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(AppThemeColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: c.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadii.xxxl),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'CẤU TRÚC NGỮ PHÁP',
              style: AppTypography.label(
                fontSize: AppFontSizes.labelSm,
                color: c.onPrimarySoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              grammar.structure,
              style: AppTypography.hanziDisplay(
                fontSize: AppFontSizes.displayMd,
                fontWeight: FontWeight.w700,
                color: c.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              grammar.explanation,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                fontSize: AppFontSizes.bodyMd,
                color: c.onPrimarySoft,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Công thức ────────────────────────────────────────────────────────────────
  Widget _buildFormula(AppThemeColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HanzifySectionHeader(title: 'Công thức', icon: Icons.rule_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: HanzifyCard(
            color: c.surfaceLowest,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: grammar.formulaParts.map((part) {
                if (part.text == '+') {
                  return Text(
                    '+',
                    style: AppTypography.body(
                      fontSize: AppFontSizes.titleLg,
                      fontWeight: FontWeight.w300,
                      color: c.placeholder,
                    ),
                  );
                }
                if (part.isHighlighted) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Text(
                      part.text,
                      style: AppTypography.hanziUi(
                        fontSize: AppFontSizes.titleLg,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                // Regular label
                final isBracketed =
                    part.text.startsWith('[') && part.text.endsWith(']');
                if (isBracketed) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.disabled),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Text(
                      part.text,
                      style: AppTypography.label(
                        fontSize: AppFontSizes.bodySm,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: c.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Text(
                    part.text,
                    style: AppTypography.label(
                      fontSize: AppFontSizes.titleSm,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Cách dùng ────────────────────────────────────────────────────────────────
  Widget _buildUsages(AppThemeColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const HanzifySectionHeader(
            title: 'Cách dùng', icon: Icons.lightbulb_outline_rounded),
        ...grammar.usages.map((usage) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
              child: HanzifyCard(
                color: c.surfaceLowest,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      alignment: Alignment.center,
                      child: Text(usage.icon,
                          style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usage.title,
                            style: AppTypography.label(
                              fontSize: AppFontSizes.titleSm,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            usage.description,
                            style: AppTypography.body(
                              fontSize: AppFontSizes.bodySm,
                              color: c.placeholder,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ── Ví dụ minh họa ──────────────────────────────────────────────────────────
  Widget _buildExamples(AppThemeColors c, bool showPinyin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const HanzifySectionHeader(
            title: 'Ví dụ minh họa', icon: Icons.format_quote_rounded),
        ...List.generate(grammar.examples.length, (i) {
          final ex = grammar.examples[i];
          final tag = i < grammar.exampleTags.length
              ? grammar.exampleTags[i]
              : null;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
            child: HanzifyCard(
              color: c.surfaceLowest,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: HanzifyBadge(
                        label: tag,
                        color: c.primary,
                        fontSize: AppFontSizes.labelSm,
                      ),
                    ),
                  // Chinese sentence
                  Text(
                    ex.zh,
                    style: AppTypography.hanziUi(
                      fontSize: AppFontSizes.headlineSm,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  if (showPinyin && ex.pinyin.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ex.pinyin,
                      style: AppTypography.pinyin(
                        fontSize: AppFontSizes.bodyMd,
                        color: c.primary,
                      ),
                    ),
                  ],
                  if (ex.vi.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 3,
                          height: 20,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: c.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ex.vi,
                            style: AppTypography.body(
                              fontSize: AppFontSizes.bodyMd,
                              color: c.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Speaker icon
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.volume_up_rounded,
                        size: 20, color: c.placeholder),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Ngữ pháp liên quan ────────────────────────────────────────────────────
  Widget _buildRelatedGrammar(AppThemeColors c, WidgetRef ref, BuildContext context) {
    final allGrammarAsync = ref.watch(grammarListProvider);
    final allGrammar = allGrammarAsync.asData?.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const HanzifySectionHeader(
            title: 'Ngữ pháp liên quan', icon: Icons.link_rounded),
        ...grammar.relatedGrammar.map((relatedId) {
          final related = allGrammar.where((g) => g.id == relatedId).firstOrNull;
          if (related == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
            child: HanzifyCard(
              color: c.surfaceLowest,
              padding: const EdgeInsets.all(AppSpacing.lg),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GrammarDetailScreen(grammar: related),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      related.structure.length > 1
                          ? related.structure.substring(0, 1)
                          : related.structure,
                      style: AppTypography.hanziUi(
                        fontSize: AppFontSizes.headlineSm,
                        fontWeight: FontWeight.w700,
                        color: c.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          related.title,
                          style: AppTypography.label(
                            fontSize: AppFontSizes.titleSm,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          related.structure,
                          style: AppTypography.body(
                            fontSize: AppFontSizes.bodySm,
                            color: c.placeholder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: c.disabled),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── CTA button ──────────────────────────────────────────────────────────────
  Widget _buildCTA(AppThemeColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: c.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadii.xxxl),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Luyện tập cấu trúc này',
                style: AppTypography.label(
                  fontSize: AppFontSizes.titleMd,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
