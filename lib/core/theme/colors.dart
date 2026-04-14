import 'package:flutter/material.dart';

class AppColors {
  // Light theme
  static const lightPrimary = Color(0xFF005236);
  static const lightPrimaryContainer = Color(0xFF126c4a);
  static const lightOnPrimary = Colors.white;
  static const lightSecondary = Color(0xFF006c48);
  static const lightSecondaryContainer = Color(0xFF92f7c3);
  static const lightBackground = Color(0xFFf4faff);
  static const lightSurface = Color(0xFFf4faff);
  static const lightSurfaceLowest = Color(0xFFffffff);
  static const lightSurfaceLow = Color(0xFFe7f6ff);
  static const lightText = Color(0xFF0e1d25);
  static const lightOnSurfaceVariant = Color(0xFF404943);
  static const lightPlaceholder = Color(0xFF707973);
  static const lightDisabled = Color(0xFFbfc9c1);
  static const lightAccent = Color(0xFF40916C);
  static const lightError = Color(0xFFba1a1a);
  static const lightSuccess = Color(0xFF10B981);
  static const lightWarning = Color(0xFFF59E0B);
  static const lightOutlineVariant = Color(0xFFbfc9c1);

  // Dark theme
  static const darkPrimary = Color(0xFF86d7ad);
  static const darkPrimaryContainer = Color(0xFF005236);
  static const darkOnPrimary = Color(0xFF003921);
  static const darkSecondary = Color(0xFF75daa8);
  static const darkSecondaryContainer = Color(0xFF005235);
  static const darkBackground = Color(0xFF0e1d25);
  static const darkSurface = Color(0xFF0e1d25);
  static const darkSurfaceLowest = Color(0xFF060e17);
  static const darkSurfaceLow = Color(0xFF131b2e);
  static const darkText = Color(0xFFdae2fd);
  static const darkOnSurfaceVariant = Color(0xFFb9cacb);
  static const darkPlaceholder = Color(0xFF849495);
  static const darkDisabled = Color(0xFF3a494b);
  static const darkAccent = Color(0xFF86d7ad);
  static const darkError = Color(0xFFffb4ab);
  static const darkSuccess = Color(0xFF10B981);
  static const darkWarning = Color(0xFFF59E0B);
  static const darkOutlineVariant = Color(0xFF3a494b);

  // Sepia theme
  static const sepiaPrimary = Color(0xFF704214);
  static const sepiaPrimaryContainer = Color(0xFFf4ecd8);
  static const sepiaOnPrimary = Colors.white;
  static const sepiaSecondary = Color(0xFF5d4037);
  static const sepiaSecondaryContainer = Color(0xFFefebe9);
  static const sepiaBackground = Color(0xFFf4ecd8);
  static const sepiaSurface = Color(0xFFf4ecd8);
  static const sepiaSurfaceLowest = Color(0xFFfffbf0);
  static const sepiaSurfaceLow = Color(0xFFede4ce);
  static const sepiaText = Color(0xFF3c2f2f);
  static const sepiaOnSurfaceVariant = Color(0xFF5d4037);
  static const sepiaPlaceholder = Color(0xFF8d6e63);
  static const sepiaDisabled = Color(0xFFd7ccc8);
  static const sepiaAccent = Color(0xFF795548);
  static const sepiaError = Color(0xFFd32f2f);
  static const sepiaSuccess = Color(0xFF388e3c);
  static const sepiaWarning = Color(0xFFf57c00);
  static const sepiaOutlineVariant = Color(0xFFd7ccc8);
}

class AppThemeColors {
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color secondary;
  final Color secondaryContainer;
  final Color background;
  final Color surface;
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color text;
  final Color onSurfaceVariant;
  final Color placeholder;
  final Color disabled;
  final Color accent;
  final Color error;
  final Color success;
  final Color warning;
  final Color danger;
  final Color outlineVariant;


  const AppThemeColors({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.text,
    required this.onSurfaceVariant,
    required this.placeholder,
    required this.disabled,
    required this.accent,
    required this.error,
    required this.success,
    required this.warning,
    required this.danger,
    required this.outlineVariant,
  });

  static const light = AppThemeColors(
    primary: AppColors.lightPrimary,
    primaryContainer: AppColors.lightPrimaryContainer,
    onPrimary: AppColors.lightOnPrimary,
    secondary: AppColors.lightSecondary,
    secondaryContainer: AppColors.lightSecondaryContainer,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceLowest: AppColors.lightSurfaceLowest,
    surfaceLow: AppColors.lightSurfaceLow,
    text: AppColors.lightText,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    placeholder: AppColors.lightPlaceholder,
    disabled: AppColors.lightDisabled,
    accent: AppColors.lightAccent,
    error: AppColors.lightError,
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    danger: AppColors.lightError,
    outlineVariant: AppColors.lightOutlineVariant,
  );


  static const dark = AppThemeColors(
    primary: AppColors.darkPrimary,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimary: AppColors.darkOnPrimary,
    secondary: AppColors.darkSecondary,
    secondaryContainer: AppColors.darkSecondaryContainer,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceLowest: AppColors.darkSurfaceLowest,
    surfaceLow: AppColors.darkSurfaceLow,
    text: AppColors.darkText,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    placeholder: AppColors.darkPlaceholder,
    disabled: AppColors.darkDisabled,
    accent: AppColors.darkAccent,
    error: AppColors.darkError,
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    danger: AppColors.darkError,
    outlineVariant: AppColors.darkOutlineVariant,
  );


  static const sepia = AppThemeColors(
    primary: AppColors.sepiaPrimary,
    primaryContainer: AppColors.sepiaPrimaryContainer,
    onPrimary: AppColors.sepiaOnPrimary,
    secondary: AppColors.sepiaSecondary,
    secondaryContainer: AppColors.sepiaSecondaryContainer,
    background: AppColors.sepiaBackground,
    surface: AppColors.sepiaSurface,
    surfaceLowest: AppColors.sepiaSurfaceLowest,
    surfaceLow: AppColors.sepiaSurfaceLow,
    text: AppColors.sepiaText,
    onSurfaceVariant: AppColors.sepiaOnSurfaceVariant,
    placeholder: AppColors.sepiaPlaceholder,
    disabled: AppColors.sepiaDisabled,
    accent: AppColors.sepiaAccent,
    error: AppColors.sepiaError,
    success: AppColors.sepiaSuccess,
    warning: AppColors.sepiaWarning,
    danger: AppColors.sepiaError,
    outlineVariant: AppColors.sepiaOutlineVariant,
  );

}
