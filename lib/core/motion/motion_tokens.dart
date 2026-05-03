import 'package:flutter/animation.dart';

class MotionTokens {
  const MotionTokens._();

  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 260);
  static const feedbackHold = Duration(milliseconds: 700);

  static const feedbackCurve = Curves.easeOutBack;
  static const exitCurve = Curves.easeIn;
}
