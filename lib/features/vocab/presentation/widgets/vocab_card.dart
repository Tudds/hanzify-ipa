import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import '../../domain/entities/vocab.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/utils/pos_labels.dart' show posLabelFull;
import '../screens/vocab_detail_screen.dart';

// ============================================================================
// POS helpers
// ============================================================================
Color _posColor(String pos, AppThemeColors c) =>
    c.posColors[pos] ?? const Color(0xFF9CA3AF);

// ============================================================================
// VocabCardWidget
// ============================================================================
class VocabCardWidget extends ConsumerStatefulWidget {
  final Vocab item;
  final AppThemeColors colors;
  final Function(String char)? onCharacterTap;

  const VocabCardWidget({
    super.key,
    required this.item,
    required this.colors,
    this.onCharacterTap,
  });

  @override
  ConsumerState<VocabCardWidget> createState() => _VocabCardWidgetState();
}

class _VocabCardWidgetState extends ConsumerState<VocabCardWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final item = widget.item;

    return HanzifyCard(
      variant: HanzifyCardVariant.solid,
      borderRadius: _expanded ? AppRadii.xxxl : AppRadii.xxl,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      padding: EdgeInsets.zero,
      onTap: () {
        HanzifyHaptic.select();
        setState(() => _expanded = !_expanded);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Compact View ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar với chữ Hán
                _buildHanziAvatar(item.hanzi, c),
                const SizedBox(width: AppSpacing.md),

                // Thông tin chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.pinyin,
                            style: AppTypography.label(
                              fontSize: AppFontSizes.labelLg,
                              fontWeight: FontWeight.w800,
                              color: c.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          if (item.isMastered)
                            Icon(Icons.verified_rounded,
                                size: 14, color: c.success),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.meanings.isNotEmpty
                            ? item.meanings.first.vi
                            : 'Chưa có nghĩa',
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

                // HSK Badge & Arrow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HanzifyBadge.hsk(level: item.level, colors: c),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: c.disabled,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Expanded Content ───────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuart,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: AppSpacing.lg),

                        // Các lớp nghĩa đầy đủ
                        _buildDetailedMeanings(item, c),

                        if (item.exampleSentences.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _buildExamplesSection(item.exampleSentences, c),
                        ],

                        if (item.characters.length > 1) ...[
                          const SizedBox(height: AppSpacing.md),
                          _buildCharactersSection(item.characters, c),
                        ],

                        const SizedBox(height: AppSpacing.md),
                        _buildActionButtons(item, c),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHanziAvatar(String hanzi, AppThemeColors c) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.primary.withValues(alpha: 0.15),
            c.primary.withValues(alpha: 0.05),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: c.primary.withValues(alpha: 0.1), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        hanzi.substring(0, 1), // Hiện chữ cái đầu nếu là từ ghép
        style: GoogleFonts.notoSansSc(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: c.primary,
        ),
      ),
    );
  }

  Widget _buildDetailedMeanings(Vocab item, AppThemeColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: item.meanings.map((m) {
        final color = _posColor(m.pos, c);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  posLabelFull(m.pos),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  m.vi,
                  style: AppTypography.body(
                    fontSize: AppFontSizes.bodyMd,
                    color: c.text,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExamplesSection(
      List<ExampleSentence> examples, AppThemeColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VÍ DỤ',
          style: AppTypography.label(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: c.placeholder,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...examples.take(2).map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: c.surfaceLow,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.cn,
                    style: GoogleFonts.notoSansSc(
                      fontSize: AppFontSizes.bodyMd,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  Text(
                    e.vi,
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodySm,
                      color: c.placeholder,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCharactersSection(List<String> chars, AppThemeColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHI TIẾT CHỮ',
          style: AppTypography.label(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: c.placeholder,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: chars
              .map((ch) => GestureDetector(
                    onTap: () => widget.onCharacterTap?.call(ch),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.glassSurface,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(color: c.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(ch,
                              style: GoogleFonts.notoSansSc(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: c.text)),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined,
                              size: 10, color: c.placeholder),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Vocab item, AppThemeColors c) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VocabDetailScreen(vocab: item),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary.withValues(alpha: 0.1),
              foregroundColor: c.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl)),
            ),
            child: const Text('Học ngay'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: () {
            // bookmark toggle logic could go here
          },
          icon: Icon(
              item.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: c.primary),
        ),
      ],
    );
  }
}
