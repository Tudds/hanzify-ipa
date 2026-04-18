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
  static const darkPrimary = Color(0xFF6EE7B7);      // More vibrant mint
  static const darkPrimaryContainer = Color(0xFF064E3B);
  static const darkOnPrimary = Color(0xFF022C22);
  static const darkSecondary = Color(0xFF34D399);
  static const darkSecondaryContainer = Color(0xFF064E3B);
  static const darkBackground = Color(0xFF020617); // Deepest
  static const darkSurfaceLowest = Color(0xFF0F172A); // Card background
  static const darkSurface = Color(0xFF1E293B);    // Panels / Navigation
  static const darkSurfaceLow = Color(0xFF334155);    // Chips / Active states
  static const darkText = Color(0xFFF8FAFC);         // Slate 50
  static const darkOnSurfaceVariant = Color(0xFF94A3B8); // Slate 400
  static const darkPlaceholder = Color(0xFF64748B);     // Slate 500
  static const darkDisabled = Color(0xFF1E293B);
  static const darkAccent = Color(0xFF10B981);
  static const darkError = Color(0xFFFCA5A5);
  static const darkSuccess = Color(0xFF34D399);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkOutlineVariant = Color(0xFF334155);

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

  // Semantic Colors
  final List<Color> hskColors;
  final Map<String, Color> posColors;

  // Semantic opacity colors
  final Color onPrimarySoft;       // Colors.white @ 0.85 — soft text on primary bg
  final Color onPrimaryDivider;    // Colors.white @ 0.25 — divider on primary bg
  final Color onPrimaryArrow;      // Colors.white @ 0.8 — arrow on primary bg

  // UI Tokens
  final Gradient primaryGradient;
  final Gradient successGradient;
  final List<BoxShadow> cardShadow;


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
    required this.hskColors,
    required this.posColors,
    required this.onPrimarySoft,
    required this.onPrimaryDivider,
    required this.onPrimaryArrow,
    required this.primaryGradient,
    required this.successGradient,
    required this.cardShadow,
  });

  static final light = AppThemeColors(
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
    hskColors: [
      Color(0xFF10B981), // HSK1
      Color(0xFF3B82F6), // HSK2
      Color(0xFFF59E0B), // HSK3
      Color(0xFFEF4444), // HSK4
      Color(0xFF8B5CF6), // HSK5
      Color(0xFFEC4899), // HSK6
    ],
    posColors: {
      'v': Color(0xFF3B82F6),
      'n': Color(0xFF10B981),
      'adj': Color(0xFFF59E0B),
      'adv': Color(0xFF8B5CF6),
      'prep': Color(0xFFEF4444),
      'conj': Color(0xFFEC4899),
      'pron': Color(0xFF06B6D4),
      'num': Color(0xFF84CC16),
      'mw': Color(0xFF6366F1),
      'aux': Color(0xFFF97316),
      'interj': Color(0xFF14B8A6),
    },
    onPrimarySoft: Colors.white.withValues(alpha: 0.85),
    onPrimaryDivider: Colors.white.withValues(alpha: 0.25),
    onPrimaryArrow: Colors.white.withValues(alpha: 0.8),
    primaryGradient: const LinearGradient(
      colors: [AppColors.lightPrimary, AppColors.lightAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: const LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 40,
        offset: const Offset(0, 12),
      ),
    ],
  );


  static final dark = AppThemeColors(
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
    hskColors: [
      Color(0xFF34D399), // HSK1 (lighter)
      Color(0xFF60A5FA), // HSK2
      Color(0xFFFBBF24), // HSK3
      Color(0xFFF87171), // HSK4
      Color(0xFFA78BFA), // HSK5
      Color(0xFFF472B6), // HSK6
    ],
    posColors: {
      'v': Color(0xFF60A5FA),
      'n': Color(0xFF34D399),
      'adj': Color(0xFFFBBF24),
      'adv': Color(0xFFA78BFA),
      'prep': Color(0xFFF87171),
      'conj': Color(0xFFF472B6),
      'pron': Color(0xFF22D3EE),
      'num': Color(0xFFA3E635),
      'mw': Color(0xFF818CF8),
      'aux': Color(0xFFFB923C),
      'interj': Color(0xFF2DD4BF),
    },
    onPrimarySoft: AppColors.darkOnPrimary.withValues(alpha: 0.75),
    onPrimaryDivider: AppColors.darkOnPrimary.withValues(alpha: 0.15),
    onPrimaryArrow: AppColors.darkOnPrimary.withValues(alpha: 0.6),
    primaryGradient: const LinearGradient(
      colors: [AppColors.darkPrimary, Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: const LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.darkPrimary.withValues(alpha: 0.05),
        blurRadius: 2,
        spreadRadius: 1,
      ),
    ],
  );


  static final sepia = AppThemeColors(
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
    hskColors: [
      Color(0xFF2E7D32),
      Color(0xFF1565C0),
      Color(0xFFE65100),
      Color(0xFFC62828),
      Color(0xFF6A1B9A),
      Color(0xFFAD1457),
    ],
    posColors: {
      'v': Color(0xFF1565C0),
      'n': Color(0xFF2E7D32),
      'adj': Color(0xFFE65100),
      'adv': Color(0xFF6A1B9A),
      'prep': Color(0xFFC62828),
      'conj': Color(0xFFAD1457),
      'pron': Color(0xFF00838F),
      'num': Color(0xFF558B2F),
      'mw': Color(0xFF283593),
      'aux': Color(0xFFEF6C00),
      'interj': Color(0xFF00695C),
    },
    onPrimarySoft: Colors.white.withValues(alpha: 0.85),
    onPrimaryDivider: Colors.white.withValues(alpha: 0.25),
    onPrimaryArrow: Colors.white.withValues(alpha: 0.8),
    primaryGradient: const LinearGradient(
      colors: [AppColors.sepiaPrimary, Color(0xFF8D6E63)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: const LinearGradient(
      colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: [
      BoxShadow(
        color: Color(0xFF5D4037).withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

}
