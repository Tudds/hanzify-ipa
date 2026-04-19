import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HanzifyFilterChip extends StatefulWidget {
  final String label;
  final String? emoji;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  const HanzifyFilterChip({
    super.key,
    required this.label,
    this.emoji,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  @override
  State<HanzifyFilterChip> createState() => _HanzifyFilterChipState();
}

class _HanzifyFilterChipState extends State<HanzifyFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 150),
      lowerBound: 0.93,
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
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;
    final activeColor = widget.activeColor ?? c.primary;
    final isActive = widget.isActive;

    return GestureDetector(
      onTap: () {
        _ctrl.reverse().then((_) => _ctrl.forward());
        widget.onTap();
      },
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor : c.surfaceLowest,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isActive ? activeColor : c.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.emoji != null) ...[
                Text(widget.emoji!, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? c.onPrimary : c.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
