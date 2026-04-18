import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import './stroke_painter.dart';

/// Widget quản lý animation vẽ từng nét chữ Hán.
class StrokeAnimationWidget extends StatefulWidget {
  final List<String> svgStrokes;
  final AppThemeColors colors;
  final double size;
  final bool autoPlay;
  final Duration autoPlayDelay;
  final bool showControls;
  final bool loop;

  const StrokeAnimationWidget({
    super.key,
    required this.svgStrokes,
    required this.colors,
    this.size = 250,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(milliseconds: 400),
    this.showControls = true,
    this.loop = false,
  });

  @override
  State<StrokeAnimationWidget> createState() => _StrokeAnimationWidgetState();
}

class _StrokeAnimationWidgetState extends State<StrokeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStrokeIndex = 0;
  bool _isPlaying = false;
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentStrokeIndex < widget.svgStrokes.length - 1) {
          setState(() {
            _currentStrokeIndex++;
          });
          _controller.reset();
          if (_isPlaying) {
            _controller.forward();
          }
        } else {
          if (widget.loop && _isPlaying) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted && _isPlaying) {
                setState(() {
                  _currentStrokeIndex = 0;
                });
                _controller.reset();
                _controller.forward();
              }
            });
          } else {
            setState(() {
              _isPlaying = false;
            });
          }
        }
      }
    });

    // Auto-play after delay — syncs with Hero transition (~300ms)
    if (widget.autoPlay && widget.svgStrokes.isNotEmpty) {
      Future.delayed(widget.autoPlayDelay, () {
        if (mounted) _startAnimation();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      _isPlaying = true;
      if (_currentStrokeIndex >= widget.svgStrokes.length - 1) {
        _currentStrokeIndex = 0;
      }
    });
    _controller.reset();
    _controller.forward();
  }

  void _pauseAnimation() {
    setState(() {
      _isPlaying = false;
    });
    _controller.stop();
  }

  void _resetAnimation() {
    setState(() {
      _currentStrokeIndex = 0;
      _isPlaying = false;
    });
    _controller.reset();
  }

  void _nextStroke() {
    if (_currentStrokeIndex < widget.svgStrokes.length - 1) {
      setState(() {
        _currentStrokeIndex++;
      });
      _controller.value = 1.0;
    }
  }

  void _prevStroke() {
    if (_currentStrokeIndex > 0) {
      setState(() {
        _currentStrokeIndex--;
      });
      _controller.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Grid display Area
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: c.surfaceLowest,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: c.outlineVariant, width: 1),
          ),
          child: Stack(
            children: [
              // Background grid (optional but classic for Hanzi)
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridPainter(color: c.outlineVariant.withValues(alpha: 0.3)),
                ),
              ),
              // Main Stroke Painter
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: StrokePainter(
                          svgPaths: widget.svgStrokes,
                          currentStrokeIndex: _currentStrokeIndex,
                          animationValue: _controller.value,
                          showOutline: _showGuide,
                          strokeColor: c.text,
                          outlineColor: c.outlineVariant.withValues(alpha: 0.4),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Step indicator
              Positioned(
                bottom: 8,
                right: 12,
                child: Text(
                  '${_currentStrokeIndex + 1} / ${widget.svgStrokes.length}',
                  style: TextStyle(
                    fontSize: AppFontSizes.labelSm,
                    color: c.placeholder,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (widget.showControls) ...[
          const SizedBox(height: AppSpacing.lg),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                onPressed: _prevStroke,
                colors: c,
                tooltip: 'Nét trước',
              ),
              const SizedBox(width: AppSpacing.md),
              _ControlButton(
                icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onPressed: _isPlaying ? _pauseAnimation : _startAnimation,
                isPrimary: true,
                colors: c,
                tooltip: _isPlaying ? 'Tạm dừng' : 'Chạy tự động',
              ),
              const SizedBox(width: AppSpacing.md),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onPressed: _nextStroke,
                colors: c,
                tooltip: 'Nét sau',
              ),
              const SizedBox(width: AppSpacing.md),
              _ControlButton(
                icon: Icons.refresh_rounded,
                onPressed: _resetAnimation,
                colors: c,
                tooltip: 'Reset',
              ),
              const SizedBox(width: AppSpacing.md),
              _ControlButton(
                icon: _showGuide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                onPressed: () => setState(() => _showGuide = !_showGuide),
                colors: c,
                tooltip: 'Ẩn/Hiện bóng nét',
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final AppThemeColors colors;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    required this.colors,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: isPrimary ? colors.primary : colors.surfaceLow,
        foregroundColor: isPrimary ? colors.onPrimary : colors.text,
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
      icon: Icon(icon, size: isPrimary ? 28 : 22),
      tooltip: tooltip,
    );
  }
}

/// Vẽ ô kẻ vuông/chéo kiểu "mễ tự cách" (Rice character grid)
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Viền ngoài
    canvas.drawRect(Offset.zero & size, paint);

    // Chữ thập (+)
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Đường chéo (x) nét đứt
    _drawDashedLine(canvas, Offset.zero, Offset(size.width, size.height), paint);
    _drawDashedLine(canvas, Offset(size.width, 0), Offset(0, size.height), paint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5;
    const dashSpace = 5;
    double distance = (p2 - p1).distance;
    int count = (distance / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < count; i++) {
      double start = i * (dashWidth + dashSpace).toDouble();
      double end = start + dashWidth;
      canvas.drawLine(
        Offset.lerp(p1, p2, start / distance)!,
        Offset.lerp(p1, p2, end / distance)!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
