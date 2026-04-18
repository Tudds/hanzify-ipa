// ============================================================================
// AppRoutes — Centralized navigation route constants
// Replaces hardcoded route strings ('home', 'vocabList', 'flashcard', etc.)
// scattered across 15+ files
// ============================================================================
class AppRoutes {
  AppRoutes._();

  // ── Tab screens ───────────────────────────────────────────────────────
  static const String home = 'home';
  static const String vocabList = 'vocabList';
  static const String progress = 'progress';
  static const String profile = 'profile';

  // ── Feature screens ──────────────────────────────────────────────────
  static const String flashcard = 'flashcard';
  static const String grammar = 'grammar';
  static const String quiz = 'quiz';
  static const String charDetail = 'charDetail';
  static const String conversation = 'conversation';

  // ── Tab visibility set ───────────────────────────────────────────────
  /// Screens that show the bottom tab bar
  static const tabBarScreens = [home, vocabList, progress, profile];
}
