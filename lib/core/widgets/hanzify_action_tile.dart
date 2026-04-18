// ============================================================================
// HanzifyActionTile — Unified action / feature card widget
// Replaces 4 duplicate patterns:
//   - HomeActionCard (home_action_card.dart)
//   - Flashcard/Quiz action cards (progress_screen.dart)
//   - _QuickActionTile (bottom_tab_bar.dart)
//   - _CompactGrammarCard (grammar_screen.dart)
// Supports icon/emoji, title, subtitle, trailing, gradient/outline variants
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';

/// Style variants for HanzifyActionTile
enum HanzifyActionTileStyle {
  /// Gradient background with white text (flashcard button in progress_screen)
  gradient,

  /// Outlined border with themed text (quiz button in progress_screen)
  outlined,

  /// Tinted background with colored icon (quick action tiles)
  tinted,

  /// Clean card with icon circle + text (compact grammar card)
  clean,
}

class HanzifyActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? emoji;
  final AppThemeColors colors;
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
    required this.colors,
    this.accentColor,
    this.gradient,
    this.onTap,
    this.trailing,
    this.style = HanzifyActionTileStyle.tinted,
  });

  static Widget variantGradient({
    required String title,
    required String subtitle,
    required AppThemeColors colors,
    String? emoji,
    IconData? icon,
    VoidCallback? onTap,
    Gradient? customGradient,
  }) {
    return HanzifyActionTile(
      title: title,
      subtitle: subtitle,
      colors: colors,
      emoji: emoji,
      icon: icon,
      onTap: onTap,
      gradient: customGradient,
      style: HanzifyActionTileStyle.gradient,
    );
  }

  static Widget variantOutlined({
    required String title,
    required String subtitle,
    required AppThemeColors colors,
    String? emoji,
    IconData? icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return HanzifyActionTile(
      title: title,
      subtitle: subtitle,
      colors: colors,
      emoji: emoji,
      icon: icon,
      onTap: onTap,
      trailing: trailing,
      style: HanzifyActionTileStyle.outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? colors.primary;

    switch (style) {
      case HanzifyActionTileStyle.gradient:
        return _buildGradient(accent);
      case HanzifyActionTileStyle.outlined:
        return _buildOutlined();
      case HanzifyActionTileStyle.tinted:
        return _buildTinted(accent);
      case HanzifyActionTileStyle.clean:
        return _buildClean(accent);
    }
  }

  // ── Gradient variant (e.g. Flashcard CTA in progress_screen) ──────────

  Widget _buildGradient(Color accent) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? colors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 28)),
            if (icon != null)
              Icon(icon!, color: colors.onPrimary, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headline(
                      fontSize: AppFontSizes.titleMd,
                      fontWeight: FontWeight.w800,
                      color: colors.onPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodySm,
                        color: colors.onPrimarySoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                color: colors.onPrimaryArrow, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Outlined variant (e.g. Quiz CTA in progress_screen) ───────────────

  Widget _buildOutlined() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(color: colors.outlineVariant, width: 1.5),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 28)),
            if (icon != null)
              Icon(icon!, color: colors.primary, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headline(
                      fontSize: AppFontSizes.titleMd,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodySm,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_rounded,
                    color: colors.placeholder, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Tinted variant (e.g. Quick action tiles in bottom_sheet) ──────────

  Widget _buildTinted(Color accent) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xxl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(color: accent.withValues(alpha: 0.12), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: icon != null
                  ? Icon(icon!, color: accent, size: 28)
                  : null,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodyLg,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodySm,
                        color: colors.placeholder,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: accent.withValues(alpha: 0.4), size: 24),
          ],
        ),
      ),
    );
  }

  // ── Clean variant (e.g. Compact grammar card) ─────────────────────────

  Widget _buildClean(Color accent) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Circular icon / emoji container
          if (emoji != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                emoji!,
                style: TextStyle(fontSize: 22),
              ),
            )
          else if (icon != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon!, color: accent, size: AppSpacing.iconSm),
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label(
                    fontSize: AppFontSizes.titleSm,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodySm,
                      color: colors.placeholder,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: colors.disabled, size: 20),
        ],
      ),
    );
  }
}
