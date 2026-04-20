import 'package:flutter/material.dart';

enum HanzifyButtonType { primary, outline, danger, tonal }

class HanzifyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final HanzifyButtonType type;
  final double? width;
  final IconData? icon;

  const HanzifyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.type = HanzifyButtonType.primary,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget button;
    switch (type) {
      case HanzifyButtonType.outline:
        button = icon != null
            ? OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label))
            : OutlinedButton(onPressed: onTap, child: Text(label));
        break;
      case HanzifyButtonType.danger:
        button = icon != null
            ? FilledButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: 18),
                label: Text(label),
                style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
              )
            : FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                child: Text(label),
              );
        break;
      case HanzifyButtonType.tonal:
        button = icon != null
            ? FilledButton.tonalIcon(onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label))
            : FilledButton.tonal(onPressed: onTap, child: Text(label));
        break;
      case HanzifyButtonType.primary:
        button = icon != null
            ? FilledButton.icon(onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label))
            : FilledButton(onPressed: onTap, child: Text(label));
        break;
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
