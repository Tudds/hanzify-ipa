import 'package:flutter/material.dart';

import '../../../core/audio/audio_play_button.dart';
import '../domain/review_challenge.dart';

class ReviewSessionPanel extends StatelessWidget {
  const ReviewSessionPanel({
    super.key,
    required this.challenge,
    this.onAnswer,
    this.onChoice,
  });

  final ReviewChallenge challenge;
  final ValueChanged<bool>? onAnswer;
  final ValueChanged<String>? onChoice;

  void _handleChoice(String choice) {
    onChoice?.call(choice);
    onAnswer?.call(choice == challenge.answer);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    challenge.prompt,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (challenge.audioUrl != null) ...[
                  const SizedBox(width: 8),
                  AudioPlayButton(url: challenge.audioUrl, size: 28),
                ],
              ],
            ),
            const SizedBox(height: 16),
            for (final choice in challenge.choices) ...[
              FilledButton.tonal(
                onPressed: () => _handleChoice(choice),
                child: Text(choice),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
