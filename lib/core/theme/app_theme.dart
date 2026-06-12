import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Hanzify theme — Premium Dark theo skill flutter-ui.
///
/// Dark-first: dark là theme chính, light là bản phái sinh từ cùng seed
/// (chưa expose mặc định cho user — bật qua `themeModeProvider` sau khi
/// audit từng màn hình với light).
class AppTheme {
  const AppTheme._();

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: kSeedColor,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final baseTextTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
    ).textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: 'Inter',
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      scaffoldBackgroundColor: colors.surface,
      textTheme: AppTypography.textTheme(colors, baseTextTheme),
      cardTheme: const CardThemeData(elevation: 0),
      extensions: [
        brightness == Brightness.dark
            ? AppSemanticColors.dark
            : AppSemanticColors.light,
      ],
    );
  }
}

/// Token shortcuts theo skill flutter-ui — `context.colors.primary`,
/// `context.semantic.success`, `context.text.titleMedium`.
extension UITokens on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  /// Fallback theo brightness để widget vẫn chạy dưới theme không đăng ký
  /// extension (test pump MaterialApp trần, preview...).
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>() ??
      (isDark ? AppSemanticColors.dark : AppSemanticColors.light);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
