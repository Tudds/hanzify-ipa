import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/theme/typography.dart';

/// Streak badge with optional celebration animation when count increases.
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

class _HanzifyStreakBadgeState extends State<HanzifyStreakBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppDurations.streak);
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
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: AppCurves.emphasis)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: AppCurves.spring)),
        weight: 60,
      ),
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
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return ScaleTransition(
      scale: disableAnimations ? const AlwaysStoppedAnimation(1.0) : _scale,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? AppSpacing.sm : AppSpacing.md,
          vertical: widget.compact ? 3 : AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF97316).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(fontSize: widget.compact ? 12 : 14),
            ),
            const SizedBox(width: 3),
            Text(
              '${widget.count}',
              style: AppTypography.label(
                fontSize: widget.compact ? AppFontSizes.labelSm : AppFontSizes.labelLg,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
