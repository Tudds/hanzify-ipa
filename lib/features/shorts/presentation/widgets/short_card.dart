import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../application/shorts_session_controller.dart';
import '../../domain/short_feed_item.dart';
import 'short_context_cards.dart';
import 'short_dialogue_card.dart';
import 'short_quiz_cards.dart';

class ShortCard extends StatelessWidget {
  const ShortCard({
    super.key,
    required this.item,
    required this.index,
    required this.totalCount,
    required this.selectedAnswers,
    required this.correctCount,
    required this.incorrectCount,
    required this.active,
    required this.controller,
    required this.performance,
    required this.onShowVocabDetail,
    required this.onShowGrammarDetail,
  });

  final ShortFeedItem item;
  final int index;
  final int totalCount;
  final Map<String, String> selectedAnswers;
  final int correctCount;
  final int incorrectCount;
  final bool active;
  final ShortsSessionController controller;
  final bool performance;
  final ShowShortVocabDetail onShowVocabDetail;
  final ShowShortGrammarDetail onShowGrammarDetail;

  @override
  Widget build(BuildContext context) {
    final body = _CardBody(
      key: ValueKey(item.id),
      item: item,
      selectedAnswers: selectedAnswers,
      controller: controller,
      active: active,
      performance: performance,
      onShowVocabDetail: onShowVocabDetail,
      onShowGrammarDetail: onShowGrammarDetail,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackSize = MediaQuery.sizeOf(context);
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackSize.width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : fallbackSize.height;
        final horizontalPadding = (width * 0.045).clamp(12.0, 28.0).toDouble();
        final topPadding = (height * 0.018).clamp(8.0, 20.0).toDouble();
        final bottomPadding = (height * 0.12).clamp(72.0, 118.0).toDouble();
        final maxCardWidth = (width - horizontalPadding * 2)
            .clamp(320.0, 640.0)
            .toDouble();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCardWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressHeader(index: index, totalCount: totalCount, tags: item.tags),
                    Expanded(
                      child: Center(
                        child: _CardBodyViewport(
                          scrollable: _needsInnerScroll(item.payload),
                          child: performance || !active
                              ? body
                              : body
                                    .animate()
                                    .fadeIn(
                                      duration: MotionTokens.fast,
                                      curve: Curves.easeOut,
                                    )
                                    .slideY(
                                      begin: 0.04,
                                      end: 0,
                                      duration: MotionTokens.medium,
                                    ),
                        ),
                      ),
                    ),
                    _ScoreFooter(
                      correct: correctCount,
                      incorrect: incorrectCount,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _needsInnerScroll(Object payload) {
    return payload is ShortVocabContext ||
        payload is ShortQuickQuiz ||
        payload is ShortGrammarContext ||
        payload is ShortDialogue ||
        payload is ShortMiniTest;
  }
}

class _CardBodyViewport extends StatelessWidget {
  const _CardBodyViewport({required this.scrollable, required this.child});

  final bool scrollable;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!scrollable) return child;
    return SingleChildScrollView(child: child);
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.index,
    required this.totalCount,
    required this.tags,
  });

  final int index;
  final int totalCount;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final progress = totalCount > 0 ? (index + 1) / totalCount : 0.0;

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.primaryContainer.withValues(alpha:0.7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              '#${index + 1}/$totalCount',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuad,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: color.primary.withValues(alpha:0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color.primary),
                  );
                },
              ),
            ),
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(width: 10),
          Flexible(
            flex: 0,
            child: Text(
              tags.first,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    super.key,
    required this.item,
    required this.selectedAnswers,
    required this.controller,
    required this.active,
    required this.performance,
    required this.onShowVocabDetail,
    required this.onShowGrammarDetail,
  });

  final ShortFeedItem item;
  final Map<String, String> selectedAnswers;
  final ShortsSessionController controller;
  final bool active;
  final bool performance;
  final ShowShortVocabDetail onShowVocabDetail;
  final ShowShortGrammarDetail onShowGrammarDetail;

  @override
  Widget build(BuildContext context) {
    final payload = item.payload;
    return switch (payload) {
      ShortVocabContext() => ShortVocabContextView(
        payload: payload,
        active: active,
        performance: performance,
        onShowVocabDetail: onShowVocabDetail,
      ),
      ShortGrammarContext() => ShortGrammarContextView(
        payload: payload,
        active: active,
        performance: performance,
        onShowGrammarDetail: onShowGrammarDetail,
      ),
      ShortQuickQuiz() => ShortQuizView(
        itemId: item.id,
        quiz: payload,
        selected: selectedAnswers[item.id],
        onSelect: (answer) => controller.selectAnswer(item, answer),
        onTimeout: () => controller.selectQuizAnswer(
          itemId: item.id,
          answer: '',
          correctAnswer: payload.answer,
          quiz: payload,
        ),
        active: active,
        performance: performance,
      ),
      ShortDialogue() => ShortDialogueView(
        payload: payload,
        active: active,
        performance: performance,
      ),
      ShortMiniTest() => ShortMiniTestView(
        itemId: item.id,
        payload: payload,
        selectedAnswers: selectedAnswers,
        controller: controller,
        active: active,
        performance: performance,
      ),
      ShortSummary() => _SummaryView(payload: payload),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.payload});

  final ShortSummary payload;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textTheme = Theme.of(context).textTheme;
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : fallbackWidth;
        final compact = width < 430;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SvgPicture.asset(
                'assets/images/gen_shorts_summary.svg',
                width: double.infinity,
                height: (width * 0.32).clamp(116.0, 168.0).toDouble(),
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              payload.title,
              style:
                  (compact ? textTheme.headlineSmall : textTheme.displaySmall)
                      ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Text(
              payload.message,
              style: (compact ? textTheme.titleMedium : textTheme.titleLarge)
                  ?.copyWith(height: 1.3),
            ),
          ],
        );
      },
    );
  }
}

class _ScoreFooter extends StatelessWidget {
  const _ScoreFooter({required this.correct, required this.incorrect});

  final int correct;
  final int incorrect;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 20, color: color.primary),
        const SizedBox(width: 6),
        Text('$correct'),
        const SizedBox(width: 18),
        Icon(Icons.cancel_rounded, size: 20, color: color.error),
        const SizedBox(width: 6),
        Text('$incorrect'),
        const Spacer(),
        const Icon(Icons.keyboard_arrow_up_rounded),
        const Icon(Icons.keyboard_arrow_down_rounded),
      ],
    );
  }
}
