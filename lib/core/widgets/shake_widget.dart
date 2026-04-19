import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_durations.dart';

/// Wraps [child] in a horizontal shake animation.
///
/// Trigger by toggling [trigger] from false → true.
/// The shake auto-resets after completion.
class ShakeWidget extends StatefulWidget {
  final Widget child;

  /// Flip this from false → true to trigger one shake cycle.
  final bool trigger;

  /// Shake amplitude in logical pixels.
  final double amplitude;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.trigger,
    this.amplitude = 10,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppDurations.modal);
  }

  @override
  void didUpdateWidget(ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final dx = sin(_ctrl.value * pi * 4) * widget.amplitude * (1 - _ctrl.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
