import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/colors.dart';

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
    this.fontSize = 11,
    this.padding,
  });

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

  factory HanzifyBadge.pos({
    Key? key,
    required String posKey,
    required String label,
    required AppThemeColors colors,
  }) {
    final color = colors.posColors[posKey] ?? csPlaceholder(colors);
    return HanzifyBadge(
      key: key,
      label: label.toUpperCase(),
      color: color,
    );
  }

  static Color csPlaceholder(AppThemeColors colors) => colors.onSurfaceVariant.withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor ?? (filled ? Colors.white : color),
        ),
      ),
    );
  }
}
