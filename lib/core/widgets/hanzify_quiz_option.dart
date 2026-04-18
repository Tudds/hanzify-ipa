// ============================================================================
// HanzifyQuizOption — Unified quiz answer option widget
// Replaces the quiz option pattern in QuizQuestionView:
//   - Option index badge (A/B/C/D)
//   - Option text
//   - Color-coded states (selected, correct, wrong, normal)
//   - Trailing result icon
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';

/// Quiz option selection state
enum QuizOptionState {
  /// Not yet selected (normal appearance)
  normal,

  /// Currently selected by user (waiting for answer check)
  selected,

  /// This is the correct answer
  correct,

  /// This is a wrong answer
  wrong,

  /// Disabled / not selectable
  disabled,
}

class HanzifyQuizOption extends StatelessWidget {
  /// Option label (A, B, C, D)
  final String label;

  /// Option text content
  final String text;

  /// Current state of this option
  final QuizOptionState state;

  /// Tap callback
  final VoidCallback? onTap;

  /// Text style override
  final TextStyle? textStyle;

  /// Whether to show hanzi display style (larger font)
  final bool isHanzi;

  const HanzifyQuizOption({
    super.key,
    required this.label,
    required this.text,
    this.state = QuizOptionState.normal,
    this.onTap,
    this.textStyle,
    this.isHanzi = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final isSelectable = state == QuizOptionState.normal ||
        state == QuizOptionState.selected;

    final (bgColor, borderColor, textColor, trailingIcon) = _getColors(c);

    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Row(
          children: [
            _buildLabel(c, borderColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: textStyle ??
                    TextStyle(
                      fontSize: isHanzi ? 24 : 16,
                      fontWeight: isHanzi ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                      height: 1.4,
                    ),
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, color: borderColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(AppThemeColors c, Color borderColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: borderColor,
          ),
        ),
      ),
    );
  }

  (Color bg, Color border, Color text, IconData? icon) _getColors(
      AppThemeColors c) {
    switch (state) {
      case QuizOptionState.normal:
        return (c.surface, c.outlineVariant.withValues(alpha: 0.5), c.text, null);
      case QuizOptionState.selected:
        return (c.primary.withValues(alpha: 0.08), c.primary, c.primary, null);
      case QuizOptionState.correct:
        return (
          c.success.withValues(alpha: 0.1),
          c.success,
          c.success,
          Icons.check_circle_rounded,
        );
      case QuizOptionState.wrong:
        return (
          c.danger.withValues(alpha: 0.1),
          c.danger,
          c.danger,
          Icons.cancel_rounded,
        );
      case QuizOptionState.disabled:
        return (
          c.surfaceLowest,
          c.disabled.withValues(alpha: 0.3),
          c.disabled,
          null,
        );
    }
  }
}
