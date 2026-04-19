import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'hanzify_badge.dart';

/// HSK level badge that auto-colors from the current theme's hskColors.
///
/// Shorthand for [HanzifyBadge.hsk] that resolves the theme internally.
class HanzifyHskBadge extends StatelessWidget {
  final int level;
  final bool filled;

  const HanzifyHskBadge({
    super.key,
    required this.level,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    return HanzifyBadge.hsk(level: level, colors: c, filled: filled);
  }
}
