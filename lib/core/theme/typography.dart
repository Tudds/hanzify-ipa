import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xxxs = 2;
  static const double xxs = 5;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ── Named semantic sizes ─────────────────────────────────────────────
  static const double iconSm = 20;
  static const double iconMd = 28;
  static const double iconLg = 44;
  static const double iconXl = 60;
  static const double fabSize = 60;
  static const double fabSpacing = 80;
  static const double tabHeight = 100;
  static const double circularProgress = 220;

  /// Padding bottom chuẩn cho mọi scrollview có bottom nav + FAB che.
  static const double scrollBottom = 120;
}

class AppRadii {
  static const double xs = 6;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double md2 = 10;
  static const double xl = 16;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double full = 9999;
}

class AppFontSizes {
  static const double displayLg = 56;
  static const double displayMd = 40;
  static const double displaySm = 32;
  static const double headlineLg = 28;
  static const double headlineMd = 24;
  static const double headlineSm = 20;
  static const double titleLg = 18;
  static const double titleMd = 16;
  static const double titleSm = 14;
  static const double bodyLg = 16;
  static const double bodyMd = 14;
  static const double bodySm = 12;
  static const double labelLg = 14;
  static const double labelMd = 12;
  static const double labelSm = 11;
}

/// Centralized typography helpers using the design system fonts.
/// - Headlines: Manrope (ExtraBold/Bold)
/// - Body/Labels: Inter
/// - Hanzi display: Noto Serif SC (traditional/educational feel)
/// - Hanzi UI: Noto Sans SC (clean/compact)
class AppTypography {
  // ── Headlines (Manrope) ──────────────────────────────────────────────────
  static TextStyle headline({
    double fontSize = AppFontSizes.headlineLg,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sectionTitle({Color? color}) {
    return GoogleFonts.manrope(
      fontSize: AppFontSizes.labelMd,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 1.2,
    );
  }

  // ── Body / Labels (Inter) ────────────────────────────────────────────────
  static TextStyle body({
    double fontSize = AppFontSizes.bodyMd,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle label({
    double fontSize = AppFontSizes.labelMd,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // ── Hanzi (Noto Serif SC for display, Sans SC for UI) ────────────────────
  static TextStyle hanziDisplay({
    double fontSize = AppFontSizes.displayLg,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.notoSerifSc(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle hanziUi({
    double fontSize = AppFontSizes.headlineMd,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.notoSansSc(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // ── Pinyin (Inter or Manrope, colored) ───────────────────────────────────
  static TextStyle pinyin({
    double fontSize = AppFontSizes.bodyMd,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
