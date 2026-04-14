import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

enum ButtonVariant { primary, secondary, outline }

class AppButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final bool disabled;
  final ButtonVariant variant;
  final AppThemeColors colors;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.colors,
    this.disabled = false,
    this.variant = ButtonVariant.primary,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bg {
    if (widget.disabled) return widget.colors.disabled.withValues(alpha: 0.4);
    switch (widget.variant) {
      case ButtonVariant.secondary: return widget.colors.secondaryContainer;
      case ButtonVariant.outline: return Colors.transparent;
      default: return widget.colors.primary;
    }
  }

  Color get _textColor {
    if (widget.disabled) return widget.colors.placeholder;
    switch (widget.variant) {
      case ButtonVariant.secondary: return widget.colors.primary;
      case ButtonVariant.outline: return widget.colors.primary;
      default: return widget.colors.onPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); if (!widget.disabled) widget.onPressed(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xl,
          ),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: widget.variant == ButtonVariant.outline
                ? Border.all(color: widget.colors.outlineVariant)
                : null,
          ),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor,
              fontSize: AppFontSizes.titleSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
