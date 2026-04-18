// ============================================================================
// HanzifyAppBar — Unified header bar widget
// Replaces duplicated header patterns across 8+ screens:
//   - VocabDetailScreen: rounded back + bookmark trailing
//   - GrammarDetailScreen: rounded back + label
//   - CharacterDetailScreen: iconOnly back + centered title
//   - GrammarScreen: pill back + headline below
//   - QuizQuestionView: pill back + centered label + streak badge
//   - FlashcardScreen: pill back + counter text
//   - QuizModeSelection: pill back (left aligned)
//   - ProfileScreen: AppBar with title + trailing icon
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'hanzify_back_button.dart';
export 'hanzify_back_button.dart';

/// AppBar variant to determine layout behavior
enum HanzifyAppBarVariant {
  /// Back button on left, optional title, optional trailing widget on right
  /// Used in detail screens (VocabDetail, GrammarDetail)
  standard,

  /// Back button on left, title centered, optional trailing widget on right
  /// Used in CharacterDetail (Chi tiết chữ)
  centered,

  /// Back button on left (optionally with label), no trailing
  /// Used in QuizModeSelection (standalone back pill)
  backOnly,

  /// No back button, title centered, optional trailing on right
  /// Used in ProfileScreen
  titleOnly,
}

class HanzifyAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Layout variant
  final HanzifyAppBarVariant variant;

  /// Back button style (only for standard, centered, backOnly)
  final HanzifyBackButtonStyle? backStyle;

  /// Back button label text
  final String backLabel;

  /// Back button shadow
  final List<BoxShadow>? backBoxShadow;

  /// Back button tap callback
  final VoidCallback? onBackTap;

  /// Title text (displayed based on variant)
  final String? title;

  /// Title style override
  final TextStyle? titleStyle;

  /// Widget displayed after title (standard variant) or on right side
  final Widget? trailing;

  /// Background color (null = transparent)
  final Color? backgroundColor;

  /// Bottom border color (null = no border)
  final Color? borderColor;

  /// Padding around the content
  final EdgeInsetsGeometry? padding;

  /// Safe area top padding (default: true)
  final bool safeAreaTop;

  /// Safe area bottom padding (default: false)
  final bool safeAreaBottom;

  /// Elevation / shadow (for titleOnly variant)
  final double elevation;

  /// Bottom widget area (e.g., search bar below header)
  final Widget? bottom;

  const HanzifyAppBar({
    super.key,
    this.variant = HanzifyAppBarVariant.standard,
    this.backStyle,
    this.backLabel = '← Quay lại',
    this.backBoxShadow,
    this.onBackTap,
    this.title,
    this.titleStyle,
    this.trailing,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.safeAreaTop = true,
    this.safeAreaBottom = false,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final bottomHeight = bottom != null ? 56.0 : 0.0;
    return Size.fromHeight(56.0 + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {

    // TitleOnly variant uses native AppBar
    if (variant == HanzifyAppBarVariant.titleOnly) {
      return AppBar(
        backgroundColor: backgroundColor ?? Colors.transparent,
        elevation: elevation,
        centerTitle: true,
        title: title != null
            ? Text(title!, style: titleStyle)
            : null,
        actions: trailing != null ? [trailing!] : null,
        bottom: bottom != null
            ? PreferredSize(preferredSize: const Size.fromHeight(56), child: bottom!)
            : null,
      );
    }

    final defaultBackStyle = backStyle ??
        (variant == HanzifyAppBarVariant.backOnly
            ? HanzifyBackButtonStyle.pill
            : HanzifyBackButtonStyle.rounded);

    Widget content;

    switch (variant) {
      case HanzifyAppBarVariant.standard:
        content = _buildStandard(context, defaultBackStyle);
        break;
      case HanzifyAppBarVariant.centered:
        content = _buildCentered(context, defaultBackStyle);
        break;
      case HanzifyAppBarVariant.backOnly:
        content = _buildBackOnly(context, defaultBackStyle);
        break;
      case HanzifyAppBarVariant.titleOnly:
        content = const SizedBox.shrink(); // handled above
        break;
    }

    final padding = this.padding ??
        EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        );

    return Container(
      color: backgroundColor,
      decoration: borderColor != null
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor!, width: 0.5),
              ),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: padding, child: content),
          ?bottom,
        ],
      ),
    );
  }

  Widget _buildStandard(BuildContext context, HanzifyBackButtonStyle bs) {
    return Row(
      children: [
        HanzifyBackButton(
          style: bs,
          label: backLabel,
          boxShadow: backBoxShadow,
          onTap: onBackTap,
        ),
        if (title != null) ...[
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              title!,
              style: titleStyle ??
                  AppTypography.label(
                    fontSize: AppFontSizes.labelMd,
                    color: Theme.of(context)
                        .extension<AppThemeExtension>()?.colors.primary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const Spacer(),
        ?trailing,
      ],
    );
  }

  Widget _buildCentered(BuildContext context, HanzifyBackButtonStyle bs) {
    return Row(
      children: [
        HanzifyBackButton(
          style: bs,
          label: backLabel,
          boxShadow: backBoxShadow,
          onTap: onBackTap,
        ),
        Expanded(
          child: Text(
            title ?? '',
            style: titleStyle ??
                AppTypography.headline(
                  fontSize: AppFontSizes.titleLg,
                  color: Theme.of(context)
                      .extension<AppThemeExtension>()?.colors.text,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        // Equalizer for center alignment (width matches back button)
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBackOnly(BuildContext context, HanzifyBackButtonStyle bs) {
    return Align(
      alignment: Alignment.centerLeft,
      child: HanzifyBackButton(
        style: bs,
        label: backLabel,
        boxShadow: backBoxShadow,
        onTap: onBackTap,
      ),
    );
  }
}
