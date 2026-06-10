import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../motion/motion_tokens.dart';

Future<void> showLearningQuizFeedbackDialog({
  required BuildContext context,
  required String prompt,
  required String answer,
  required String? selectedAnswer,
  required bool isCorrect,
  required bool timedOut,
  String? promptPinyin,
  String? meaning,
  String? explanation,
  String noSelectionText = 'Chưa chọn đáp án',
  bool performance = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: LearningQuizFeedbackDialog(
        prompt: prompt,
        promptPinyin: promptPinyin,
        answer: answer,
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
        timedOut: timedOut,
        meaning: meaning,
        explanation: explanation,
        noSelectionText: noSelectionText,
        performance: performance,
      ),
    ),
  );
}

class LearningQuizFeedbackDialog extends StatelessWidget {
  const LearningQuizFeedbackDialog({
    super.key,
    required this.prompt,
    required this.answer,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timedOut,
    this.promptPinyin,
    this.meaning,
    this.explanation,
    this.noSelectionText = 'Chưa chọn đáp án',
    this.performance = false,
  });

  final String prompt;
  final String? promptPinyin;
  final String answer;
  final String? selectedAnswer;
  final bool isCorrect;
  final bool timedOut;
  final String? meaning;
  final String? explanation;
  final String noSelectionText;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final toneColor = timedOut
        ? colors.tertiary
        : isCorrect
        ? colors.primary
        : colors.error;
    final title = timedOut
        ? 'Hết giờ'
        : isCorrect
        ? 'Chính xác'
        : 'Chưa đúng';
    final icon = timedOut
        ? Icons.timer_outlined
        : isCorrect
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        maxWidth: 380,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FeedbackHero(
              title: title,
              toneColor: toneColor,
              icon: icon,
              performance: performance,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FeedbackBlock(
                      label: 'Câu hỏi',
                      compact: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (promptPinyin?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 4),
                            Text(
                              promptPinyin!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FeedbackBlock(
                      label: 'Đáp án đúng',
                      toneColor: isCorrect ? colors.primary : colors.error,
                      icon: Icons.flag_rounded,
                      child: Text(
                        answer,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (meaning?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 10),
                      _FeedbackBlock(
                        label: 'Nghĩa',
                        toneColor: colors.primary,
                        icon: Icons.translate_rounded,
                        child: Text(meaning!),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _FeedbackBlock(
                      label: 'Bạn chọn',
                      toneColor: selectedAnswer == null
                          ? colors.tertiary
                          : isCorrect
                          ? colors.primary
                          : colors.error,
                      icon: selectedAnswer == null
                          ? Icons.hourglass_empty_rounded
                          : Icons.touch_app_rounded,
                      child: Text(selectedAnswer ?? noSelectionText),
                    ),
                    if (explanation?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 10),
                      _FeedbackBlock(
                        label: 'Giải thích',
                        icon: Icons.lightbulb_outline_rounded,
                        child: Text(explanation!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      ),
    );

    if (performance) return content;
    return content
        .animate()
        .fadeIn(duration: MotionTokens.fast)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: MotionTokens.medium,
          curve: Curves.easeOutBack,
        )
        .slideY(
          begin: 0.04,
          end: 0,
          duration: MotionTokens.medium,
          curve: Curves.easeOutCubic,
        );
  }
}

class _FeedbackHero extends StatelessWidget {
  const _FeedbackHero({
    required this.title,
    required this.toneColor,
    required this.icon,
    required this.performance,
  });

  final String title;
  final Color toneColor;
  final IconData icon;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mark = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: toneColor.withValues(alpha: 0.34)),
      ),
      child: Icon(icon, color: toneColor, size: 34),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        performance
            ? mark
            : mark
                  .animate()
                  .scale(
                    begin: const Offset(0.72, 0.72),
                    end: const Offset(1, 1),
                    duration: MotionTokens.medium,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: MotionTokens.fast),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: toneColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _FeedbackBlock extends StatelessWidget {
  const _FeedbackBlock({
    required this.label,
    required this.child,
    this.toneColor,
    this.icon,
    this.compact = false,
  });

  final String label;
  final Widget child;
  final Color? toneColor;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = toneColor ?? colors.outlineVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: toneColor == null
            ? colors.surfaceContainerHigh
            : accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: toneColor ?? colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: toneColor ?? colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}
