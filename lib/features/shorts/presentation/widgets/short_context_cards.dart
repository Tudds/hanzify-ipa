import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../domain/short_feed_item.dart';

typedef ShowShortVocabDetail = Future<void> Function(String vocabId);
typedef ShowShortGrammarDetail = Future<void> Function(String grammarId);

double _resolvedWidth(BuildContext context, BoxConstraints constraints) {
  if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
    return constraints.maxWidth;
  }
  return MediaQuery.sizeOf(context).width;
}

double _responsiveSpace(double width, double factor, double min, double max) {
  return (width * factor).clamp(min, max).toDouble();
}

class ShortGrammarContextView extends StatelessWidget {
  const ShortGrammarContextView({
    super.key,
    required this.payload,
    required this.active,
    required this.performance,
    required this.onShowGrammarDetail,
  });

  final ShortGrammarContext payload;
  final bool active;
  final bool performance;
  final ShowShortGrammarDetail onShowGrammarDetail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textTheme = Theme.of(context).textTheme;
        final colors = Theme.of(context).colorScheme;
        final width = _resolvedWidth(context, constraints);
        final compact = width < 430;
        final contentPadding = _responsiveSpace(width, 0.05, 14, 22);
        final verticalPadding = _responsiveSpace(width, 0.045, 14, 20);
        final sectionGap = _responsiveSpace(width, 0.045, 14, 24);
        final examples = payload.examples.take(2).toList(growable: false);
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Ngữ pháp',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              payload.title,
              style: (compact ? textTheme.titleLarge : textTheme.headlineSmall)
                  ?.copyWith(height: 1.2, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _GrammarFormula(payload: payload),
            if (payload.explanation.isNotEmpty) ...[
              SizedBox(height: compact ? 14 : 18),
              Text(
                payload.explanation,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (examples.isNotEmpty) ...[
              SizedBox(height: sectionGap),
              Text(
                'Ví dụ',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (var index = 0; index < examples.length; index++) ...[
                performance || !active
                    ? _GrammarExampleTile(example: examples[index])
                    : _GrammarExampleTile(example: examples[index])
                          .animate()
                          .fadeIn(
                            duration: MotionTokens.fast,
                            delay: (60 * index).ms,
                          )
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            duration: MotionTokens.medium,
                          ),
                const SizedBox(height: 10),
              ],
            ],
            if (payload.targetGrammarId.isNotEmpty) ...[
              SizedBox(height: compact ? 6 : 10),
              _ShortDetailCtaButton(
                icon: Icons.account_tree_outlined,
                label: 'Chi tiết ngữ pháp',
                active: active,
                performance: performance,
                onPressed: () {
                  onShowGrammarDetail(payload.targetGrammarId);
                },
              ),
            ],
          ],
        );
        return ShortCardVectorFrame(
          assetPath: 'assets/images/shorts_grammar_card_frame.svg',
          opacity: 0.44,
          showArtwork: active && !performance,
          performance: performance,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: contentPadding,
              vertical: verticalPadding,
            ),
            child: content,
          ),
        );
      },
    );
  }
}

class ShortVocabContextView extends StatelessWidget {
  const ShortVocabContextView({
    super.key,
    required this.payload,
    required this.active,
    required this.performance,
    required this.onShowVocabDetail,
  });

  final ShortVocabContext payload;
  final bool active;
  final bool performance;
  final ShowShortVocabDetail onShowVocabDetail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textTheme = Theme.of(context).textTheme;
        final color = Theme.of(context).colorScheme;
        final width = _resolvedWidth(context, constraints);
        final compact = width < 430;
        final contentPadding = _responsiveSpace(width, 0.05, 14, 22);
        final verticalPadding = _responsiveSpace(width, 0.05, 14, 22);
        final majorGap = _responsiveSpace(width, 0.06, 16, 28);
        final hanziStyle =
            (compact ? textTheme.displayMedium : textTheme.displayLarge)
                ?.copyWith(height: 1.05, fontWeight: FontWeight.w900);
        final hanziRow = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  payload.hanzi,
                  textAlign: TextAlign.center,
                  style: hanziStyle,
                ),
              ),
            ),
            if (payload.audioUrl != null) ...[
              const SizedBox(width: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: AudioPlayButton(
                  url: payload.audioUrl,
                  size: compact ? 34 : 38,
                  color: color.onPrimaryContainer,
                ),
              ),
            ],
          ],
        );
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showsSituation) ...[
              Text(
                payload.situation,
                textAlign: TextAlign.center,
                style: (compact ? textTheme.titleMedium : textTheme.titleLarge)
                    ?.copyWith(
                      height: 1.25,
                      color: color.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: majorGap),
            ],
            performance || !active
                ? hanziRow
                : hanziRow
                      .animate()
                      .fadeIn(duration: MotionTokens.fast)
                      .slideY(
                        begin: 0.05,
                        end: 0,
                        duration: MotionTokens.medium,
                      ),
            const SizedBox(height: 12),
            if (payload.pinyin.isNotEmpty)
              performance || !active
                  ? Text(
                      payload.pinyin,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Text(
                      payload.pinyin,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(
                      delay: 80.ms,
                      duration: MotionTokens.fast,
                    ),
            SizedBox(height: compact ? 14 : 18),
            performance || !active
                ? Text(
                    payload.vi,
                    textAlign: TextAlign.center,
                    style: compact
                        ? textTheme.titleLarge
                        : textTheme.headlineSmall,
                  )
                : Text(
                    payload.vi,
                    textAlign: TextAlign.center,
                    style: compact
                        ? textTheme.titleLarge
                        : textTheme.headlineSmall,
                  ).animate().fadeIn(
                    delay: 160.ms,
                    duration: MotionTokens.fast,
                  ),
            if (payload.targetVocabId.isNotEmpty) ...[
              SizedBox(height: compact ? 18 : 24),
              _ShortDetailCtaButton(
                icon: Icons.menu_book_outlined,
                label: 'Chi tiết từ',
                active: active,
                performance: performance,
                onPressed: () {
                  onShowVocabDetail(payload.targetVocabId);
                },
              ),
            ],
          ],
        );
        if (!_usesCollocationFrame) return content;
        return ShortCardVectorFrame(
          assetPath: 'assets/images/shorts_collocation_card_frame.svg',
          opacity: 0.46,
          showArtwork: active && !performance,
          performance: performance,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: contentPadding,
              vertical: verticalPadding,
            ),
            child: content,
          ),
        );
      },
    );
  }

  bool get _usesCollocationFrame {
    return payload.situation.startsWith('Câu mẫu để luyện') ||
        payload.situation.contains('collocation') ||
        payload.situation.startsWith('Một ví dụ khác');
  }

  bool get _showsSituation {
    if (payload.situation.trim().isEmpty) return false;
    return payload.situation != 'Câu mẫu để luyện từ vựng trong ngữ cảnh.' &&
        payload.situation !=
            'Câu mới từ collocation + frame để luyện trong ngữ cảnh.';
  }
}

class ShortCardVectorFrame extends StatelessWidget {
  const ShortCardVectorFrame({
    super.key,
    required this.assetPath,
    required this.opacity,
    required this.child,
    this.accentHeight = 44,
    this.showArtwork = true,
    this.performance = false,
  });

  final String assetPath;
  final double opacity;
  final Widget child;
  final double accentHeight;
  final bool showArtwork;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolvedWidth(context, constraints);
        final resolvedAccentHeight = accentHeight < 32
            ? _responsiveSpace(width, 0.055, 18, 24)
            : _responsiveSpace(width, 0.1, 30, accentHeight);
        final artworkWidth = _responsiveSpace(width, 0.34, 104, 180);
        final artworkHeight = artworkWidth * 4 / 3;
        final shouldShowArtwork = showArtwork && width >= 320;

        final cardDecoration = BoxDecoration(
          color: colors.surfaceContainerHigh.withValues(alpha:performance ? 0.98 : 0.72),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha:performance ? 0.35 : 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.24),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        );

        Widget mainContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: resolvedAccentHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha:
                        0.24,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: colors.outlineVariant.withValues(alpha:
                            0.15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (shouldShowArtwork)
                    Positioned(
                      right: -artworkWidth * 0.1,
                      top: resolvedAccentHeight - artworkHeight * 0.5,
                      width: artworkWidth,
                      height: artworkHeight,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: opacity,
                          child: SvgPicture.asset(
                            assetPath,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: _responsiveSpace(width, 0.045, 14, 22),
                    top: (resolvedAccentHeight / 2).floorToDouble(),
                    right: shouldShowArtwork ? artworkWidth * 0.6 : 18,
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.primary.withValues(alpha:0.18),
                    ),
                  ),
                ],
              ),
            ),
            child,
          ],
        );

        if (performance) {
          return Container(
            width: double.infinity,
            decoration: cardDecoration,
            child: mainContent,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              decoration: cardDecoration,
              child: mainContent,
            ),
          ),
        );
      },
    );
  }
}

class _GrammarFormula extends StatelessWidget {
  const _GrammarFormula({required this.payload});

  final ShortGrammarContext payload;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final parts = payload.formulaParts
        .where((part) => part.text.trim().isNotEmpty)
        .toList(growable: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: parts.isEmpty
          ? Text(
              payload.structure,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w800,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final part in parts)
                  _FormulaPartChip(
                    text: part.text,
                    highlighted: part.isHighlighted,
                  ),
              ],
            ),
    );
  }
}

class _FormulaPartChip extends StatelessWidget {
  const _FormulaPartChip({required this.text, required this.highlighted});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (text == '+') {
      return Text(
        '+',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colors.onSecondaryContainer.withValues(alpha: 0.68),
          fontWeight: FontWeight.w800,
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? colors.primary : colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted
              ? colors.primary
              : colors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: highlighted ? colors.onPrimary : colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _GrammarExampleTile extends StatelessWidget {
  const _GrammarExampleTile({required this.example});

  final ShortGrammarExample example;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.hanzi,
            style: textTheme.titleLarge?.copyWith(
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (example.pinyin.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(example.pinyin, style: TextStyle(color: colors.primary)),
          ],
          if (example.vi.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(example.vi, style: textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}

class _ShortDetailCtaButton extends StatelessWidget {
  const _ShortDetailCtaButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.performance,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool performance;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolvedWidth(context, constraints);
        final compact = width < 430;
        final button = SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: _responsiveSpace(width, 0.045, 14, 18),
                vertical: compact ? 13 : 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        );

        if (performance || !active) return button;
        return button
            .animate()
            .fadeIn(duration: MotionTokens.fast, delay: 180.ms)
            .slideY(begin: 0.08, end: 0, duration: MotionTokens.medium);
      },
    );
  }
}
