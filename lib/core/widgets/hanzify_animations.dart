import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';

/// Consistent animation helpers for entrance and state transitions.
extension HanzifyEntrance on Widget {
  /// Standard screen/card entrance: fadeIn + slight slideY.
  /// Use [index] for sequential stagger (max stagger capped at 300ms).
  Widget hanzifyEntrance({int index = 0, Duration? duration}) {
    final delay = Duration(milliseconds: (40 * index).clamp(0, 300));
    final dur = duration ?? AppDurations.slow;
    return animate()
        .fadeIn(delay: delay, duration: dur)
        .slideY(
          begin: 0.06,
          end: 0,
          curve: AppCurves.enter,
          delay: delay,
          duration: dur,
        );
  }

  /// Simple fade in — for content that appears without positional change.
  Widget hanzifyFadeIn({int index = 0, Duration? duration}) {
    final delay = Duration(milliseconds: (40 * index).clamp(0, 300));
    return animate().fadeIn(
      delay: delay,
      duration: duration ?? AppDurations.normal,
    );
  }

  /// Scale in from center — for celebration elements, badge pops.
  Widget hanzifyScaleIn({Duration? duration, Curve? curve}) {
    return animate().scale(
      begin: const Offset(0.85, 0.85),
      end: const Offset(1, 1),
      duration: duration ?? AppDurations.normal,
      curve: curve ?? AppCurves.emphasis,
    );
  }
}

/// Animated visibility wrapper using FadeTransition + ScaleTransition.
class HanzifyScaleInOut extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;

  const HanzifyScaleInOut({
    super.key,
    required this.visible,
    required this.child,
    this.duration = AppDurations.fast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      child: AnimatedScale(
        scale: visible ? 1.0 : 0.85,
        duration: duration,
        curve: AppCurves.enter,
        child: child,
      ),
    );
  }
}

/// Animated integer counter — counts up/down when [value] changes.
class HanzifyCountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const HanzifyCountUp({
    super.key,
    required this.value,
    this.style,
    this.duration = AppDurations.counter,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: AppCurves.progress,
      builder: (context, v, child) => Text('$v', style: style),
    );
  }
}
