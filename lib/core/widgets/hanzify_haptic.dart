import 'package:flutter/services.dart';

class HanzifyHaptic {
  HanzifyHaptic._();

  static Future<void> selection() => HapticFeedback.selectionClick();
  static Future<void> light() => HapticFeedback.lightImpact();
  static Future<void> medium() => HapticFeedback.mediumImpact();
  static Future<void> success() => HapticFeedback.lightImpact();
  static Future<void> error() => HapticFeedback.heavyImpact();
}
