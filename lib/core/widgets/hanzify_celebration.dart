import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class HanzifyCelebration extends StatefulWidget {
  const HanzifyCelebration({super.key});

  @override
  State<HanzifyCelebration> createState() => _HanzifyCelebrationState();
}

class _HanzifyCelebrationState extends State<HanzifyCelebration> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirection: pi / 2, // radial value - SOUTH
        particleDrag: 0.05,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.05,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ], // manually specify colors
      ),
    );
  }
}
