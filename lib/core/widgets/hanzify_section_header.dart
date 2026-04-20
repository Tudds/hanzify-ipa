import 'package:flutter/material.dart';

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
    final cs = theme.colorScheme;

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
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
