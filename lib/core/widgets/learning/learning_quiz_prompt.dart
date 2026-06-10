import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../audio/audio_play_button.dart';
import '../../motion/motion_tokens.dart';

double _resolvedWidth(BuildContext context, BoxConstraints constraints) {
  if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
    return constraints.maxWidth;
  }
  return MediaQuery.sizeOf(context).width;
}

double _responsiveSpace(double width, double factor, double min, double max) {
  return (width * factor).clamp(min, max).toDouble();
}

class LearningQuizPrompt extends StatelessWidget {
  const LearningQuizPrompt({
    super.key,
    required this.prompt,
    this.promptPinyin,
    this.audioUrl,
    this.quizType,
    this.compact = false,
    this.animate = true,
  });

  final String prompt;
  final String? promptPinyin;
  final String? audioUrl;
  final String? quizType;
  final bool compact;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colors = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final width = _resolvedWidth(context, constraints);
        final dense = compact || width < 360;
        final promptStyle = dense
            ? textTheme.titleLarge
            : textTheme.headlineSmall;
        final content = DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _responsiveSpace(width, 0.055, 14, 24),
              vertical: _responsiveSpace(width, 0.05, 16, 22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _quizQuestionLabel(quizType),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        prompt,
                        textAlign: TextAlign.center,
                        style: promptStyle?.copyWith(
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (audioUrl != null) ...[
                      const SizedBox(width: 10),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: AudioPlayButton(
                          url: audioUrl,
                          size: dense ? 34 : 38,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ],
                ),
                if (promptPinyin?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 10),
                  Text(
                    promptPinyin!,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        if (!animate) return content;
        return content.animate().fadeIn(duration: MotionTokens.fast);
      },
    );
  }

  String _quizQuestionLabel(String? quizType) {
    return switch (quizType) {
      'pinyinChoice' => 'Pinyin nào đúng?',
      'clozeCollocation' => 'Điền từ còn thiếu',
      _ => 'Nghĩa là gì?',
    };
  }
}
