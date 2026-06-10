import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/performance_provider.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../data/character_repository.dart';
import '../../domain/character_strokes.dart';

class StrokeOrderWidget extends ConsumerStatefulWidget {
  const StrokeOrderWidget({
    super.key,
    required this.character,
    this.size = 220,
    this.autoPlay = true,
    this.strokeMs = 600,
  });

  final String character;
  final double size;
  final bool autoPlay;
  final int strokeMs;

  @override
  ConsumerState<StrokeOrderWidget> createState() => _StrokeOrderWidgetState();
}

class _StrokeOrderWidgetState extends ConsumerState<StrokeOrderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  CharacterStrokes? _data;
  bool _loading = true;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.strokeMs),
    );
    _load();
  }

  Future<void> _load() async {
    final data =
        await ref.read(characterRepositoryProvider).load(widget.character);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
    if (data != null && data.strokes.isNotEmpty) {
      _controller.duration = Duration(
        milliseconds: (widget.strokeMs * data.strokes.length / _speed).round(),
      );
      if (widget.autoPlay) _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant StrokeOrderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character != widget.character) {
      _loading = true;
      _data = null;
      _controller.reset();
      _load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    HanzifyHaptic.selection();
    _controller.reset();
    _controller.forward();
  }

  void _toggle() {
    HanzifyHaptic.selection();
    if (_controller.isAnimating) {
      _controller.stop();
    } else if (_controller.value >= 1.0) {
      _controller.reset();
      _controller.forward();
    } else {
      _controller.forward();
    }
  }

  void _setSpeed(double speed) {
    _speed = speed;
    final data = _data;
    if (data == null) return;
    final wasAnimating = _controller.isAnimating;
    final progress = _controller.value;
    _controller.duration = Duration(
      milliseconds: (widget.strokeMs * data.strokes.length / speed).round(),
    );
    _controller.value = progress;
    if (wasAnimating) _controller.forward();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);

    if (_loading) {
      return SizedBox(
        height: widget.size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _data;
    if (data == null || data.strokes.isEmpty) {
      return _Fallback(character: widget.character, size: widget.size);
    }

    return Column(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _StrokeOrderPainter(
                    strokes: data.strokes,
                    progress: performance ? 1.0 : _controller.value,
                    fillColor: colors.onSurface,
                    outlineColor: colors.onSurfaceVariant,
                    grid: true,
                    gridColor: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!performance)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _toggle,
                icon: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Icon(
                    _controller.isAnimating
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _replay,
                icon: const Icon(Icons.replay_rounded),
              ),
              const SizedBox(width: 12),
              for (final s in const [0.5, 1.0, 2.0])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    selected: _speed == s,
                    label: Text('${s}x'),
                    onSelected: (_) => _setSpeed(s),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 4),
        Text(
          '${data.strokes.length} net',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.character, required this.size});

  final String character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        character,
        style: TextStyle(
          fontSize: size * 0.5,
          color: colors.onSurface,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _StrokeOrderPainter extends CustomPainter {
  _StrokeOrderPainter({
    required this.strokes,
    required this.progress,
    required this.fillColor,
    required this.outlineColor,
    required this.grid,
    required this.gridColor,
  });

  final List<ui.Path> strokes;
  final double progress;
  final Color fillColor;
  final Color outlineColor;
  final bool grid;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (grid) _paintGrid(canvas, size);

    final scale = size.width / 1024;
    canvas.save();
    canvas.translate(0, size.height);
    canvas.scale(scale, -scale);

    final outlinePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = outlineColor.withValues(alpha: 0.12);
    final activePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final strokeProgress = progress * strokes.length;

    for (var i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      if (i + 1 <= strokeProgress) {
        canvas.drawPath(stroke, activePaint);
      } else if (i < strokeProgress) {
        final alpha = (strokeProgress - i).clamp(0.0, 1.0);
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = fillColor.withValues(alpha: alpha);
        canvas.drawPath(stroke, paint);
      } else {
        canvas.drawPath(stroke, outlinePaint);
      }
    }

    canvas.restore();
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    final dashPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.6)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), dashPaint);
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrokeOrderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokes != strokes ||
        oldDelegate.fillColor != fillColor;
  }
}
