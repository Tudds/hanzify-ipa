import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';

/// Flashcard reveal animation: tap to flip from [front] to [back].
/// Uses AnimatedSwitcher with fade + scale (no 3D Y-rotate, per design spec).
class FlashcardFlipWidget extends StatefulWidget {
  final Widget front;
  final Widget back;

  /// Called when card flips to back (revealed).
  final VoidCallback? onRevealed;

  /// Called when card flips back to front (unreveal).
  final VoidCallback? onUnrevealed;

  const FlashcardFlipWidget({
    super.key,
    required this.front,
    required this.back,
    this.onRevealed,
    this.onUnrevealed,
  });

  @override
  State<FlashcardFlipWidget> createState() => _FlashcardFlipWidgetState();
}

class _FlashcardFlipWidgetState extends State<FlashcardFlipWidget> {
  bool _revealed = false;

  void _toggle() {
    if (_revealed) {
      setState(() => _revealed = false);
      widget.onUnrevealed?.call();
    } else {
      setState(() => _revealed = true);
      widget.onRevealed?.call();
    }
  }

  void reset() => setState(() => _revealed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: AppDurations.flip,
        switchInCurve: AppCurves.enter,
        switchOutCurve: AppCurves.exit,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: AppCurves.enter),
              ),
              child: child,
            ),
          );
        },
        child: _revealed
            ? KeyedSubtree(key: const ValueKey('back'), child: widget.back)
            : KeyedSubtree(key: const ValueKey('front'), child: widget.front),
      ),
    );
  }
}
