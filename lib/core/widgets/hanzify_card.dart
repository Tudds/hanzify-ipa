import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HanzifyCardVariant {
  /// Solid white/surface card with soft shadow (default)
  solid,
  /// Subtle tinted surface — no blur, just a light fill + border
  glass,
  /// Outlined card — no fill, border only
  outlined,
  /// Large-radius soft card for flashcard study view
  study,
}

class HanzifyCard extends ConsumerStatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Gradient? gradient;
  final HanzifyCardVariant variant;

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
    this.onLongPress,
    this.gradient,
    this.variant = HanzifyCardVariant.solid,
  });

  @override
  ConsumerState<HanzifyCard> createState() => _HanzifyCardState();
}

class _HanzifyCardState extends ConsumerState<HanzifyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleCtrl.reverse();
  void _onTapUp(_) => _scaleCtrl.forward();
  void _onTapCancel() => _scaleCtrl.forward();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;
    final radius = widget.borderRadius ?? AppRadii.xxxl;

    final content = Padding(
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.xl),
      child: widget.child,
    );

    Widget card;
    switch (widget.variant) {
      case HanzifyCardVariant.glass:
        card = Container(
          decoration: BoxDecoration(
            color: widget.color ?? c.glassSurface,
            borderRadius: BorderRadius.circular(radius),
            border: widget.border ?? Border.all(color: c.glassBorder, width: 1),
            boxShadow: widget.boxShadow ?? c.cardShadow,
          ),
          child: content,
        );
      case HanzifyCardVariant.outlined:
        card = Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            border: widget.border ?? Border.all(color: c.outlineVariant, width: 1),
          ),
          child: content,
        );
      case HanzifyCardVariant.solid:
        card = Container(
          decoration: BoxDecoration(
            color: widget.gradient == null ? (widget.color ?? c.surfaceLowest) : null,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: widget.boxShadow ?? c.cardShadow,
            border: widget.border,
          ),
          child: content,
        );
      case HanzifyCardVariant.study:
        card = Container(
          decoration: BoxDecoration(
            color: widget.color ?? c.surfaceLowest,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadii.xxxl),
            boxShadow: widget.boxShadow ?? [
              BoxShadow(
                color: c.text.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: widget.border,
          ),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(AppSpacing.xxl),
            child: widget.child,
          ),
        );
        return Container(
          margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 6),
          child: widget.onTap != null
              ? GestureDetector(
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  child: ScaleTransition(scale: _scaleAnim, child: card),
                )
              : card,
        );
    }

    final wrapped = Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 6),
      child: card,
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            child: wrapped,
          ),
        ),
      );
    }
    return wrapped;
  }
}
