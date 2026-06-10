import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConversationVectorBackground extends StatelessWidget {
  const ConversationVectorBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/images/conversation_background.svg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.68),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
