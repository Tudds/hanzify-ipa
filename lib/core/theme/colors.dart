import 'package:flutter/material.dart';

/// Seed màu thương hiệu Hanzify (Royal Purple). Toàn bộ palette M3 được sinh
/// từ seed này qua [ColorScheme.fromSeed] — không tự đặt màu lẻ trong widget,
/// luôn đọc qua `Theme.of(context).colorScheme`.
const kSeedColor = Color(0xFF7C5CFF);

/// Màu ngữ nghĩa cho app học (đúng / sắp tới hạn / sai) — M3 không có sẵn
/// success/warning nên định nghĩa qua [ThemeExtension] để theo theme.
///
/// Không truyền thông tin CHỈ bằng màu — luôn kèm icon/label (a11y, mù màu).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color success;
  final Color warning;
  final Color danger;

  static const dark = AppSemanticColors(
    success: Color(0xFF4ADE80), // green, desaturate cho dark
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  static const light = AppSemanticColors(
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
  );

  @override
  AppSemanticColors copyWith({Color? success, Color? warning, Color? danger}) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
