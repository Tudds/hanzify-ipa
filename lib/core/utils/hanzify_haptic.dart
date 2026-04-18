import 'package:flutter/services.dart';

/// Quy tắc haptic thống nhất toàn app.
/// - [select] khi chọn chip/option/toggle
/// - [tap] khi tap card/list item để navigate
/// - [action] cho primary CTA (FAB, submit, flashcard grade)
class HanzifyHaptic {
  const HanzifyHaptic._();

  static void select() => HapticFeedback.selectionClick();
  static void tap() => HapticFeedback.lightImpact();
  static void action() => HapticFeedback.mediumImpact();
}
