import 'package:flutter/material.dart';

class HanzifyStreakBadge extends StatefulWidget {
  final int count;
  final bool animate;
  final bool compact;

  const HanzifyStreakBadge({
    super.key,
    required this.count,
    this.animate = false,
    this.compact = false,
  });

  @override
  State<HanzifyStreakBadge> createState() => _HanzifyStreakBadgeState();
}

class _HanzifyStreakBadgeState extends State<HanzifyStreakBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 1.0, end: 1.0).animate(_ctrl);
    if (widget.animate) _celebrate();
  }

  @override
  void didUpdateWidget(HanzifyStreakBadge old) {
    super.didUpdateWidget(old);
    if (widget.count > old.count) _celebrate();
  }

  void _celebrate() {
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
    ]).animate(_ctrl);
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: widget.compact ? 8 : 12, vertical: widget.compact ? 4 : 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥', style: TextStyle(fontSize: widget.compact ? 12 : 14)),
            const SizedBox(width: 4),
            Text(
              '${widget.count}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: widget.compact ? 11 : 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
