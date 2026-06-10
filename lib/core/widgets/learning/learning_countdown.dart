import 'package:flutter/material.dart';

class LearningCountdownPill extends StatelessWidget {
  const LearningCountdownPill({super.key, required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final urgent = seconds <= 10;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: urgent ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: urgent
                  ? colors.onErrorContainer
                  : colors.onSecondaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              '${seconds}s',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: urgent
                    ? colors.onErrorContainer
                    : colors.onSecondaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearningCountdownProgress extends StatelessWidget {
  const LearningCountdownProgress({
    super.key,
    required this.seconds,
    required this.totalSeconds,
    this.minHeight = 7,
  });

  final int seconds;
  final int totalSeconds;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safeTotal = totalSeconds <= 0 ? 1 : totalSeconds;
    final progress = (seconds / safeTotal).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: minHeight,
              backgroundColor: colors.surfaceContainerHighest,
              color: progress <= 0.25 ? colors.error : colors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        LearningCountdownPill(seconds: seconds),
      ],
    );
  }
}
