// ============================================================================
// HanzifyResultHeader — Result/celebration header with large emoji circle
// Replaces duplicated result header patterns:
//   - QuizResultsView: emoji in 110x110 gradient circle
//   - FlashcardFinishedView: trophy in 110x110 gradient circle
// ============================================================================
import 'package:flutter/material.dart';
import 'hanzify_icon_avatar.dart';

class HanzifyResultHeader extends StatelessWidget {
  /// Emoji to display (e.g., '🌟', '🏆')
  final String emoji;

  /// Color used for gradient background
  final Color color;

  /// Size of the circle container (default: 110)
  final double size;

  /// Font size of the emoji (default: 56)
  final double emojiSize;

  const HanzifyResultHeader({
    super.key,
    required this.emoji,
    required this.color,
    this.size = 110,
    this.emojiSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return HanzifyIconAvatar(
      size: HanzifyAvatarSize.xl,
      customSize: size,
      useGradient: true,
      gradientColors: [
        color.withValues(alpha: 0.2),
        color.withValues(alpha: 0.05),
      ],
      child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
    );
  }
}
