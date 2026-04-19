import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

enum HanzifyIconBoxSize { sm, md, lg, xl }

enum HanzifyIconBoxShape { square, rounded, circle }

/// Standardized icon container replacing ad-hoc 40/44/50px icon boxes.
class HanzifyIconBox extends StatelessWidget {
  final IconData icon;
  final HanzifyIconBoxSize size;
  final HanzifyIconBoxShape shape;
  final Color? backgroundColor;
  final Color? iconColor;

  const HanzifyIconBox({
    super.key,
    required this.icon,
    this.size = HanzifyIconBoxSize.md,
    this.shape = HanzifyIconBoxShape.rounded,
    this.backgroundColor,
    this.iconColor,
  });

  double get _boxSize => switch (size) {
    HanzifyIconBoxSize.sm => 32,
    HanzifyIconBoxSize.md => 40,
    HanzifyIconBoxSize.lg => 48,
    HanzifyIconBoxSize.xl => 56,
  };

  double get _iconSize => switch (size) {
    HanzifyIconBoxSize.sm => AppSpacing.iconSm,
    HanzifyIconBoxSize.md => 22,
    HanzifyIconBoxSize.lg => 24,
    HanzifyIconBoxSize.xl => 28,
  };

  double get _radius => switch (shape) {
    HanzifyIconBoxShape.circle => _boxSize / 2,
    HanzifyIconBoxShape.rounded => switch (size) {
      HanzifyIconBoxSize.sm => AppRadii.md,
      HanzifyIconBoxSize.md => AppRadii.lg,
      HanzifyIconBoxSize.lg => AppRadii.xl,
      HanzifyIconBoxSize.xl => AppRadii.xl,
    },
    HanzifyIconBoxShape.square => AppRadii.sm,
  };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final bg = backgroundColor ?? c.primaryContainer;
    final fg = iconColor ?? c.primary;

    return Container(
      width: _boxSize,
      height: _boxSize,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Icon(icon, color: fg, size: _iconSize),
    );
  }
}
