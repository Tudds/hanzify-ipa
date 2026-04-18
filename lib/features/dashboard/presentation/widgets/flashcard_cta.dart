import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class FlashcardCTA extends StatelessWidget {
  final int dueCount;

  const FlashcardCTA({super.key, required this.dueCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: c.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        boxShadow: c.cardShadow,
      ),
      child: Row(
        children: [
          const Text('🧘', style: TextStyle(fontSize: 36)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flashcard Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dueCount > 0 ? '$dueCount cards waiting' : 'Practice all cards',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xBFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '→',
            style: TextStyle(fontSize: 24, color: Color(0x99FFFFFF)),
          ),
        ],
      ),
    );
  }
}
