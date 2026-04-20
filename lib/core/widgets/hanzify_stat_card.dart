import 'package:flutter/material.dart';

enum HanzifyStatCardLayout { vertical, horizontal }

class HanzifyStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final HanzifyStatCardLayout layout;

  const HanzifyStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.textColor,
    this.layout = HanzifyStatCardLayout.vertical,
    @Deprecated('Use theme instead') dynamic colors,
  });

  const HanzifyStatCard.vertical({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.textColor,
  }) : layout = HanzifyStatCardLayout.vertical;

  const HanzifyStatCard.horizontal({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.textColor,
  }) : layout = HanzifyStatCardLayout.horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: layout == HanzifyStatCardLayout.vertical ? _buildVertical(cs, theme) : _buildHorizontal(cs, theme),
      ),
    );
  }

  Widget _buildVertical(ColorScheme cs, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? cs.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHorizontal(ColorScheme cs, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? cs.primary, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
