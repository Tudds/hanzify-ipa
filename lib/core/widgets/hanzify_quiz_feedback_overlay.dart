import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/typography.dart';

class HanzifyQuizFeedbackOverlay extends StatelessWidget {
  final bool isCorrect;

  const HanzifyQuizFeedbackOverlay({
    super.key,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final color = isCorrect ? c.success : c.error;
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final text = isCorrect ? 'CHÍNH XÁC!' : 'CHƯA ĐÚNG...';

    return Stack(
      children: [
        // Background dim
        Positioned.fill(
          child: Container(
            color: color.withValues(alpha: 0.05),
          ).animate().fadeIn(duration: 200.ms),
        ),
        
        // Center content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 100,
                color: color,
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 600.ms,
                  curve: Curves.easeInOut,
                )
                .shimmer(delay: 400.ms, duration: 1200.ms, color: Colors.white.withValues(alpha: 0.2)),
              
              const SizedBox(height: AppSpacing.lg),
              
              Text(
                text,
                style: AppTypography.headline(
                  fontSize: AppFontSizes.displaySm,
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ).animate().slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack, duration: 400.ms).fadeIn(),
            ],
          ),
        ),
      ],
    );
  }
}
