import 'package:flutter/material.dart';
import '../../domain/entities/vocab.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';

// ============================================================================
// POS helpers
// ============================================================================
const _posColorMap = <String, Color>{
  'v': Color(0xFF3B82F6), // blue   – động từ
  'n': Color(0xFF10B981), // green  – danh từ
  'adj': Color(0xFFF59E0B), // amber  – tính từ
  'adv': Color(0xFF8B5CF6), // purple – trạng từ
  'prep': Color(0xFFEF4444), // red    – giới từ
  'conj': Color(0xFFEC4899), // pink   – liên từ
  'pron': Color(0xFF06B6D4), // cyan   – đại từ
  'num': Color(0xFF84CC16), // lime   – số từ
  'mw': Color(0xFF6366F1), // indigo – lượng từ
  'aux': Color(0xFFF97316), // orange – trợ động từ
  'interj': Color(0xFF14B8A6), // teal   – thán từ
};

const _posLabelMap = <String, String>{
  'v': 'Động từ (动词)',
  'n': 'Danh từ (名词)',
  'adj': 'Tính từ (形容词)',
  'adv': 'Trạng từ (副词)',
  'prep': 'Giới từ (介词)',
  'conj': 'Liên từ (连词)',
  'pron': 'Đại từ (代词)',
  'num': 'Số từ (数词)',
  'mw': 'Lượng từ (量词)',
  'aux': 'Trợ từ (助词)',
  'interj': 'Thán từ (叹词)',
  'other': 'Khác (其他)',
};

Color _posColor(String pos) => _posColorMap[pos] ?? const Color(0xFF9CA3AF);
String _posLabel(String pos) => _posLabelMap[pos] ?? pos;

Color _hskColor(int level) {
  const map = {
    1: Color(0xFF10B981),
    2: Color(0xFF3B82F6),
    3: Color(0xFFF59E0B),
    4: Color(0xFFEF4444),
    5: Color(0xFF8B5CF6),
    6: Color(0xFFEC4899),
  };
  return map[level] ?? const Color(0xFF6B7280);
}

// ============================================================================
// VocabCardWidget
// ============================================================================
class VocabCardWidget extends StatefulWidget {
  final Vocab item;
  final AppThemeColors colors;

  const VocabCardWidget({super.key, required this.item, required this.colors});

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
    final c = widget.colors;
    final item = widget.item;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                _buildHeader(item, c),

                const SizedBox(height: 6),

                // ── Pinyin ──────────────────────────────────────────────────
                Text(
                  item.pinyin,
                  style: TextStyle(
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
    final hskColor = _hskColor(item.level);
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
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 8),
              if (item.isMastered)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
              if (item.isBookmarked)
                Icon(Icons.bookmark_rounded, color: c.primary, size: 18),
            ],
          ),
        ),
        // HSK badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: hskColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: hskColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            'HSK ${item.level}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: hskColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeanings(Vocab item, AppThemeColors c) {
    // Có meanings có cấu trúc → dùng
    if (item.meanings.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: item.meanings.map((m) => _buildMeaningRow(m, c)).toList(),
      );
    }
    // Fallback: flat string
    if (item.meaning.isNotEmpty) {
      return Text(
        item.meaning,
        style: TextStyle(fontSize: 15, color: c.placeholder),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMeaningRow(Meaning m, AppThemeColors c) {
    final color = _posColor(m.pos);
    final label = _posLabel(m.pos);
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
              style: TextStyle(
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
              style: TextStyle(fontSize: 13, color: c.primary, height: 1.4),
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
            (ch) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.primary.withValues(alpha: 0.25)),
              ),
              child: Text(
                ch,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
