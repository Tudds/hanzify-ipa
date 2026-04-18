import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HomeActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final VoidCallback onTap;
  final String? heroTag;

  const HomeActionCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;

    Widget emojiContent = Text(emoji, style: const TextStyle(fontSize: 28));
    if (heroTag != null) {
      emojiContent = Hero(
        tag: heroTag!,
        child: Material(color: Colors.transparent, child: emojiContent),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.surfaceLowest,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: c.cardShadow,
        ),
        child: Row(
          children: [
            emojiContent,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSizes.titleMd,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySm,
                      color: c.placeholder,
                    ),
                  ),
                ],
              ),
            ),
            Text('›', style: TextStyle(fontSize: 24, color: c.disabled)),
          ],
        ),
      ),
    );
  }
}
