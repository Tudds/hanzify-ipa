import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

/// Circular progress ring with animated fill and center label.
///
/// [progress] is 0.0–1.0. Changes animate automatically.
class HanzifyProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? center;
  final String? label;
  final String? sublabel;

  const HanzifyProgressRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 6,
    this.color,
    this.trackColor,
    this.center,
    this.label,
    this.sublabel,
  });

  @override
  State<HanzifyProgressRing> createState() => _HanzifyProgressRingState();
}

class _HanzifyProgressRingState extends State<HanzifyProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  double _oldProgress = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppDurations.celebrate);
    _anim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _ctrl, curve: AppCurves.progress),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(HanzifyProgressRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _oldProgress = old.progress;
      _anim = Tween<double>(begin: _oldProgress, end: widget.progress).animate(
        CurvedAnimation(parent: _ctrl, curve: AppCurves.progress),
      );
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
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final ringColor = widget.color ?? c.primary;
    final track = widget.trackColor ?? ringColor.withValues(alpha: 0.12);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => CustomPaint(
          painter: _RingPainter(
            progress: _anim.value.clamp(0.0, 1.0),
            color: ringColor,
            trackColor: track,
            strokeWidth: widget.strokeWidth,
          ),
          child: child,
        ),
        child: Center(
          child: widget.center ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: AppTypography.headline(
                        fontSize: AppFontSizes.headlineSm,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                  if (widget.sublabel != null)
                    Text(
                      widget.sublabel!,
                      style: AppTypography.label(
                        fontSize: AppFontSizes.labelSm,
                        color: c.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
