// lib/features/character/presentation/screens/character_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/features/vocab/presentation/screens/vocab_detail_screen.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';
import '../providers/character_providers.dart';
import '../widgets/stroke_animation_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharacterDetailScreen
// Nhận [char] — ký tự đơn cần xem chi tiết
// ─────────────────────────────────────────────────────────────────────────────
class CharacterDetailScreen extends ConsumerWidget {
  final String char;

  const CharacterDetailScreen({super.key, required this.char});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = themeColorsOfRef(ref);
    final charAsync = ref.watch(characterDetailProvider(char));
    final vocabAsync = ref.watch(vocabContainingCharProvider(char));

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          _Header(char: char, colors: c),

          // ── Content ────────────────────────────────────────────────────────
          Expanded(
            child: charAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: c.primary)),
              error: (e, _) => HanzifyEmptyState.errorState(errorText: 'Lỗi tải dữ liệu "$char"'),
              data: (character) {
                if (character == null) {
                  return HanzifyEmptyState.noCharacterData(character: char);
                }
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Stroke animation section
                    SliverToBoxAdapter(
                      child: _StrokeSection(
                        strokes: character.strokes,
                        colors: c,
                      ),
                    ),

                    // Info section
                    SliverToBoxAdapter(
                      child: _InfoSection(
                        char: char,
                        pinyin: character.pinyin,
                        radical: character.radical,
                        strokeCount: character.strokeCount,
                        hskLevel: character.hskLevel,
                        definitionVi: character.definitionVi,
                        colors: c,
                      ),
                    ),

                    // Words containing this character
                    SliverToBoxAdapter(
                      child: vocabAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (vocabList) => vocabList.isEmpty
                            ? const SizedBox.shrink()
                            : _VocabSection(
                                char: char,
                                vocabList: vocabList,
                                colors: c,
                              ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  final String char;
  final AppThemeColors colors;

  const _Header({required this.char, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = colors;
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppSpacing.sm), // Safe area
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.outlineVariant, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            HanzifyBackButton(
              style: HanzifyBackButtonStyle.iconOnly,
              onTap: () => ref.read(navigationProvider.notifier).goBack(),
            ),
            Expanded(
              child: Text(
                'Chi tiết chữ',
                style: AppTypography.headline(
                  fontSize: AppFontSizes.titleLg,
                  color: c.text,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.iconMd), // Equalizer for center alignment
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stroke Animation Section
// ─────────────────────────────────────────────────────────────────────────────
class _StrokeSection extends StatelessWidget {
  final List<String> strokes;
  final AppThemeColors colors;

  const _StrokeSection({required this.strokes, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Section label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '✍️ Thứ tự nét',
              style: AppTypography.headline(
                fontSize: AppFontSizes.titleMd,
                color: c.text,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Animation widget — centered
          Center(
            child: strokes.isEmpty
                ? _NoStrokeData(colors: c)
                : StrokeAnimationWidget(
                    svgStrokes: strokes,
                    colors: c,
                    size: 280,
                    autoPlay: true,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoStrokeData extends StatelessWidget {
  final AppThemeColors colors;
  const _NoStrokeData({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: colors.surfaceLowest,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.draw_outlined, size: 48, color: colors.placeholder),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chưa có dữ liệu nét',
            style: TextStyle(
              fontSize: AppFontSizes.bodyMd,
              color: colors.placeholder,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Section
// ─────────────────────────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final String char;
  final String? pinyin;
  final String? radical;
  final int strokeCount;
  final int? hskLevel;
  final String? definitionVi;
  final AppThemeColors colors;

  const _InfoSection({
    required this.char,
    this.pinyin,
    this.radical,
    required this.strokeCount,
    this.hskLevel,
    this.definitionVi,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    // Sử dụng theme hskColors thay vì hardcode local
    final hskColor = hskLevel != null && hskLevel! > 0
        ? c.hskColors[(hskLevel! - 1).clamp(0, c.hskColors.length - 1)]
        : c.primary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: c.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'char_$char',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    char,
                    style: AppTypography.hanziDisplay(fontSize: 72, color: c.text),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pinyin != null && pinyin!.isNotEmpty)
                      Text(
                        pinyin!,
                        style: AppTypography.pinyin(
                          fontSize: AppFontSizes.headlineSm,
                          color: c.primary,
                        ),
                      ),
                    if (hskLevel != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: hskColor
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadii.full),
                        ),
                        child: Text(
                          'HSK $hskLevel',
                          style: TextStyle(
                            fontSize: AppFontSizes.labelSm,
                            fontWeight: FontWeight.w700,
                            color: hskColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (definitionVi != null && definitionVi!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              definitionVi!,
              style: AppTypography.body(
                fontSize: AppFontSizes.bodyLg,
                color: c.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Số nét',
                  value: '$strokeCount',
                  icon: Icons.edit_outlined,
                  colors: c,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatTile(
                  label: 'Bộ thủ',
                  value: radical ?? '—',
                  icon: Icons.category_outlined,
                  colors: c,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final AppThemeColors colors;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSizes.labelSm,
                  color: c.placeholder,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppFontSizes.titleMd,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vocab Section — danh sách từ chứa chữ này
// ─────────────────────────────────────────────────────────────────────────────
class _VocabSection extends StatelessWidget {
  final String char;
  final List<Vocab> vocabList;
  final AppThemeColors colors;

  const _VocabSection({
    required this.char,
    required this.vocabList,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final display = vocabList.take(10).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📖 Từ chứa "$char"',
                style: AppTypography.headline(
                  fontSize: AppFontSizes.titleMd,
                  color: c.text,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  '${vocabList.length}',
                  style: TextStyle(
                    fontSize: AppFontSizes.labelSm,
                    fontWeight: FontWeight.w700,
                    color: c.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...display.map((v) => _VocabRow(vocab: v, char: char, colors: c)),
          if (vocabList.length > 10) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                '... và ${vocabList.length - 10} từ khác',
                style: TextStyle(
                  fontSize: AppFontSizes.labelMd,
                  color: c.placeholder,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VocabRow extends ConsumerWidget {
  final Vocab vocab;
  final String char;
  final AppThemeColors colors;

  const _VocabRow({
    required this.vocab,
    required this.char,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = colors;
    final meaning = vocab.primaryMeaningVi;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VocabDetailScreen(vocab: vocab),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: c.surfaceLowest,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: c.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            _HighlightedHanzi(hanzi: vocab.hanzi, targetChar: char, colors: c),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocab.pinyin,
                    style: AppTypography.pinyin(
                      fontSize: AppFontSizes.labelMd,
                      color: c.primary,
                    ),
                  ),
                  if (meaning.isNotEmpty)
                    Text(
                      meaning,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodyMd,
                        color: c.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.surfaceLow,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                'H${vocab.level}',
                style: TextStyle(
                  fontSize: AppFontSizes.labelSm,
                  color: c.placeholder,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightedHanzi extends StatelessWidget {
  final String hanzi;
  final String targetChar;
  final AppThemeColors colors;

  const _HighlightedHanzi({
    required this.hanzi,
    required this.targetChar,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    for (final ch in hanzi.split('')) {
      spans.add(
        TextSpan(
          text: ch,
          style: AppTypography.hanziUi(
            fontSize: AppFontSizes.headlineSm,
            color: ch == targetChar ? colors.primary : colors.text,
          ),
        ),
      );
    }
    return RichText(text: TextSpan(children: spans));
  }
}


