import 'package:flutter/material.dart';

/// Painter chịu trách nhiệm vẽ các nét chữ Hán từ SVG path data.
/// Dữ liệu từ HanziWriter có hệ tọa độ 0-1024, Y=0 ở đáy (bottom).
/// Vì vậy cần flip Y-axis và scale cho phù hợp với kích thước widget.
class StrokePainter extends CustomPainter {
  final List<String> svgPaths;
  final int currentStrokeIndex; // chỉ mục nét đang được vẽ
  final bool showOutline;       // hiện bóng mờ của toàn bộ chữ
  final double animationValue;  // 0.0 -> 1.0 (opacity hoặc tiến độ vẽ)
  final Color strokeColor;
  final Color outlineColor;
  final bool drawFullCharacter; // vẽ tất cả các nét (đã hoàn thành)

  StrokePainter({
    required this.svgPaths,
    required this.currentStrokeIndex,
    this.showOutline = true,
    this.animationValue = 1.0,
    required this.strokeColor,
    required this.outlineColor,
    this.drawFullCharacter = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (svgPaths.isEmpty) return;

    // 1. Tính toán tỉ lệ scale (HanziWriter chuẩn là 1024x1024)
    final double scale = size.width / 1024.0;

    // 2. Chuyển đổi hệ tọa độ: 
    // - Flutter: Origin Top-Left
    // - HanziWriter: Origin Bottom-Left
    canvas.save();
    canvas.translate(0, size.height);
    canvas.scale(scale, -scale);

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;

    // 3. Vẽ Outline (bóng mờ)
    if (showOutline) {
      fillPaint.color = outlineColor;
      for (final pathData in svgPaths) {
        final Path path = _parseSvgPath(pathData);
        canvas.drawPath(path, fillPaint);
      }
    }

    // 4. Vẽ các nét đã hoàn thành (nếu không phải mode vẽ full luôn)
    if (!drawFullCharacter) {
      fillPaint.color = strokeColor;
      for (int i = 0; i < currentStrokeIndex; i++) {
        final Path path = _parseSvgPath(svgPaths[i]);
        canvas.drawPath(path, fillPaint);
      }

      // 5. Vẽ nét hiện tại với animation (opacity)
      if (currentStrokeIndex < svgPaths.length) {
        fillPaint.color = strokeColor.withValues(alpha: animationValue);
        final Path path = _parseSvgPath(svgPaths[currentStrokeIndex]);
        canvas.drawPath(path, fillPaint);
      }
    } else {
      // Vẽ toàn bộ chữ (cho chế độ xem tĩnh)
      fillPaint.color = strokeColor;
      for (final pathData in svgPaths) {
        final Path path = _parseSvgPath(pathData);
        canvas.drawPath(path, fillPaint);
      }
    }

    canvas.restore();
  }

  /// Parser siêu cơ bản cho SVG Path data (M, L, Q, C, Z)
  /// Phù hợp với format của HanziWriter (chủ yếu là M, Q, Z)
  Path _parseSvgPath(String data) {
    final Path path = Path();
    final RegExp regExp = RegExp(r'([a-zA-Z])|(-?\d*\.?\d+)');
    final matches = regExp.allMatches(data).toList();

    int i = 0;
    while (i < matches.length) {
      String? command = matches[i].group(1);
      if (command == null) {
        i++;
        continue;
      }
      i++;

      switch (command) {
        case 'M':
          double x = double.parse(matches[i++].group(2)!);
          double y = double.parse(matches[i++].group(2)!);
          path.moveTo(x, y);
          break;
        case 'L':
          double x = double.parse(matches[i++].group(2)!);
          double y = double.parse(matches[i++].group(2)!);
          path.lineTo(x, y);
          break;
        case 'Q':
          double x1 = double.parse(matches[i++].group(2)!);
          double y1 = double.parse(matches[i++].group(2)!);
          double x = double.parse(matches[i++].group(2)!);
          double y = double.parse(matches[i++].group(2)!);
          path.quadraticBezierTo(x1, y1, x, y);
          break;
        case 'C':
          double x1 = double.parse(matches[i++].group(2)!);
          double y1 = double.parse(matches[i++].group(2)!);
          double x2 = double.parse(matches[i++].group(2)!);
          double y2 = double.parse(matches[i++].group(2)!);
          double x = double.parse(matches[i++].group(2)!);
          double y = double.parse(matches[i++].group(2)!);
          path.cubicTo(x1, y1, x2, y2, x, y);
          break;
        case 'Z':
        case 'z':
          path.close();
          break;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return oldDelegate.currentStrokeIndex != currentStrokeIndex ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.showOutline != showOutline ||
        oldDelegate.drawFullCharacter != drawFullCharacter;
  }
}
