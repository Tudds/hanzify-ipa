import 'package:flutter/material.dart';

class AppCurves {
  AppCurves._();

  /// Standard enter: decelerate into place.
  static const Curve enter = Curves.easeOutCubic;

  /// Standard exit: accelerate out.
  static const Curve exit = Curves.easeInCubic;

  /// Transform in-place (resize, color, position swap).
  static const Curve transform = Curves.easeInOutCubic;

  /// Emphasis: elastic overshoot — for celebration, badge pop.
  static const Curve emphasis = Curves.elasticOut;

  /// Progress bars and rings.
  static const Curve progress = Curves.easeOutQuart;

  /// Spring-like snap-back for swipe cards and drag.
  static const Curve spring = Curves.fastOutSlowIn;

  /// Page transitions (Material standard).
  static const Curve page = Curves.fastOutSlowIn;
}
