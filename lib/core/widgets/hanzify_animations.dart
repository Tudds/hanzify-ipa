import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Extension giữ animation entrance nhất quán trên toàn app.
/// Dùng cho card, list item, section.
extension HanzifyEntrance on Widget {
  /// fadeIn + slideY nhẹ, stagger theo [index].
  Widget hanzifyEntrance({int index = 0, Duration? duration}) {
    return animate()
        .fadeIn(
          delay: (60 * index).ms,
          duration: duration ?? 350.ms,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          curve: Curves.easeOutCubic,
          delay: (60 * index).ms,
          duration: duration ?? 350.ms,
        );
  }
}
