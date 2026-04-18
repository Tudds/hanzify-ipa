import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

/// Reusable section header: Icon + UPPERCASE title + optional trailing widget.
///
/// Matches the design system pattern used across Home, Detail, Dictionary screens.
/// Example: `[icon] BÀI HỌC                              Xem tất cả >`
class HanzifySectionHeader extends StatelessWidget {
  final String title;
  final String? emoji;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const HanzifySectionHeader({
    super.key,
    required this.title,
    this.emoji,
    this.icon,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.sm),
          ] else if (icon != null) ...[
            Icon(icon, size: 18, color: c.primary),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            title.toUpperCase(),
            style: AppTypography.sectionTitle(color: c.text),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
