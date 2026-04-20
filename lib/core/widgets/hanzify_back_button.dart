import 'package:flutter/material.dart';

enum HanzifyBackButtonStyle {
  rounded,
  pill,
  iconOnly,
}

class HanzifyBackButton extends StatelessWidget {
  final HanzifyBackButtonStyle style;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const HanzifyBackButton({
    super.key,
    this.style = HanzifyBackButtonStyle.rounded,
    this.label = 'Quay lại',
    this.color,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    switch (style) {
      case HanzifyBackButtonStyle.rounded:
        return IconButton.filledTonal(
          onPressed: onTap ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor ?? cs.surfaceContainerHigh,
            foregroundColor: color ?? cs.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      case HanzifyBackButtonStyle.pill:
        return TextButton.icon(
          onPressed: onTap ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: color ?? cs.primary,
            backgroundColor: cs.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const StadiumBorder(),
          ),
        );
      case HanzifyBackButtonStyle.iconOnly:
        return IconButton(
          onPressed: onTap ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          color: color ?? cs.onSurface,
        );
    }
  }
}
