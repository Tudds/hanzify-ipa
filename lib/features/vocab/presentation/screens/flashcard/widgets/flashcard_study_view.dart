import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/utils/pos_labels.dart';
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';
import 'package:hanzify/core/widgets/highlighted_text.dart';
import 'package:hanzify/core/widgets/hanzify_progress_bar.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';

class FlashcardStudyView extends StatefulWidget {
  final List<Vocab> cards;
  final int currentIndex;
  final bool isFlipped;
  final bool? scoreFeedback;
  final VoidCallback onFlip;
  final Function(int) onScore;
  final PageController pageController;
  final Animation<double> flipAnim;
  final Widget header;
  final ValueChanged<int>? onPageChanged;

  const FlashcardStudyView({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.isFlipped,
    required this.scoreFeedback,
    required this.onFlip,
    required this.onScore,
    required this.pageController,
    required this.flipAnim,
    required this.header,
    this.onPageChanged,
  });

  @override
  State<FlashcardStudyView> createState() => _FlashcardStudyViewState();
}

class _FlashcardStudyViewState extends State<FlashcardStudyView> {
  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW - 48;
    final progress = (widget.currentIndex + 1) / widget.cards.length;

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          widget.header,
          HanzifyProgressBar(
            progress: progress,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            borderRadius: 3,
          ),
          Expanded(
            child: PageView.builder(
              controller: widget.pageController,
              physics: widget.isFlipped
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: widget.cards.length,
              onPageChanged: widget.onPageChanged,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: widget.pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (widget.pageController.position.haveDimensions) {
                      value = widget.pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Center(
                      child: Transform.scale(
                        scale: Curves.easeOut.transform(value),
                        child: Opacity(
                          opacity: value,
                          child: _buildFlipCard(
                            widget.cards[index],
                            c,
                            cardW,
                            index,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildScoreButtons(c),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFlipCard(
    Vocab vocab,
    AppThemeColors c,
    double cardW,
    int index,
  ) {
    if (!widget.isFlipped) {
      return GestureDetector(
        onTap: widget.onFlip,
        child: Hero(
          tag: 'flashcard_hero_${vocab.id}',
          child: Material(
            color: Colors.transparent,
            child: _buildCardSide(vocab, c, cardW, true),
          ),
        ),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onFlip,
          child: AnimatedBuilder(
            animation: widget.flipAnim,
            builder: (_, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(widget.flipAnim.value * pi),
              child: widget.flipAnim.value < 0.5
                  ? _buildCardSide(vocab, c, cardW, true)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildCardSide(vocab, c, cardW, false),
                    ),
            ),
          ),
        ),
        _buildScoreFeedbackOverlay(c),
      ],
    );
  }

  Widget _buildCardSide(
    Vocab vocab,
    AppThemeColors c,
    double cardW,
    bool isFront,
  ) {
    if (isFront) {
      return Container(
        width: cardW,
        height: cardW * 1.3,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: c.cardShadow,
        ),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Text(
              vocab.hanzi,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansSc(
                fontSize: vocab.hanzi.length > 3 ? 48 : 84,
                fontWeight: FontWeight.w700,
                color: c.text,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
      );
    }

    // Back Side - Premium Redesign
    // Use centralized VocabMeaningHelper extension for grouping
    final groupedMeanings = vocab.groupedByPos;

    return Container(
      width: cardW,
      height: cardW * 1.3,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: c.cardShadow,
      ),
      child: Stack(
        children: [
          // Subtle background decoration icon
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 100,
              color: c.primary.withValues(alpha: 0.03),
            ),
          ),
          Column(
            children: [
              // ── Header Section ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  bottom: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      c.primary.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      vocab.hanzi,
                      style: AppTypography.hanziUi(
                        fontSize: 42,
                        color: c.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.full),
                      ),
                      child: Text(
                        vocab.pinyin,
                        style: AppTypography.pinyin(
                          fontSize: AppFontSizes.labelLg,
                          fontWeight: FontWeight.w700,
                          color: c.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Content ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      // Grouped Meanings
                      if (vocab.meanings.isNotEmpty)
                        ...groupedMeanings.entries.map((entry) {
                          final pos = entry.key;
                          final meanings = entry.value;
                          final posColor = c.posColors[pos] ?? c.primary;

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              color: c.surfaceLow.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(AppRadii.xl),
                              border: Border(
                                left: BorderSide(color: posColor, width: 4),
                              ),
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
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.sm,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: posColor.withValues(
                                              alpha: 0.5,
                                            ),
                                            shape: BoxShape.circle,
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
                        }),

                      // Example Sentences
                      if (vocab.exampleSentences.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: 16,
                              color: c.placeholder,
                            ),
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
                        ...vocab.exampleSentences
                            .take(2)
                            .map(
                              (ex) => Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: c.background,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.lg,
                                  ),
                                  border: Border.all(
                                    color: c.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HanzifyHighlightedText(
                                      text: ex.cn,
                                      highlight: vocab.hanzi,
                                      baseStyle: AppTypography.hanziUi(
                                        fontSize: 14,
                                        color: c.text,
                                      ),
                                      colors: c,
                                    ),
                                    const SizedBox(height: 2),
                                    HanzifyHighlightedText(
                                      text: ex.pinyin,
                                      highlight: vocab.pinyin,
                                      baseStyle: AppTypography.pinyin(
                                        fontSize: 12,
                                        color: c.primary,
                                      ),
                                      colors: c,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ex.vi,
                                      style: AppTypography.body(
                                        fontSize: 12,
                                        color: c.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreFeedbackOverlay(AppThemeColors c) {
    if (widget.scoreFeedback == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: (widget.scoreFeedback! ? c.success : c.danger).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Icon(
              widget.scoreFeedback!
                  ? Icons.check_circle_rounded
                  : Icons.replay_rounded,
              size: 80,
              color: (widget.scoreFeedback! ? c.success : c.danger).withValues(
                alpha: 0.5,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.0, 1.0),
                  duration: 260.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 180.ms),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreButtons(AppThemeColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildGradeBtn(0, '😵', c.danger, c),
          const SizedBox(width: AppSpacing.sm),
          _buildGradeBtn(3, '😰', c.warning, c),
          const SizedBox(width: AppSpacing.sm),
          _buildGradeBtn(4, '😊', c.primary, c),
          const SizedBox(width: AppSpacing.sm),
          _buildGradeBtn(5, '🤩', c.success, c),
        ],
      ),
    );
  }

  Widget _buildGradeBtn(
    int score,
    String emoji,
    Color color,
    AppThemeColors c,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onScore(score),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                ['Quên', 'Khó', 'Tốt', 'Dễ'][score == 0 ? 0 : score - 2],
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
