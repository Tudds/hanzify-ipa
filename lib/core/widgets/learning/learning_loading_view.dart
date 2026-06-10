import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../motion/motion_tokens.dart';

class LearningLoadingView extends StatelessWidget {
  const LearningLoadingView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: colors.primary)
            .animate()
            .fadeIn(duration: MotionTokens.fast)
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1, 1),
              duration: MotionTokens.medium,
            ),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ).animate().fadeIn(delay: 90.ms, duration: MotionTokens.fast),
      ],
    );
  }
}
