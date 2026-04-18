import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

class HanzifyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const HanzifyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;

    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.surfaceLowest) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadii.xxxl),
        boxShadow: boxShadow ?? c.cardShadow,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
