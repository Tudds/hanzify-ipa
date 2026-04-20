import 'package:flutter/material.dart';

enum HanzifyActionTileStyle {
  gradient,
  outlined,
  tinted,
  clean,
}

class HanzifyActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? emoji;
  final Color? accentColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Widget? trailing;
  final HanzifyActionTileStyle style;

  const HanzifyActionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.emoji,
    this.accentColor,
    this.gradient,
    this.onTap,
    this.trailing,
    this.style = HanzifyActionTileStyle.tinted,
    @Deprecated('Use theme instead') dynamic colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = accentColor ?? cs.primary;

    switch (style) {
      case HanzifyActionTileStyle.gradient:
        return _buildGradient(cs, accent);
      case HanzifyActionTileStyle.outlined:
        return _buildOutlined(cs, accent);
      case HanzifyActionTileStyle.tinted:
        return _buildTinted(cs, accent, theme);
      case HanzifyActionTileStyle.clean:
        return _buildClean(cs, accent, theme);
    }
  }

  Widget _buildGradient(ColorScheme cs, Color accent) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? LinearGradient(colors: [cs.primary, cs.primaryContainer]),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 32)),
                if (icon != null) Icon(icon!, color: cs.onPrimary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onPrimary)),
                      if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 14, color: cs.onPrimary.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: cs.onPrimary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlined(ColorScheme cs, Color accent) {
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 32)),
              if (icon != null) Icon(icon!, color: accent, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent)),
                    if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              trailing ?? Icon(Icons.arrow_forward_rounded, color: cs.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTinted(ColorScheme cs, Color accent, ThemeData theme) {
    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: icon != null ? Icon(icon!, color: accent, size: 24) : (emoji != null ? Center(child: Text(emoji!, style: const TextStyle(fontSize: 24))) : null),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              trailing ?? Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClean(ColorScheme cs, Color accent, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (emoji != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(emoji!, style: const TextStyle(fontSize: 20)),
              )
            else if (icon != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon!, color: accent, size: 20),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
