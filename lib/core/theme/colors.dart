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

  // ── Study semantic colors ─────────────────────────────────────────────
  final Color studyCorrect;
  final Color studyCorrectContainer;
  final Color studyWrong;
  final Color studyWrongContainer;
  final Color studyDue;
  final Color studyNew;
  final Color studyMastered;

  // Semantic opacity colors
  final Color onPrimarySoft;
  final Color onPrimaryDivider;
  final Color onPrimaryArrow;

  // ── Design tokens ────────────────────────────────────────────────────────
  final Color glassSurface;
  final Color glassBorder;
  final Gradient accentGradient;
  final List<BoxShadow> glowShadow;
  final Gradient heroMesh;
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
    required this.studyCorrect,
    required this.studyCorrectContainer,
    required this.studyWrong,
    required this.studyWrongContainer,
    required this.studyDue,
    required this.studyNew,
    required this.studyMastered,
    required this.onPrimarySoft,
    required this.onPrimaryDivider,
    required this.onPrimaryArrow,
    required this.glassSurface,
    required this.glassBorder,
    required this.accentGradient,
    required this.glowShadow,
    required this.heroMesh,
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
    onPrimarySoft: Colors.white.withValues(alpha: 0.90),
    onPrimaryDivider: Colors.white.withValues(alpha: 0.30),
    onPrimaryArrow: Colors.white.withValues(alpha: 0.85),
    glassSurface: Colors.white.withValues(alpha: 0.80),
    glassBorder: const Color(0xFFE5E7EB),
    accentGradient: const LinearGradient(
      colors: [Color(0xFF4A90E2), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowShadow: [
      BoxShadow(
        color: const Color(0xFF4A90E2).withValues(alpha: 0.20),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    heroMesh: const LinearGradient(
      colors: [Color(0xFFF0F6FF), Color(0xFFF5F3FF), Color(0xFFF8F9FB)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: const LinearGradient(
      colors: [Color(0xFF4A90E2), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: const LinearGradient(
      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: [
      BoxShadow(
        color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
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
    onPrimarySoft: AppColors.darkOnPrimary.withValues(alpha: 0.85),
    onPrimaryDivider: AppColors.darkOnPrimary.withValues(alpha: 0.20),
    onPrimaryArrow: AppColors.darkOnPrimary.withValues(alpha: 0.70),
    glassSurface: Colors.white.withValues(alpha: 0.05),
    glassBorder: Colors.white.withValues(alpha: 0.10),
    accentGradient: const LinearGradient(
      colors: [Color(0xFF7CB9F5), Color(0xFF818CF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowShadow: [
      BoxShadow(
        color: const Color(0xFF7CB9F5).withValues(alpha: 0.18),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
    heroMesh: const LinearGradient(
      colors: [Color(0xFF0F1827), Color(0xFF141828), Color(0xFF0F1117)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: const LinearGradient(
      colors: [Color(0xFF7CB9F5), Color(0xFF818CF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: const LinearGradient(
      colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 4),
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
    onPrimarySoft: Colors.white.withValues(alpha: 0.85),
    onPrimaryDivider: Colors.white.withValues(alpha: 0.25),
    onPrimaryArrow: Colors.white.withValues(alpha: 0.8),
    glassSurface: const Color(0xFFFFFBF0).withValues(alpha: 0.75),
    glassBorder: const Color(0xFF704214).withValues(alpha: 0.15),
    accentGradient: const LinearGradient(
      colors: [Color(0xFF704214), Color(0xFF8D6E63)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowShadow: [
      BoxShadow(
        color: const Color(0xFF704214).withValues(alpha: 0.12),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    heroMesh: const LinearGradient(
      colors: [Color(0xFFFFFBF0), Color(0xFFF4ECD8), Color(0xFFEDE4CE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
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
        color: const Color(0xFF5D4037).withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
