import 'package:flutter/material.dart';

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
    this.borderRadius = 8,
    this.isLoading = true,
    this.child,
  });

  @override
  State<HanzifyShimmerBox> createState() => _HanzifyShimmerBoxState();
}

class _HanzifyShimmerBoxState extends State<HanzifyShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) return widget.child!;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final baseColor = cs.surfaceContainerHigh;
    final highlightColor = cs.surfaceContainerLow;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [
              (_ctrl.value - 0.3).clamp(0.0, 1.0),
              _ctrl.value.clamp(0.0, 1.0),
              (_ctrl.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: [baseColor, highlightColor, baseColor],
          ),
        ),
      ),
    );
  }
}

class HanzifyShimmerList extends StatelessWidget {
  final int lineCount;
  final double lineHeight;
  final double spacing;

  const HanzifyShimmerList({
    super.key,
    this.lineCount = 3,
    this.lineHeight = 14,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lineCount; i++) ...[
          HanzifyShimmerBox(
            height: lineHeight,
            width: i == lineCount - 1 ? 160 : double.infinity,
          ),
          if (i < lineCount - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
