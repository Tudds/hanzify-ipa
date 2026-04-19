import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HanzifyGradientFab extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final double size;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const HanzifyGradientFab({
    super.key,
    required this.icon,
    this.iconColor,
    this.size = 60,
    this.onTap,
    this.gradient,
    this.boxShadow,
  });

  @override
  State<HanzifyGradientFab> createState() => _HanzifyGradientFabState();
}

class _HanzifyGradientFabState extends State<HanzifyGradientFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.90,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;

    return GestureDetector(
      onTap: () {
        _ctrl.reverse().then((_) => _ctrl.forward());
        widget.onTap?.call();
      },
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.gradient == null ? c.primary : null,
            gradient: widget.gradient,
            shape: BoxShape.circle,
            boxShadow: widget.boxShadow ?? c.glowShadow,
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor ?? c.onPrimary,
            size: widget.size * 0.45,
          ),
        ),
      ),
    );
  }
}
