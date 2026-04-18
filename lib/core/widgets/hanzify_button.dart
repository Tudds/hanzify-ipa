import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

enum HanzifyButtonType { primary, outline, danger }

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
    final themeColors = theme.extension<AppThemeExtension>()?.colors ?? AppThemeColors.light;

    switch (type) {
      case HanzifyButtonType.primary:
        return _buildGradientButton(themeColors);
      case HanzifyButtonType.outline:
        return _buildOutlineButton(themeColors);
      case HanzifyButtonType.danger:
        return _buildDangerButton(themeColors);
    }
  }

  Widget _buildGradientButton(AppThemeColors c) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: c.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: c.cardShadow,
        ),
        child: _buildLabel(c.onPrimary),
      ),
    );
  }

  Widget _buildOutlineButton(AppThemeColors c) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
        decoration: BoxDecoration(
          border: Border.all(color: c.disabled.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: _buildLabel(c.text),
      ),
    );
  }

  Widget _buildDangerButton(AppThemeColors c) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.danger.withValues(alpha: 0.1),
          border: Border.all(color: c.danger.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: _buildLabel(c.danger),
      ),
    );
  }

  Widget _buildLabel(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: AppFontSizes.bodyLg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
