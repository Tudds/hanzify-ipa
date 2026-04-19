import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_curves.dart';

/// Feedback state for correct/wrong/neutral.
enum FeedbackState { none, correct, wrong }

/// Wraps [child] with an animated border pulse when [state] changes.
/// Correct: 2 green pulses (200ms each). Wrong: red flash.
/// Reverts to [none] automatically after the animation completes.
class FeedbackBorderWidget extends StatefulWidget {
  final FeedbackState state;
  final Widget child;
  final double borderRadius;
  final Color? correctColor;
  final Color? wrongColor;

  const FeedbackBorderWidget({
    super.key,
    required this.state,
    required this.child,
    this.borderRadius = 16,
    this.correctColor,
    this.wrongColor,
  });

  @override
  State<FeedbackBorderWidget> createState() => _FeedbackBorderWidgetState();
}

class _FeedbackBorderWidgetState extends State<FeedbackBorderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacityAnim = _buildOpacityAnim();
  }

  @override
  void didUpdateWidget(FeedbackBorderWidget old) {
    super.didUpdateWidget(old);
    if (widget.state != old.state && widget.state != FeedbackState.none) {
      _opacityAnim = _buildOpacityAnim();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _buildOpacityAnim() {
    if (widget.state == FeedbackState.correct) {
      // 2 pulses: fade in → fade out → fade in → fade out
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
      ]).animate(CurvedAnimation(parent: _controller, curve: AppCurves.transform));
    }
    // Wrong: single flash
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: AppCurves.transform));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correctColor =
        widget.correctColor ?? theme.colorScheme.tertiary;
    final wrongColor =
        widget.wrongColor ?? theme.colorScheme.error;

    final borderColor = switch (widget.state) {
      FeedbackState.correct => correctColor,
      FeedbackState.wrong => wrongColor,
      FeedbackState.none => Colors.transparent,
    };

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final opacity = widget.state == FeedbackState.none
            ? 0.0
            : _opacityAnim.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: borderColor.withValues(alpha: opacity),
              width: 2.5,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
