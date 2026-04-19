import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// Wraps [child] with a confetti burst overlay.
///
/// Call [HanzifyConfettiOverlay.of(context).play()] to trigger.
/// Or use [HanzifyConfettiOverlayController] directly.
class HanzifyConfettiOverlay extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const HanzifyConfettiOverlay({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  });

  static HanzifyConfettiOverlayState? of(BuildContext context) =>
      context.findAncestorStateOfType<HanzifyConfettiOverlayState>();

  @override
  State<HanzifyConfettiOverlay> createState() => HanzifyConfettiOverlayState();
}

class HanzifyConfettiOverlayState extends State<HanzifyConfettiOverlay> {
  late final ConfettiController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ConfettiController(duration: widget.duration);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void play() => _ctrl.play();
  void stop() => _ctrl.stop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _ctrl,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            gravity: 0.3,
            emissionFrequency: 0.05,
            colors: const [
              Color(0xFF4A90E2),
              Color(0xFF22C55E),
              Color(0xFFF59E0B),
              Color(0xFFEF4444),
              Color(0xFF8B5CF6),
              Color(0xFFEC4899),
            ],
          ),
        ),
      ],
    );
  }
}

/// Standalone controller — use when you need to trigger confetti
/// from a provider/notifier without access to BuildContext.
class HanzifyConfettiOverlayController {
  final ConfettiController _ctrl;

  HanzifyConfettiOverlayController({
    Duration duration = const Duration(seconds: 3),
  }) : _ctrl = ConfettiController(duration: duration);

  void play() => _ctrl.play();
  void stop() => _ctrl.stop();
  void dispose() => _ctrl.dispose();

  Widget buildWidget({required Widget child}) => ConfettiWidget(
    confettiController: _ctrl,
    blastDirectionality: BlastDirectionality.explosive,
    shouldLoop: false,
    numberOfParticles: 30,
    gravity: 0.3,
    emissionFrequency: 0.05,
    colors: const [
      Color(0xFF4A90E2), Color(0xFF22C55E), Color(0xFFF59E0B),
      Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFFEC4899),
    ],
  );
}

