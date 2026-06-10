import 'package:flutter/material.dart';

/// Hanzify design tokens for spacing.
class AppSpacing {
  const AppSpacing._();
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Hanzify design tokens for border radii.
class AppRadii {
  const AppRadii._();
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double circular = 999.0;
}

/// Hanzify Typography helper tokens.
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

  static TextStyle pinyin({required double size, Color? color, FontWeight weight = FontWeight.w600}) {
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
