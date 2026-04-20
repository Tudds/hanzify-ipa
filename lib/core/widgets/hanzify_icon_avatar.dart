import 'package:flutter/material.dart';

enum HanzifyAvatarSize {
  xs,
  sm,
  md,
  lg,
  xl,
}

class HanzifyIconAvatar extends StatelessWidget {
  final HanzifyAvatarSize size;
  final double? customSize;
  final IconData? icon;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;
  final bool useGradient;
  final List<Color>? gradientColors;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const HanzifyIconAvatar({
    super.key,
    this.size = HanzifyAvatarSize.sm,
    this.customSize,
    this.icon,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize,
    this.useGradient = false,
    this.gradientColors,
    this.border,
    this.boxShadow,
  });

  factory HanzifyIconAvatar.person({
    Key? key,
    HanzifyAvatarSize size = HanzifyAvatarSize.sm,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return HanzifyIconAvatar(
      key: key,
      size: size,
      icon: Icons.person_rounded,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  factory HanzifyIconAvatar.resultHeader({
    Key? key,
    required String emoji,
    required Color color,
  }) {
    return HanzifyIconAvatar(
      key: key,
      size: HanzifyAvatarSize.xl,
      useGradient: true,
      gradientColors: [
        color.withValues(alpha: 0.2),
        color.withValues(alpha: 0.05),
      ],
      child: Text(emoji, style: const TextStyle(fontSize: 56)),
    );
  }

  factory HanzifyIconAvatar.hanzi({
    Key? key,
    required String character,
    HanzifyAvatarSize size = HanzifyAvatarSize.md,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final s = _getSizeDimension(size);
    final fontSize = s > 50 ? 24.0 : 18.0;

    return HanzifyIconAvatar(
      key: key,
      size: size,
      backgroundColor: backgroundColor,
      child: Text(
        character,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: textColor,
          fontFamily: 'NotoSansSC',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  factory HanzifyIconAvatar.emoji({
    Key? key,
    required String emoji,
    HanzifyAvatarSize size = HanzifyAvatarSize.sm,
    Color? backgroundColor,
  }) {
    final s = _getSizeDimension(size);
    return HanzifyIconAvatar(
      key: key,
      size: size,
      backgroundColor: backgroundColor,
      child: Text(
        emoji,
        style: TextStyle(fontSize: s * 0.55),
      ),
    );
  }

  factory HanzifyIconAvatar.feature({
    Key? key,
    required IconData featureIcon,
    required Color iconColor,
    HanzifyAvatarSize size = HanzifyAvatarSize.sm,
  }) {
    return HanzifyIconAvatar(
      key: key,
      size: size,
      icon: featureIcon,
      backgroundColor: iconColor.withValues(alpha: 0.1),
      foregroundColor: iconColor,
    );
  }

  static double _getSizeDimension(HanzifyAvatarSize s) {
    switch (s) {
      case HanzifyAvatarSize.xs: return 32;
      case HanzifyAvatarSize.sm: return 40;
      case HanzifyAvatarSize.md: return 56;
      case HanzifyAvatarSize.lg: return 80;
      case HanzifyAvatarSize.xl: return 110;
    }
  }

  double get _dimension => customSize ?? _getSizeDimension(size);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dim = _dimension;
    final bg = backgroundColor ?? cs.surfaceContainerHigh;
    final fg = foregroundColor ?? cs.onSurfaceVariant;
    final icSize = iconSize ?? (dim * 0.5);

    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: useGradient ? null : bg,
        gradient: useGradient ? LinearGradient(
          colors: gradientColors ?? [cs.primaryContainer, cs.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      alignment: Alignment.center,
      child: child ?? Icon(icon, color: fg, size: icSize),
    );
  }
}
