// ============================================================================
// AppDurations — Centralized animation duration constants
// Replaces magic Duration(milliseconds: N) values scattered across the app
// ============================================================================
class AppDurations {
  AppDurations._();

  /// 150ms — Micro-interactions (haptic feedback, tiny animations)
  static const Duration micro = Duration(milliseconds: 150);

  /// 200ms — Standard tap feedback, small transitions
  static const Duration fast = Duration(milliseconds: 200);

  /// 250ms — Medium transitions, animated size changes
  static const Duration normal = Duration(milliseconds: 250);

  /// 300ms — Page transitions, overlay animations
  static const Duration slow = Duration(milliseconds: 300);

  /// 350ms — Detailed page transitions
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// 400ms — Full-screen transitions, modal animations
  static const Duration modal = Duration(milliseconds: 400);

  /// 1400ms — Quiz feedback delay (time before auto-advancing to next question)
  static const Duration quizFeedback = Duration(milliseconds: 1400);

  /// 1500ms — Counter/number animations
  static const Duration counter = Duration(milliseconds: 1500);

  // ── Study-specific ───────────────────────────────────────────────────

  /// 450ms — Flashcard reveal (AnimatedSwitcher fade+scale).
  static const Duration flip = Duration(milliseconds: 450);

  /// 800ms — Daily goal ring fill, progress bar.
  static const Duration celebrate = Duration(milliseconds: 800);

  /// 1200ms — Streak badge scale + particle burst.
  static const Duration streak = Duration(milliseconds: 1200);

  /// 2000ms — Character stroke-order animation (single stroke).
  static const Duration stroke = Duration(milliseconds: 2000);
}
