import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'hanzify_icon_box.dart';

/// Standardized settings list tile: icon + title + optional subtitle + trailing.
class HanzifySettingsTile extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const HanzifySettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.iconBackground,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  State<HanzifySettingsTile> createState() => _HanzifySettingsTileState();
}

class _HanzifySettingsTileState extends State<HanzifySettingsTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.98,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          HanzifyIconBox(
            icon: widget.icon,
            size: HanzifyIconBoxSize.md,
            iconColor: widget.iconColor,
            backgroundColor: widget.iconBackground,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.body(
                    fontSize: AppFontSizes.bodyMd,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodySm,
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) widget.trailing!
          else if (widget.showChevron && widget.onTap != null)
            Icon(
              Icons.chevron_right,
              color: c.onSurfaceVariant,
              size: 20,
            ),
        ],
      ),
    );

    if (widget.onTap == null) return tile;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: tile,
      ),
    );
  }
}
