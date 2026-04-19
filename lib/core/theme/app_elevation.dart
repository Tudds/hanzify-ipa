import 'package:flutter/material.dart';

/// Standardized BoxShadow presets. Max blurRadius=16, alpha<=0.08 light / <=0.35 dark.
/// Use [AppElevation.forTheme] to get the right set for the current brightness.
class AppElevation {
  AppElevation._();

  // ── Light shadows ────────────────────────────────────────────────────
  static const List<BoxShadow> flatLight = [];

  static final List<BoxShadow> raisedLight = [
    BoxShadow(
      color: const Color(0xFF1A1A1A).withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> floatingLight = [
    BoxShadow(
      color: const Color(0xFF1A1A1A).withValues(alpha: 0.07),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> modalLight = [
    BoxShadow(
      color: const Color(0xFF1A1A1A).withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Dark shadows ─────────────────────────────────────────────────────
  static const List<BoxShadow> flatDark = [];

  static final List<BoxShadow> raisedDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.20),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> floatingDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> modalDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.40),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Returns the correct shadow set based on brightness and level.
  /// [level]: 0=flat, 1=raised, 2=floating, 3=modal
  static List<BoxShadow> forTheme(Brightness brightness, {int level = 1}) {
    final isDark = brightness == Brightness.dark;
    return switch (level) {
      0 => const [],
      1 => isDark ? raisedDark : raisedLight,
      2 => isDark ? floatingDark : floatingLight,
      3 => isDark ? modalDark : modalLight,
      _ => isDark ? raisedDark : raisedLight,
    };
  }
}
