// ============================================================================
// HanzifyIconAvatar — Unified icon/avatar circle widget
// Replaces duplicated circle icon patterns across 8+ screens:
//   - ProfileScreen: CircleAvatar(radius:44) with person icon
//   - HomeScreen: CircleAvatar(radius:18) with person icon
//   - VocabListScreen: CircleAvatar(radius:20) with person icon
//   - HomeScreen: Container(44x44) circle with dialogue icons
//   - VocabListScreen: Container(56x56) circle with Hanzi text
//   - GrammarScreen: Container(48x48) circle with Hanzi character
//   - QuizResultsView: Container(110x110) with emoji in gradient circle
//   - FlashcardFinishedView: Container(110x110) with emoji in gradient circle
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';

/// Avatar size presets
enum HanzifyAvatarSize {
  /// 36x36 — small icons
  xs,

  /// 44x44 — regular icon avatars (dialogue items, profile mini)
  sm,

  /// 56x56 — medium (vocab list hanzi circle)
  md,

  /// 80x80 — large
  lg,

  /// 110x110 — result header (quiz results, flashcard finished)
  xl,
}

class HanzifyIconAvatar extends StatelessWidget {
  /// Size preset
  final HanzifyAvatarSize size;

  /// Custom size override (takes precedence over size preset)
  final double? customSize;

  /// Icon to display inside the circle
  final IconData? icon;

  /// Custom child widget (e.g., Text with hanzi character)
  /// Takes precedence over icon
  final Widget? child;

  /// Background color
  final Color? backgroundColor;

  /// Icon/foreground color
  final Color? foregroundColor;

  /// Icon size (null = auto-calculated based on avatar size)
  final double? iconSize;

  /// Whether to use gradient background
  final bool useGradient;

  /// Gradient colors (requires useGradient = true)
  final List<Color>? gradientColors;

  /// Border
  final BoxBorder? border;

  /// Box shadow
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

  /// Convenience: Person avatar (user icon in colored circle)
  /// Used in HomeScreen, ProfileScreen, VocabListScreen
  factory HanzifyIconAvatar.person({
    Key? key,
    HanzifyAvatarSize size = HanzifyAvatarSize.sm,
    AppThemeColors? colors,
    Color? backgroundColor,
  }) {
    final c = colors;
    return HanzifyIconAvatar(
      key: key,
      size: size,
      icon: Icons.person_rounded,
      backgroundColor: backgroundColor ??
          (size == HanzifyAvatarSize.md
              ? (c?.primary ?? const Color(0xFF005236)).withValues(alpha: 0.15)
              : c?.surfaceLow ?? const Color(0xFFe7f6ff)),
      foregroundColor: size == HanzifyAvatarSize.md
          ? c?.primary ?? const Color(0xFF005236)
          : c?.placeholder ?? const Color(0xFF707973),
    );
  }

  /// Convenience: Result header circle with emoji and gradient background
  /// Used in QuizResultsView, FlashcardFinishedView
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

  /// Convenience: Hanzi character in colored circle
  /// Used in VocabListScreen (56x56), GrammarScreen (48x48)
  factory HanzifyIconAvatar.hanzi({
    Key? key,
    required String character,
    HanzifyAvatarSize size = HanzifyAvatarSize.md,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final s = _getSizeDimension(size);
    final fontSize = s > 50
        ? (character.length > 2 ? AppFontSizes.titleMd : AppFontSizes.headlineMd)
        : AppFontSizes.titleLg;

    return HanzifyIconAvatar(
      key: key,
      size: size,
      backgroundColor: backgroundColor,
      child: Text(
        character,
        style: AppTypography.hanziUi(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Convenience: Emoji in colored circle
  /// Used in Conversation list items
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

  /// Convenience: Feature icon in colored circle
  /// Used in HomeScreen dialogue items (44x44)
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
      backgroundColor: iconColor.withValues(alpha: 0.12),
      foregroundColor: iconColor,
    );
  }

  static double _getSizeDimension(HanzifyAvatarSize s) {
    switch (s) {
      case HanzifyAvatarSize.xs: return 36;
      case HanzifyAvatarSize.sm: return 44;
      case HanzifyAvatarSize.md: return 56;
      case HanzifyAvatarSize.lg: return 80;
      case HanzifyAvatarSize.xl: return 110;
    }
  }

  double get _dimension => customSize ?? _getSizeDimension(size);

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final dim = _dimension;
    final fg = foregroundColor ?? c.text;
    final icSize = iconSize ?? (dim * 0.5);

    BoxDecoration decoration;

    if (useGradient && gradientColors != null) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      );
    } else {
      decoration = BoxDecoration(
        color: backgroundColor ?? c.surfaceLow,
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      );
    }

    return Container(
      width: dim,
      height: dim,
      decoration: decoration,
      alignment: Alignment.center,
      child: child ??
          Icon(icon, color: fg, size: icSize),
    );
  }
}
