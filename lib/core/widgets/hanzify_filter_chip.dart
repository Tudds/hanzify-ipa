import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HanzifyFilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  const HanzifyFilterChip({
    super.key,
    required this.label,
    this.emoji,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;

    final baseActiveColor = activeColor ?? c.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive ? baseActiveColor.withValues(alpha: 0.15) : c.surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? baseActiveColor : c.disabled.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? baseActiveColor : c.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
