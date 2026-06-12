import 'package:flutter/material.dart';

/// Hanzify design tokens for spacing — thang 4pt theo skill flutter-ui.
class AppSpacing {
  const AppSpacing._();
  static const double xs = 4.0; // icon ↔ label
  static const double sm = 8.0; // padding trong nhỏ
  static const double md = 12.0; // gap giữa elements
  static const double lg = 16.0; // padding chuẩn / margin màn hình
  static const double xl = 24.0; // gap giữa section
  static const double xxl = 32.0; // block lớn
}

/// Hanzify design tokens for border radii — nhất quán theo skill flutter-ui.
class AppRadii {
  const AppRadii._();
  static const double chip = 8.0;
  static const double button = 12.0;
  static const double card = 16.0;
  static const double sheet = 24.0;
  static const double circular = 999.0;
}

/// Hanzify Typography helper tokens.
///
/// UI (Latin + tiếng Việt) dùng **Inter** (self-host subset, đủ glyph Việt +
/// pinyin tones — không dùng google_fonts vì COEP/web perf). Chữ Hán dùng
/// Noto Serif/Sans SC apply cục bộ, không global.
class AppTypography {
  const AppTypography._();

  static const fontFamilyFallback = <String>[
    'Inter',
    'Noto Sans',
    'Noto Sans SC',
    'PingFang SC',
    'Microsoft YaHei',
    'Arial',
    'sans-serif',
  ];

  static const hanziFontFamilyFallback = <String>[
    'Noto Serif SC',
    'Noto Sans SC',
    'PingFang SC',
    'Microsoft YaHei',
    'serif',
  ];

  /// Type scale theo skill flutter-ui: ≤ 5 cấp, tương phản bằng weight + size.
  static TextTheme textTheme(ColorScheme colors, TextTheme base) {
    final themed = base.apply(
      fontFamily: 'Inter',
      fontFamilyFallback: fontFamilyFallback,
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    );
    return themed.copyWith(
      displayLarge: themed.displayLarge?.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyMedium: themed.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: colors.onSurfaceVariant,
      ),
      labelSmall: themed.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: colors.onSurfaceVariant,
      ),
    );
  }

  static TextStyle hanziDisplay({required double size, Color? color}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      fontFamily: 'Noto Serif SC',
      fontFamilyFallback: hanziFontFamilyFallback,
      color: color,
      height: 1.15,
    );
  }

  static TextStyle pinyin({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      fontFamily: 'Inter',
      fontFamilyFallback: fontFamilyFallback,
      color: color,
      letterSpacing: 0.2,
    );
  }
}
