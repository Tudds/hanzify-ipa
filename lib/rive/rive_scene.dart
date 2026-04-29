import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'hanzify_rive_scene_controller.dart';

class RiveScene extends StatelessWidget {
  const RiveScene({
    super.key,
    required this.asset,
    required this.stateMachineName,
    this.controller,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String asset;
  final String stateMachineName;
  final HanzifyRiveSceneController? controller;
  final BoxFit fit;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (asset.isEmpty) {
      return placeholder ?? const SizedBox.expand();
    }

    return RiveAnimation.asset(
      asset,
      fit: fit,
      onInit: (artboard) {
        final stateMachine = StateMachineController.fromArtboard(
          artboard,
          stateMachineName,
        );

        if (stateMachine == null) {
          return;
        }

        artboard.addController(stateMachine);
        controller?.bind(stateMachine);
      },
    );
  }
}
