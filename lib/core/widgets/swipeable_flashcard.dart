import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_curves.dart';

/// Commit threshold: drag must exceed this fraction of screen width to commit.
const double _kCommitThreshold = 0.30;

/// Labels shown as user drags — fade in proportional to drag progress.
enum SwipeLabel { again, hard, good, easy }

/// Tinder-style swipeable flashcard wrapper.
/// Swipe left = [onSwipeLeft] (Again), right = [onSwipeRight] (Easy),
/// down = [onSwipeDown] (Hard), up = [onSwipeUp] (Good).
class SwipeableFlashcard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;   // Again
  final VoidCallback? onSwipeRight;  // Easy
  final VoidCallback? onSwipeDown;   // Hard
  final VoidCallback? onSwipeUp;     // Good

  const SwipeableFlashcard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeDown,
    this.onSwipeUp,
  });

  @override
  State<SwipeableFlashcard> createState() => _SwipeableFlashcardState();
}

class _SwipeableFlashcardState extends State<SwipeableFlashcard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  late Animation<Offset> _snapAnimation;

  Offset _offset = Offset.zero;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isSnapping) return;
    setState(() => _offset += d.delta);
  }

  void _onPanEnd(DragEndDetails details, Size size) {
    if (_isSnapping) return;
    final threshold = size.width * _kCommitThreshold;
    final dx = _offset.dx;
    final dy = _offset.dy;

    // Determine dominant axis
    final isHorizontalDominant = dx.abs() > dy.abs();

    if (isHorizontalDominant && dx.abs() > threshold) {
      final target = Offset(dx.sign * size.width * 1.5, dy);
      _commitSwipe(target, dx > 0 ? widget.onSwipeRight : widget.onSwipeLeft);
    } else if (!isHorizontalDominant && dy.abs() > threshold) {
      final target = Offset(dx, dy.sign * size.height * 1.5);
      _commitSwipe(target, dy > 0 ? widget.onSwipeDown : widget.onSwipeUp);
    } else {
      _snapBack();
    }
  }

  void _commitSwipe(Offset target, VoidCallback? callback) {
    _isSnapping = true;
    _snapAnimation = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: AppCurves.exit),
    );
    _snapAnimation.addListener(() => setState(() => _offset = _snapAnimation.value));
    _snapController.forward(from: 0).then((_) {
      callback?.call();
      setState(() {
        _offset = Offset.zero;
        _isSnapping = false;
      });
      _snapController.reset();
    });
  }

  void _snapBack() {
    _isSnapping = true;
    _snapAnimation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _snapController, curve: AppCurves.spring),
    );
    _snapAnimation.addListener(() => setState(() => _offset = _snapAnimation.value));
    _snapController.forward(from: 0).then((_) {
      _isSnapping = false;
      _snapController.reset();
    });
  }

  double get _tiltAngle => _offset.dx / 800.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: (d) => _onPanEnd(d, size),
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: _tiltAngle,
          child: Stack(
            children: [
              widget.child,
              _SwipeLabelOverlay(offset: _offset, screenSize: size),
            ],
          ),
        ),
      ),
    );
  }
}

/// Labels that fade in as the user drags toward a commit threshold.
class _SwipeLabelOverlay extends StatelessWidget {
  final Offset offset;
  final Size screenSize;

  const _SwipeLabelOverlay({required this.offset, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final threshold = screenSize.width * _kCommitThreshold;
    final dx = offset.dx;
    final dy = offset.dy;

    final isHorizontal = dx.abs() > dy.abs();
    final opacity = isHorizontal
        ? (dx.abs() / threshold).clamp(0.0, 1.0)
        : (dy.abs() / threshold).clamp(0.0, 1.0);

    if (opacity < 0.05) return const SizedBox.shrink();

    final (label, color, alignment) = _labelFor(dx, dy, isHorizontal);

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  (String, Color, Alignment) _labelFor(
      double dx, double dy, bool isHorizontal) {
    if (isHorizontal) {
      return dx > 0
          ? ('EASY', Colors.green, Alignment.topLeft)
          : ('AGAIN', Colors.red, Alignment.topRight);
    } else {
      return dy > 0
          ? ('HARD', Colors.orange, Alignment.topCenter)
          : ('GOOD', Colors.blue, Alignment.bottomCenter);
    }
  }
}
