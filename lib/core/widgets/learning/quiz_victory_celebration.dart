import 'package:flutter/material.dart';

/// Hanzify victory celebration progress gauge widget.
/// Vẽ biểu đồ đường tròn tiến trình và hiển thị kết quả chúc mừng bằng CustomPainter.
class QuizVictoryCelebration extends StatelessWidget {
  const QuizVictoryCelebration({
    super.key,
    required this.score,
    required this.total,
    required this.performance,
  });

  final int score;
  final int total;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pct = total == 0 ? 0.0 : score / total;
    final emoji = pct >= 0.9
        ? '🏆'
        : pct >= 0.7
        ? '🎉'
        : pct >= 0.5
        ? '👍'
        : '💪';

    final textStyle = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: pct),
            duration: performance ? Duration.zero : const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(160, 160),
                    painter: _VictoryGaugePainter(
                      percentage: value,
                      trackColor: colors.outlineVariant.withValues(alpha: 0.24),
                      progressColor: pct >= 0.5 ? colors.primary : colors.error,
                      strokeWidth: 10,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 42),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(value * 100).toInt()}%',
                        style: textStyle.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          pct >= 0.9
              ? 'Xuất sắc!'
              : pct >= 0.7
                  ? 'Tuyệt vời!'
                  : pct >= 0.5
                      ? 'Hoàn thành!'
                      : 'Lần sau sẽ tốt hơn!',
          style: textStyle.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đúng $score trên $total câu',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VictoryGaugePainter extends CustomPainter {
  _VictoryGaugePainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double percentage;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    if (percentage > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * 3.1415926535 * percentage;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.1415926535 / 2, // Start from top 12 o'clock
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VictoryGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
