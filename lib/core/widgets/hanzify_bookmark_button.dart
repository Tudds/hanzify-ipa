import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';

class HanzifyBookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onTap;
  final AppThemeColors colors;

  const HanzifyBookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isBookmarked
              ? c.primary.withValues(alpha: 0.12)
              : c.surfaceLowest,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: isBookmarked ? c.primary.withValues(alpha: 0.3) : Colors.transparent,
            width: 1,
          ),
          boxShadow: c.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: child,
                );
              },
              child: Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                key: ValueKey(isBookmarked),
                color: isBookmarked ? c.primary : c.placeholder,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Lưu',
              style: AppTypography.label(
                color: isBookmarked ? c.primary : c.placeholder,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ).animate(target: isBookmarked ? 1 : 0)
        .shimmer(
          duration: 1200.ms,
          color: c.primary.withValues(alpha: 0.1),
          delay: 200.ms,
        ),
    );
  }
}
