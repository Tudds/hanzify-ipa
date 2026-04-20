import 'package:flutter/material.dart';

enum HanzifyCardVariant {
  solid,
  glass,
  outlined,
  study,
  elevated,
  gradient,
}

class HanzifyCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final HanzifyCardVariant variant;

  const HanzifyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.variant = HanzifyCardVariant.solid,
  });

  @override
  State<HanzifyCard> createState() => _HanzifyCardState();
}

class _HanzifyCardState extends State<HanzifyCard> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = widget.borderRadius ?? (widget.variant == HanzifyCardVariant.study ? 24.0 : 16.0);

    Widget cardContent = Padding(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: widget.child,
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      cardContent = InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(radius),
        child: cardContent,
      );
    }

    Widget card;
    switch (widget.variant) {
      case HanzifyCardVariant.outlined:
        card = Card.outlined(
          margin: widget.margin ?? EdgeInsets.zero,
          color: widget.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          child: cardContent,
        );
        break;
      case HanzifyCardVariant.study:
        card = Card.filled(
          margin: widget.margin ?? EdgeInsets.zero,
          color: widget.color ?? cs.primaryContainer.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          child: cardContent,
        );
        break;
      case HanzifyCardVariant.elevated:
        card = Card(
          margin: widget.margin ?? EdgeInsets.zero,
          color: widget.color ?? cs.surfaceContainerHigh,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          child: cardContent,
        );
        break;
      case HanzifyCardVariant.gradient:
        card = Container(
          margin: widget.margin ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            child: cardContent,
          ),
        );
        break;
      default:
        card = Card.filled(
          margin: widget.margin ?? EdgeInsets.zero,
          color: widget.color ?? cs.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          child: cardContent,
        );
        break;
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => _scaleCtrl.reverse(),
        onTapUp: (_) => _scaleCtrl.forward(),
        onTapCancel: () => _scaleCtrl.forward(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: card,
        ),
      );
    }

    return card;
  }
}
