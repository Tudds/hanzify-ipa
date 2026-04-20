import 'package:flutter/material.dart';

class HanzifyProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final bool animated;
  final Color? barColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsets? margin;

  const HanzifyProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.animated = true,
    this.barColor,
    this.backgroundColor,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bg = backgroundColor ?? cs.surfaceContainerHighest;
    final color = barColor ?? cs.primary;
    final radius = borderRadius ?? height / 2;

    return Container(
      height: height,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Stack(
        children: [
          animated
              ? AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                )
              : FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
