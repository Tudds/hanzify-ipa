import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';

/// Pill-shaped badge for HSK levels, POS tags, or generic labels.
///
/// Usage:
/// ```dart
/// HanzifyBadge.hsk(level: 1, colors: c)
/// HanzifyBadge.pos(posKey: 'v', label: 'Dong tu', colors: c)
/// HanzifyBadge(label: 'Custom', color: Colors.purple)
/// ```
class HanzifyBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool filled;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const HanzifyBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.filled = false,
    this.fontSize = AppFontSizes.labelSm,
    this.padding,
  });

  /// HSK level badge — uses `hskColors` from the theme.
  factory HanzifyBadge.hsk({
    Key? key,
    required int level,
    required AppThemeColors colors,
    bool filled = false,
  }) {
    final idx = (level - 1).clamp(0, colors.hskColors.length - 1);
    return HanzifyBadge(
      key: key,
      label: 'HSK $level',
      color: colors.hskColors[idx],
      filled: filled,
    );
  }

  /// Part-of-speech badge — uses `posColors` from the theme.
  factory HanzifyBadge.pos({
    Key? key,
    required String posKey,
    required String label,
    required AppThemeColors colors,
  }) {
    final color = colors.posColors[posKey] ?? colors.placeholder;
    return HanzifyBadge(
      key: key,
      label: label.toUpperCase(),
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: AppTypography.label(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: textColor ?? 
              (filled ? (color.computeLuminance() > 0.6 ? Colors.black : Colors.white) : color),
        ),
      ),
    );
  }
}
