import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';

class HanzifyProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Widget? center;
  final String? label;
  final String? sublabel;
  final Color? color;
  final double strokeWidth;

  const HanzifyProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.center,
    this.label,
    this.sublabel,
    this.color,
    this.strokeWidth = 8,
  });

  @override
  State<HanzifyProgressRing> createState() => _HanzifyProgressRingState();
}

class _HanzifyProgressRingState extends State<HanzifyProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _lastProgress = 0;

  @override
  void initState() {
    super.initState();
    _lastProgress = widget.progress;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(HanzifyProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _lastProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _lastProgress = widget.progress;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = themeColorsOf(context);
    final activeColor = widget.color ?? colors.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: _animation.value.clamp(0, 1),
                    color: activeColor,
                    backgroundColor: activeColor.withValues(alpha: 0.1),
                    strokeWidth: widget.strokeWidth,
                  ),
                );
              },
            ),
          ),
          Center(
            child: widget.center ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: widget.size * 0.25,
                          fontWeight: FontWeight.w900,
                          color: activeColor,
                          height: 1,
                        ),
                      ),
                    if (widget.sublabel != null)
                      Text(
                        widget.sublabel!,
                        style: TextStyle(
                          fontSize: widget.size * 0.1,
                          fontWeight: FontWeight.bold,
                          color: colors.placeholder,
                        ),
                      ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Draw background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Draw a subtle glow/gradient if progress > 0
    if (progress > 0.05) {
      final glowPaint = Paint()
        ..shader = SweepGradient(
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.5),
          ],
          stops: const [0.0, 1.0],
          transform: GradientRotation(-math.pi / 2 + (2 * math.pi * progress) - 0.5),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
      // Only draw the glow near the tip
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + (2 * math.pi * progress) - 0.3,
        0.3,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
