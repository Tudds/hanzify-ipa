import 'package:flutter/material.dart';

class AppColors {
  // ── Light (Minimal Blue) ───────────────────────────────────────────────────
  static const lightPrimary = Color(0xFF4A90E2);
  static const lightPrimaryContainer = Color(0xFFE8F1FC);
  static const lightOnPrimary = Colors.white;
  static const lightSecondary = Color(0xFF6366F1);
  static const lightSecondaryContainer = Color(0xFFEEEEFF);
  static const lightBackground = Color(0xFFF8F9FB);
  static const lightSurface = Color(0xFFF0F2F5);
  static const lightSurfaceLowest = Color(0xFFFFFFFF);
  static const lightSurfaceLow = Color(0xFFE8EBF0);
  static const lightText = Color(0xFF1A1A1A);
  static const lightOnSurfaceVariant = Color(0xFF6B7280);
  static const lightPlaceholder = Color(0xFF9CA3AF);
  static const lightDisabled = Color(0xFFD1D5DB);
  static const lightAccent = Color(0xFF4A90E2);
  static const lightError = Color(0xFFEF4444);
  static const lightSuccess = Color(0xFF22C55E);
  static const lightWarning = Color(0xFFF59E0B);
  static const lightOutlineVariant = Color(0xFFE5E7EB);

  // ── Dark (Navy Blue) ───────────────────────────────────────────────────────
  static const darkPrimary = Color(0xFF7CB9F5);
  static const darkPrimaryContainer = Color(0xFF1E3A5F);
  static const darkOnPrimary = Color(0xFF0D1B2E);
  static const darkSecondary = Color(0xFF818CF8);
  static const darkSecondaryContainer = Color(0xFF2D2F5E);
  static const darkBackground = Color(0xFF0F1117);
  static const darkSurfaceLowest = Color(0xFF1A1D27);
  static const darkSurface = Color(0xFF22263A);
  static const darkSurfaceLow = Color(0xFF2E3347);
  static const darkText = Color(0xFFF0F2F5);
  static const darkOnSurfaceVariant = Color(0xFF9CA3AF);
  static const darkPlaceholder = Color(0xFF6B7280);
  static const darkDisabled = Color(0xFF374151);
  static const darkAccent = Color(0xFF7CB9F5);
  static const darkError = Color(0xFFF87171);
  static const darkSuccess = Color(0xFF4ADE80);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkOutlineVariant = Color(0xFF2E3347);

  // ── Sepia ──────────────────────────────────────────────────────────────────
  static const sepiaPrimary = Color(0xFF704214);
  static const sepiaPrimaryContainer = Color(0xFFf4ecd8);
  static const sepiaOnPrimary = Colors.white;
  static const sepiaSecondary = Color(0xFF8D6E63);
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
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;
  final Color surfaceTint;

  // Custom Semantic Colors
  final Color success;
  final Color warning;
  final Color danger;
  final List<Color> hskColors;
  final Map<String, Color> posColors;

  // Study semantic colors
  final Color studyCorrect;
  final Color studyCorrectContainer;
  final Color studyWrong;
  final Color studyWrongContainer;
  final Color studyDue;
  final Color studyNew;
  final Color studyMastered;

  // Legacy compatibility tokens (mapped to M3 equivalents)
  Color get text => onSurface;
  Color get disabled => onSurface.withValues(alpha: 0.38);
  Color get placeholder => onSurfaceVariant.withValues(alpha: 0.6);
  Color get surfaceLowest => surface;
  Color get surfaceLow => Color.alphaBlend(surfaceTint.withValues(alpha: 0.05), surface);
  Color get accent => primary;

  // Compatibility tokens for migration (Deprecated)
  @Deprecated('Use surfaceContainerLow instead')
  Color get glassSurface => surfaceContainerLow;
  @Deprecated('Use outlineVariant instead')
  Color get glassBorder => outlineVariant;
  @Deprecated('Use onPrimary with alpha instead')
  Color get onPrimarySoft => onPrimary.withValues(alpha: 0.85);
  @Deprecated('Use onPrimary with alpha instead')
  Color get onPrimaryDivider => onPrimary.withValues(alpha: 0.2);
  @Deprecated('Use onPrimary instead')
  Color get onPrimaryArrow => onPrimary;
  @Deprecated('Use cardShadow instead')
  List<BoxShadow> get glowShadow => cardShadow;
  @Deprecated('Use primaryGradient instead')
  Gradient get accentGradient => primaryGradient;

  // Mapped Gradients (Simplifying for M3)
  Gradient get primaryGradient => LinearGradient(colors: [primary, secondary]);
  Gradient get successGradient => LinearGradient(colors: [success, Color.alphaBlend(Colors.black.withValues(alpha: 0.1), success)]);
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  Color get surfaceContainerLow => Color.alphaBlend(surfaceTint.withValues(alpha: 0.05), surface);

  const AppThemeColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.surfaceTint,
    required this.success,
    required this.warning,
    required this.danger,
    required this.hskColors,
    required this.posColors,
    required this.studyCorrect,
    required this.studyCorrectContainer,
    required this.studyWrong,
    required this.studyWrongContainer,
    required this.studyDue,
    required this.studyNew,
    required this.studyMastered,
  });

  factory AppThemeColors.fromColorScheme(ColorScheme cs, {
    required Color success,
    required Color warning,
    required Color danger,
    required List<Color> hskColors,
    required Map<String, Color> posColors,
    required Color studyCorrect,
    required Color studyCorrectContainer,
    required Color studyWrong,
    required Color studyWrongContainer,
    required Color studyDue,
    required Color studyNew,
    required Color studyMastered,
  }) {
    return AppThemeColors(
      primary: cs.primary,
      onPrimary: cs.onPrimary,
      primaryContainer: cs.primaryContainer,
      onPrimaryContainer: cs.onPrimaryContainer,
      secondary: cs.secondary,
      onSecondary: cs.onSecondary,
      secondaryContainer: cs.secondaryContainer,
      onSecondaryContainer: cs.onSecondaryContainer,
      tertiary: cs.tertiary,
      onTertiary: cs.onTertiary,
      tertiaryContainer: cs.tertiaryContainer,
      onTertiaryContainer: cs.onTertiaryContainer,
      error: cs.error,
      onError: cs.onError,
      errorContainer: cs.errorContainer,
      onErrorContainer: cs.onErrorContainer,
      background: cs.surface,
      onBackground: cs.onSurface,
      surface: cs.surface,
      onSurface: cs.onSurface,
      surfaceVariant: cs.surfaceContainerHighest,
      onSurfaceVariant: cs.onSurfaceVariant,
      outline: cs.outline,
      outlineVariant: cs.outlineVariant,
      shadow: cs.shadow,
      scrim: cs.scrim,
      inverseSurface: cs.inverseSurface,
      onInverseSurface: cs.onInverseSurface,
      inversePrimary: cs.inversePrimary,
      surfaceTint: cs.surfaceTint,
      success: success,
      warning: warning,
      danger: danger,
      hskColors: hskColors,
      posColors: posColors,
      studyCorrect: studyCorrect,
      studyCorrectContainer: studyCorrectContainer,
      studyWrong: studyWrong,
      studyWrongContainer: studyWrongContainer,
      studyDue: studyDue,
      studyNew: studyNew,
      studyMastered: studyMastered,
    );
  }

  static final light = AppThemeColors.fromColorScheme(
    ColorScheme.fromSeed(
      seedColor: AppColors.lightPrimary,
      brightness: Brightness.light,
    ),
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    danger: AppColors.lightError,
    hskColors: const [
      Color(0xFF22C55E), Color(0xFF4A90E2), Color(0xFFF59E0B),
      Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFFEC4899),
    ],
    posColors: const {
      'v': Color(0xFF4A90E2), 'n': Color(0xFF22C55E), 'adj': Color(0xFFF59E0B),
      'adv': Color(0xFF8B5CF6), 'prep': Color(0xFFEF4444), 'conj': Color(0xFFEC4899),
      'pron': Color(0xFF06B6D4), 'num': Color(0xFF84CC16), 'mw': Color(0xFF6366F1),
      'aux': Color(0xFFF97316), 'interj': Color(0xFF14B8A6),
    },
    studyCorrect: Color(0xFF16A34A),
    studyCorrectContainer: Color(0xFFDCFCE7),
    studyWrong: Color(0xFFDC2626),
    studyWrongContainer: Color(0xFFFEE2E2),
    studyDue: Color(0xFFF59E0B),
    studyNew: Color(0xFF4A90E2),
    studyMastered: Color(0xFF22C55E),
  );

  static final dark = AppThemeColors.fromColorScheme(
    ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
    ),
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    danger: AppColors.darkError,
    hskColors: const [
      Color(0xFF4ADE80), Color(0xFF7CB9F5), Color(0xFFFBBF24),
      Color(0xFFF87171), Color(0xFFA78BFA), Color(0xFFF472B6),
    ],
    posColors: const {
      'v': Color(0xFF7CB9F5), 'n': Color(0xFF4ADE80), 'adj': Color(0xFFFBBF24),
      'adv': Color(0xFFA78BFA), 'prep': Color(0xFFF87171), 'conj': Color(0xFFF472B6),
      'pron': Color(0xFF22D3EE), 'num': Color(0xFFA3E635), 'mw': Color(0xFF818CF8),
      'aux': Color(0xFFFB923C), 'interj': Color(0xFF2DD4BF),
    },
    studyCorrect: Color(0xFF4ADE80),
    studyCorrectContainer: Color(0xFF14532D),
    studyWrong: Color(0xFFF87171),
    studyWrongContainer: Color(0xFF7F1D1D),
    studyDue: Color(0xFFFBBF24),
    studyNew: Color(0xFF7CB9F5),
    studyMastered: Color(0xFF4ADE80),
  );

  static final sepia = AppThemeColors.fromColorScheme(
    ColorScheme.fromSeed(
      seedColor: AppColors.sepiaPrimary,
      brightness: Brightness.light,
    ),
    success: AppColors.sepiaSuccess,
    warning: AppColors.sepiaWarning,
    danger: AppColors.sepiaError,
    hskColors: const [
      Color(0xFF2E7D32), Color(0xFF1565C0), Color(0xFFE65100),
      Color(0xFFC62828), Color(0xFF6A1B9A), Color(0xFFAD1457),
    ],
    posColors: const {
      'v': Color(0xFF1565C0), 'n': Color(0xFF2E7D32), 'adj': Color(0xFFE65100),
      'adv': Color(0xFF6A1B9A), 'prep': Color(0xFFC62828), 'conj': Color(0xFFAD1457),
      'pron': Color(0xFF00838F), 'num': Color(0xFF558B2F), 'mw': Color(0xFF283593),
      'aux': Color(0xFFEF6C00), 'interj': Color(0xFF00695C),
    },
    studyCorrect: Color(0xFF2E7D32),
    studyCorrectContainer: Color(0xFFD7F0D8),
    studyWrong: Color(0xFFC62828),
    studyWrongContainer: Color(0xFFFDE8E8),
    studyDue: Color(0xFFE65100),
    studyNew: Color(0xFF1565C0),
    studyMastered: Color(0xFF388E3C),
  );
}
