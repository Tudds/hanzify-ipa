// ============================================================================
// HanzifyStatCard — Unified stat display widget
// Replaces 3 duplicate implementations:
//   - HomeStatCard (home_stat_card.dart)
//   - _StatCard (progress_screen.dart) — vertical icon + value + label
//   - _buildStatCard (profile_screen.dart) — horizontal icon + value + label
// Supports 2 layout variants (vertical/horizontal) + optional gradient
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';

enum HanzifyStatCardLayout { vertical, horizontal }

class HanzifyStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final AppThemeColors colors;
  final Color? iconColor;
  final Gradient? gradient;
  final Color? textColor;
  final HanzifyStatCardLayout layout;

  const HanzifyStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.colors,
    this.iconColor,
    this.gradient,
    this.textColor,
    this.layout = HanzifyStatCardLayout.vertical,
  });

  // ── Convenience factories ─────────────────────────────────────────────

  /// Vertical card: icon on top, value + label below (used in progress_screen)
  const HanzifyStatCard.vertical({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.colors,
    this.iconColor,
    this.gradient,
    this.textColor,
  }) : layout = HanzifyStatCardLayout.vertical;

  /// Horizontal card: icon left, value + label right (used in profile_screen)
  const HanzifyStatCard.horizontal({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.colors,
    this.iconColor,
    this.gradient,
    this.textColor,
  }) : layout = HanzifyStatCardLayout.horizontal;

  @override
  Widget build(BuildContext context) {
    return HanzifyCard(
      gradient: gradient,
      child: layout == HanzifyStatCardLayout.vertical
          ? _buildVertical()
          : _buildHorizontal(),
    );
  }

  Widget _buildVertical() {
    final fg = textColor ?? colors.text;
    return Column(
      children: [
        Icon(icon, color: iconColor ?? colors.primary, size: AppSpacing.iconMd),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.headline(
            fontSize: AppFontSizes.headlineMd,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.label(
            fontSize: AppFontSizes.labelSm,
            fontWeight: FontWeight.w600,
            color: fg.withValues(alpha: 0.7),
          ).copyWith(letterSpacing: 0.8),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    final fg = textColor ?? colors.text;
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: iconColor ?? colors.primary),
        const SizedBox(width: AppSpacing.lg),
        Text(
          value,
          style: AppTypography.headline(
            fontSize: AppFontSizes.headlineLg,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.label(
              fontSize: AppFontSizes.labelMd,
              fontWeight: FontWeight.w600,
              color: fg.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
