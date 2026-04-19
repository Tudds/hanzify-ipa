import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/utils/pos_labels.dart';
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';
import 'package:hanzify/core/widgets/feedback_border_widget.dart';
import 'package:hanzify/core/widgets/flashcard_flip_widget.dart';
import 'package:hanzify/core/widgets/highlighted_text.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';

class FlashcardStudyView extends StatefulWidget {
  final List<Vocab> cards;
  final int currentIndex;
  final bool? scoreFeedback;
  final Function(int) onScore;
  final PageController pageController;
  final Widget header;
  final ValueChanged<int>? onPageChanged;

  const FlashcardStudyView({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.scoreFeedback,
    required this.onScore,
    required this.pageController,
    required this.header,
    this.onPageChanged,
  });

  @override
  State<FlashcardStudyView> createState() => _FlashcardStudyViewState();
}

class _FlashcardStudyViewState extends State<FlashcardStudyView> {
  // Trạng thái lật thẻ: false = mặt trước (Hán tự), true = mặt sau (nghĩa)
  bool _revealed = false;

  // Các hàm callback để cập nhật trạng thái lật thẻ từ widget con
  void _onRevealed() => setState(() => _revealed = true);
  void _onUnrevealed() => setState(() => _revealed = false);

  void _onPageChanged(int index) {
    setState(() => _revealed = false);
    widget.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: widget.header,
          ),
          Expanded(
            child: PageView.builder(
              controller: widget.pageController,
              // Khi đã lật thẻ (xem nghĩa), khóa lướt trang để buộc người dùng phải chọn mức độ thuộc bài
              physics: _revealed
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: widget.cards.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _CardPage(
                  vocab: widget.cards[index],
                  isCurrentPage: index == widget.currentIndex,
                  scoreFeedback: widget.scoreFeedback,
                  onRevealed: _onRevealed,
                  onUnrevealed: _onUnrevealed,
                );
              },
            ),
          ),
          // Grade buttons — appear after reveal
          // Reserve space to prevent card jumping (100px to avoid overflow)
          SizedBox(
            height: 100,
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              switchInCurve: AppCurves.enter,
              switchOutCurve: AppCurves.exit,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _revealed
                  ? _GradeButtons(
                      key: const ValueKey('buttons'),
                      onScore: widget.onScore,
                      colors: c,
                    )
                  : const SizedBox(key: ValueKey('empty')),
            ),
          ),
          SizedBox(height: safeBottom + AppSpacing.xs),
        ],
      ),
    );
  }
}

// ── Single card page ──────────────────────────────────────────────────────────

class _CardPage extends StatelessWidget {
  final Vocab vocab;
  final bool isCurrentPage;
  final bool? scoreFeedback;
  final VoidCallback onRevealed;
  final VoidCallback onUnrevealed;

  const _CardPage({
    required this.vocab,
    required this.isCurrentPage,
    required this.scoreFeedback,
    required this.onRevealed,
    required this.onUnrevealed,
  });

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final size = MediaQuery.sizeOf(context);
    // Tính toán chiều cao thẻ dựa trên tỉ lệ màn hình (62%)
    final cardH = size.height * 0.62;
    // Tính toán chiều ngang thẻ trừ đi khoảng đệm (24pt mỗi bên)
    final cardW = size.width - (AppSpacing.xl * 2);

    FeedbackState feedbackState = FeedbackState.none;
    if (isCurrentPage && scoreFeedback != null) {
      feedbackState = scoreFeedback! ? FeedbackState.correct : FeedbackState.wrong;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: SizedBox(
        height: cardH,
        width: cardW,
        child: FeedbackBorderWidget(
          state: feedbackState,
          borderRadius: AppRadii.xxl,
          correctColor: c.studyCorrect,
          wrongColor: c.studyWrong,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            child: FlashcardFlipWidget(
              key: ValueKey(vocab.id),
              onRevealed: onRevealed,
              onUnrevealed: onUnrevealed,
              // Giao diện mặt trước
              front: _FrontFace(vocab: vocab, cardH: cardH, cardW: cardW, colors: c),
              // Giao diện mặt sau
              back: _BackFace(vocab: vocab, cardH: cardH, cardW: cardW, colors: c),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Front face ────────────────────────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  final Vocab vocab;
  final double cardH;
  final double cardW;
  final AppThemeColors colors;

  const _FrontFace({
    required this.vocab,
    required this.cardH,
    required this.cardW,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Semantics(
      label: '${vocab.hanzi}, phát âm: ${vocab.pinyin}. Nhấn để xem nghĩa.',
      child: Container(
        height: cardH,
        width: cardW,
        decoration: BoxDecoration(
          color: c.glassSurface,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(color: c.glassBorder),
          boxShadow: c.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              vocab.hanzi,
              textAlign: TextAlign.center,
              style: AppTypography.hanziDisplay(
                // Logic co giãn cỡ chữ theo số lượng ký tự để không bị tràn thẻ
                fontSize: vocab.hanzi.length <= 2
                    ? AppFontSizes.hanziStudy // 1-2 chữ dùng cỡ cực đại
                    : vocab.hanzi.length == 3
                        ? 80.0 // 3 chữ dùng cỡ trung bình
                        : AppFontSizes.displayMd, // 4 chữ trở lên dùng cỡ nhỏ
                color: c.text,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded,
                    size: 16, color: c.placeholder),
                const SizedBox(width: 6),
                Text(
                  'Nhấn để xem nghĩa',
                  style: AppTypography.label(
                    fontSize: AppFontSizes.labelMd,
                    color: c.placeholder,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Back face ─────────────────────────────────────────────────────────────────

class _BackFace extends StatelessWidget {
  final Vocab vocab;
  final double cardH;
  final double cardW;
  final AppThemeColors colors;

  const _BackFace({
    required this.vocab,
    required this.cardH,
    required this.cardW,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final groupedMeanings = vocab.groupedByPos;
    final meaningLabel = vocab.meanings.take(3).map((m) => m.vi).join(', ');

    return Semantics(
      label: '${vocab.hanzi}, phát âm: ${vocab.pinyin}. Nghĩa: $meaningLabel.',
      child: Container(
      height: cardH,
      width: cardW,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.glassSurface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: c.glassBorder),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          // ── Header: Hanzi + Pinyin ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
            child: Column(
              children: [
                Text(
                  vocab.hanzi,
                  style: AppTypography.hanziUi(
                    fontSize: AppFontSizes.displaySm,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: c.accentGradient,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Text(
                    vocab.pinyin,
                    style: AppTypography.pinyin(
                      fontSize: AppFontSizes.titleMd,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: c.outlineVariant, height: 1),
          // ── Nội dung chính: Nghĩa & Câu ví dụ (có thể cuộn) ──────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duyệt qua danh sách nghĩa đã được nhóm theo loại từ (POS)
                  ...groupedMeanings.entries.map(
                    (entry) => _MeaningGroup(
                      pos: entry.key,
                      meanings: entry.value,
                      colors: c,
                    ),
                  ),
                  // Hiển thị phần ví dụ nếu có dữ liệu
                  if (vocab.exampleSentences.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _ExamplesSection(vocab: vocab, colors: c),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _MeaningGroup extends StatelessWidget {
  final String pos;
  final List<dynamic> meanings;
  final AppThemeColors colors;

  const _MeaningGroup({
    required this.pos,
    required this.meanings,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final posColor = c.posColors[pos] ?? c.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceLow.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border(left: BorderSide(color: posColor, width: 4)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            posLabelFull(pos).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: posColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          ...meanings.map(
            (m) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: posColor.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      m.vi,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodyLg,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamplesSection extends StatelessWidget {
  final Vocab vocab;
  final AppThemeColors colors;

  const _ExamplesSection({required this.vocab, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_quote_rounded, size: 14, color: c.placeholder),
            const SizedBox(width: 4),
            Text(
              'VÍ DỤ',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: c.placeholder,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...vocab.exampleSentences.take(2).map(
          (ex) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Câu ví dụ tiếng Trung (tự động highlight từ đang học)
                HanzifyHighlightedText(
                  text: ex.cn,
                  highlight: vocab.hanzi,
                  baseStyle: AppTypography.hanziUi(fontSize: 14, color: c.text),
                  colors: c,
                ),
                const SizedBox(height: 2),
                HanzifyHighlightedText(
                  text: ex.pinyin,
                  highlight: vocab.pinyin,
                  baseStyle:
                      AppTypography.pinyin(fontSize: 12, color: c.primary),
                  colors: c,
                ),
                const SizedBox(height: 2),
                Text(
                  ex.vi,
                  style: AppTypography.body(
                      fontSize: 12, color: c.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Grade buttons ─────────────────────────────────────────────────────────────

class _GradeButtons extends StatelessWidget {
  final Function(int) onScore;
  final AppThemeColors colors;

  const _GradeButtons({super.key, required this.onScore, required this.colors});

  static const _grades = [
    (score: 0, label: 'Quên', emoji: '😵', colorKey: 'again'),
    (score: 3, label: 'Khó', emoji: '😰', colorKey: 'hard'),
    (score: 4, label: 'Tốt', emoji: '😊', colorKey: 'good'),
    (score: 5, label: 'Dễ', emoji: '🤩', colorKey: 'easy'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final gradeColors = {
      'again': c.studyWrong,
      'hard': c.warning,
      'good': c.primary,
      'easy': c.studyCorrect,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: _grades.map((g) {
          final color = gradeColors[g.colorKey] ?? c.primary;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: _GradeBtn(
                score: g.score,
                label: g.label,
                emoji: g.emoji,
                color: color,
                surface: c.surface,
                onTap: onScore,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GradeBtn extends StatefulWidget {
  final int score;
  final String label;
  final String emoji;
  final Color color;
  final Color surface;
  final Function(int) onTap;

  const _GradeBtn({
    required this.score,
    required this.label,
    required this.emoji,
    required this.color,
    required this.surface,
    required this.onTap,
  });

  @override
  State<_GradeBtn> createState() => _GradeBtnState();
}

class _GradeBtnState extends State<_GradeBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap(widget.score);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        // Hiệu ứng "lún" nhẹ khi nhấn vào nút (feedback vật lý)
        scale: _pressed ? 0.94 : 1.0,
        duration: AppDurations.micro,
        curve: AppCurves.enter,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: widget.color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
