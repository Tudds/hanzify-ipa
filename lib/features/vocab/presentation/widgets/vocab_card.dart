import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/vocab.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/utils/pos_labels.dart' show posLabelFull;

// ============================================================================
// POS helpers
// ============================================================================
Color _posColor(String pos, AppThemeColors c) =>
    c.posColors[pos] ?? const Color(0xFF9CA3AF);

// ============================================================================
// VocabCardWidget
// ============================================================================
class VocabCardWidget extends StatefulWidget {
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
  State<VocabCardWidget> createState() => _VocabCardWidgetState();
}

class _VocabCardWidgetState extends State<VocabCardWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();
  void _onTapUp(TapUpDetails _) {
    _scaleCtrl.reverse();
    setState(() => _expanded = !_expanded);
  }

  void _onTapCancel() => _scaleCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final item = widget.item;

    final semanticLabel = [
      item.hanzi,
      'phát âm: ${item.pinyin}',
      item.meanings.take(3).map((m) => m.vi).join(', '),
      'HSK ${item.level}',
      if (item.isMastered) 'đã thuộc',
    ].join('. ');

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: HanzifyCard(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              _buildHeader(item, c),

              const SizedBox(height: 6),

              // ── Pinyin ──────────────────────────────────────────────────
              Text(
                item.pinyin,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: c.primary,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 10),

              // ── Meanings with POS tags ──────────────────────────────────
              _buildMeanings(item, c),

              // ── Expanded section ────────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: _expanded
                    ? _buildExpandedContent(item, c)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 6),

              // ── Toggle hint ─────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: c.disabled,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _expanded ? 'Thu gọn' : 'Xem thêm',
                      style: TextStyle(fontSize: 12, color: c.disabled),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ── Sub-builders ───────────────────────────────────────────────────────────

  Widget _buildHeader(Vocab item, AppThemeColors c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hanzi + status icons
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.hanzi,
                style: GoogleFonts.notoSansSc(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 8),
              if (item.isMastered)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.verified_rounded,
                    color: c.success,
                    size: 18,
                  ),
                ),
              if (item.isBookmarked)
                Icon(Icons.bookmark_rounded, color: c.primary, size: 18),
            ],
          ),
        ),
        // HSK badge
        HanzifyBadge.hsk(level: item.level, colors: c),
      ],
    );
  }

  Widget _buildMeanings(Vocab item, AppThemeColors c) {
    if (item.meanings.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: item.meanings.map((m) => _buildMeaningRow(m, c)).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMeaningRow(Meaning m, AppThemeColors c) {
    final color = _posColor(m.pos, c);
    final label = posLabelFull(m.pos);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POS chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              m.vi,
              style: TextStyle(fontSize: 15, color: c.text, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Vocab item, AppThemeColors c) {
    final hasExamples = item.exampleSentences.isNotEmpty;
    final hasChars = item.characters.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Divider ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: c.disabled.withValues(alpha: 0.3), height: 1),
        ),

        // ── Example sentences ──────────────────────────────────────────────
        if (hasExamples) ...[
          Row(
            children: [
              Icon(Icons.format_quote_rounded, size: 14, color: c.accent),
              const SizedBox(width: 4),
              Text(
                'Ví dụ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...item.exampleSentences
              .take(2)
              .map((e) => _buildExampleSentence(e, c)),
        ] else
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Chưa có câu ví dụ.',
              style: TextStyle(
                fontSize: 13,
                color: c.disabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // ── Character breakdown ────────────────────────────────────────────
        if (hasChars) ...[
          if (hasExamples) const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, size: 14, color: c.accent),
              const SizedBox(width: 4),
              Text(
                'Các chữ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCharacterChips(item.characters, c),
        ],
      ],
    );
  }

  Widget _buildExampleSentence(ExampleSentence e, AppThemeColors c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.disabled.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chinese sentence
          if (e.cn.isNotEmpty)
            Text(
              e.cn,
              style: GoogleFonts.notoSansSc(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.text,
                height: 1.5,
              ),
            ),
          // Pinyin
          if (e.pinyin.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              e.pinyin,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: c.primary,
                height: 1.4,
              ),
            ),
          ],
          // Vietnamese translation
          if (e.vi.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              e.vi,
              style: TextStyle(
                fontSize: 13,
                color: c.placeholder,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCharacterChips(List<String> chars, AppThemeColors c) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chars
          .map(
            (ch) => Semantics(
              button: true,
              label: 'Xem chữ $ch',
              child: GestureDetector(
                onTap: () => widget.onCharacterTap?.call(ch),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ch,
                          style: GoogleFonts.notoSansSc(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: c.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_outlined, size: 12, color: c.primary.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
