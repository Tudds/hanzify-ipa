import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

enum HanzifyTextFieldVariant { filled, outlined, search }

/// Standardized text field with consistent focus/error/disabled states.
class HanzifyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final HanzifyTextFieldVariant variant;
  final int? maxLines;

  const HanzifyTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = HanzifyTextFieldVariant.filled,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;

    final radius = BorderRadius.circular(AppRadii.lg);
    final borderColor = errorText != null ? c.error : c.outlineVariant;
    final focusColor = errorText != null ? c.error : c.primary;

    InputDecoration decoration;
    switch (variant) {
      case HanzifyTextFieldVariant.filled:
        decoration = InputDecoration(
          hintText: hint,
          labelText: label,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: c.surfaceLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: focusColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: c.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: c.error, width: 1.5),
          ),
          hintStyle: AppTypography.body(color: c.placeholder),
          labelStyle: AppTypography.body(color: c.onSurfaceVariant),
          errorStyle: AppTypography.body(
            fontSize: AppFontSizes.bodySm,
            color: c.error,
          ),
        );
      case HanzifyTextFieldVariant.outlined:
        decoration = InputDecoration(
          hintText: hint,
          labelText: label,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: focusColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: c.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: c.error, width: 1.5),
          ),
          hintStyle: AppTypography.body(color: c.placeholder),
          labelStyle: AppTypography.body(color: c.onSurfaceVariant),
        );
      case HanzifyTextFieldVariant.search:
        decoration = InputDecoration(
          hintText: hint ?? 'Tìm kiếm...',
          prefixIcon: prefixIcon ?? Icon(Icons.search, color: c.placeholder, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: c.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: c.primary, width: 1.5),
          ),
          hintStyle: AppTypography.body(color: c.placeholder),
        );
    }

    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
      style: AppTypography.body(color: c.text),
      decoration: decoration,
    );
  }
}
