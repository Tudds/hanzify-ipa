import 'package:flutter/material.dart';

enum HanzifyTextFieldVariant { filled, outlined, search }

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(16);

    InputDecoration decoration;
    switch (variant) {
      case HanzifyTextFieldVariant.search:
        decoration = InputDecoration(
          hintText: hint ?? 'Tìm kiếm...',
          prefixIcon: prefixIcon ?? Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: cs.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.primary, width: 2)),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        );
        break;
      case HanzifyTextFieldVariant.outlined:
        decoration = InputDecoration(
          hintText: hint,
          labelText: label,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: radius),
          enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.outline)),
          focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.primary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.error, width: 2)),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        );
        break;
      case HanzifyTextFieldVariant.filled:
        decoration = InputDecoration(
          hintText: hint,
          labelText: label,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: cs.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: UnderlineInputBorder(borderRadius: radius.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero)),
          enabledBorder: UnderlineInputBorder(borderRadius: radius.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero), borderSide: BorderSide(color: cs.outlineVariant)),
          focusedBorder: UnderlineInputBorder(borderRadius: radius.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero), borderSide: BorderSide(color: cs.primary, width: 2)),
          errorBorder: UnderlineInputBorder(borderRadius: radius.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero), borderSide: BorderSide(color: cs.error, width: 2)),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        );
        break;
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
      style: theme.textTheme.bodyLarge,
      decoration: decoration,
    );
  }
}
