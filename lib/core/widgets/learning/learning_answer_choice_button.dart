import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum LearningAnswerChoiceState { idle, correct, wrong, disabled }

double _resolvedWidth(BuildContext context, BoxConstraints constraints) {
  if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
    return constraints.maxWidth;
  }
  return MediaQuery.sizeOf(context).width;
}

double _responsiveSpace(double width, double factor, double min, double max) {
  return (width * factor).clamp(min, max).toDouble();
}

class LearningAnswerChoiceButton extends StatelessWidget {
  const LearningAnswerChoiceButton({
    super.key,
    required this.choice,
    required this.onPressed,
    this.state = LearningAnswerChoiceState.idle,
    this.prominent = false,
  });

  final String choice;
  final VoidCallback? onPressed;
  final LearningAnswerChoiceState state;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    final enabled =
        state == LearningAnswerChoiceState.idle && onPressed != null;
    final background = switch (state) {
      LearningAnswerChoiceState.idle => colors.surfaceContainerHighest,
      LearningAnswerChoiceState.correct =>
        semantic.success.withValues(alpha: 0.22),
      LearningAnswerChoiceState.wrong =>
        semantic.danger.withValues(alpha: 0.22),
      LearningAnswerChoiceState.disabled =>
        colors.surfaceContainerHighest.withValues(alpha: 0.45),
    };
    final foreground = switch (state) {
      LearningAnswerChoiceState.correct => semantic.success,
      LearningAnswerChoiceState.wrong => semantic.danger,
      LearningAnswerChoiceState.disabled => colors.onSurfaceVariant,
      LearningAnswerChoiceState.idle => colors.onSurface,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolvedWidth(context, constraints);
        final dense = width < 360;
        final textTheme = Theme.of(context).textTheme;
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: dense ? 52 : (prominent ? 66 : 58),
          ),
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: _responsiveSpace(width, 0.045, 14, 20),
                vertical: dense ? 14 : (prominent ? 18 : 16),
              ),
              backgroundColor: background,
              disabledBackgroundColor: background,
              foregroundColor: foreground,
              disabledForegroundColor: foreground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(prominent ? 18 : 14),
              ),
            ),
            child: Text(
              choice,
              textAlign: TextAlign.center,
              softWrap: true,
              style:
                  (dense || !prominent
                          ? textTheme.titleMedium
                          : textTheme.titleLarge)
                      ?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
            ),
          ),
        );
      },
    );
  }
}
