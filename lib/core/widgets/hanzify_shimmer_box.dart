import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

/// Self-contained shimmer skeleton box — no external package needed.
///
/// Use for loading placeholders that match the shape of real content.
class HanzifyShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isLoading;
  final Widget? child;

  const HanzifyShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadii.md,
    this.isLoading = true,
    this.child,
  });

  @override
  State<HanzifyShimmerBox> createState() => _HanzifyShimmerBoxState();
}

class _HanzifyShimmerBoxState extends State<HanzifyShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) return widget.child!;

    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final baseColor = c.surface;
    final highlightColor = c.surfaceLowest;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: [baseColor, highlightColor, baseColor],
          ),
        ),
      ),
    );
  }
}

/// Column of shimmer lines for paragraph-style loading.
class HanzifyShimmerList extends StatelessWidget {
  final int lineCount;
  final double lineHeight;
  final double spacing;

  const HanzifyShimmerList({
    super.key,
    this.lineCount = 3,
    this.lineHeight = 14,
    this.spacing = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lineCount; i++) ...[
          HanzifyShimmerBox(
            height: lineHeight,
            width: i == lineCount - 1 ? 160 : null,
          ),
          if (i < lineCount - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
