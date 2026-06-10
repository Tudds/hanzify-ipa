import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Hanzify Premium Theme configuration.
class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final baseTextTheme = ThemeData.dark(useMaterial3: true).textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Manrope',
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.textPrimary,
        primaryContainer: AppColors.surfaceCard,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textPrimary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHigh: AppColors.surfaceCard,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.textMuted,
        outlineVariant: AppColors.surfaceGlow,
      ),
      textTheme: baseTextTheme.copyWith(
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 36,
          fontWeight: FontWeight.w800,
          height: 1.15,
          color: AppColors.textPrimary,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.textPrimary,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 19,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: AppColors.textSecondary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: AppColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontFamily: 'Manrope',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
