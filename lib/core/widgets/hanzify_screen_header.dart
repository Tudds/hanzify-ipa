import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/widgets/hanzify_icon_avatar.dart';
import 'package:hanzify/core/widgets/hanzify_theme_toggle.dart';

/// Variant header đồng bộ cho mọi màn chính.
enum HanzifyHeaderVariant {
  /// Tab chính: title lớn + theme toggle + avatar.
  primary,

  /// Màn con: back button + title.
  detail,
}

/// Header SliverAppBar đồng bộ — dùng thay các header inline rời rạc.
///
/// Nhất quán:
/// - Title size: displaySm, w900, letterSpacing -1
/// - Subtitle size: bodyMd, placeholder
/// - Avatar size: md
/// - expandedHeight: 120 (primary), 80 (detail)
class HanzifyScreenHeader extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final HanzifyHeaderVariant variant;
  final VoidCallback? onBack;
  final Widget? trailing;

  /// Nếu true, tap avatar navigate tới ProfileScreen.
  final bool showAvatar;

  /// Nếu true, hiển thị theme toggle.
  final bool showThemeToggle;

  const HanzifyScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.variant = HanzifyHeaderVariant.primary,
    this.onBack,
    this.trailing,
    this.showAvatar = true,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = themeColorsOf(context);
    final isPrimary = variant == HanzifyHeaderVariant.primary;
    final double expanded = subtitle != null ? 140 : (isPrimary ? 120 : 88);

    return SliverAppBar(
      expandedHeight: expanded,
      pinned: true,
      floating: false,
      backgroundColor: c.background.withValues(alpha: 0.98),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      title: null,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double top = constraints.biggest.height;
          final double collapsedHeight =
              MediaQuery.of(context).padding.top + kToolbarHeight;
          final double delta = expanded - collapsedHeight;
          final double t = delta > 0
              ? ((top - collapsedHeight) / delta).clamp(0.0, 1.0)
              : 1.0;

          return FlexibleSpaceBar(
            background: Stack(
              children: [
                // ── Common Actions (Top Right) ──────────────────────────────
                // This stays fixed regardless of scroll percentage
                SafeArea(
                  child: Container(
                    height: kToolbarHeight,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActions(context, ref, c),
                      ],
                    ),
                  ),
                ),

                // ── Collapsed Title (Small) ──────────────────────────────────
                Opacity(
                  opacity: (1.0 - t).clamp(0.0, 1.0),
                  child: SafeArea(
                    child: Container(
                      height: kToolbarHeight,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      alignment: Alignment.centerLeft,
                      // We use a row here to ensure it doesn't overlap with actions
                      child: Row(
                        children: [
                          Expanded(
                            child: _CollapsedTitle(
                              title: title,
                              variant: variant,
                              onBack: onBack,
                            ),
                          ),
                          // Placeholder for the fixed actions
                          Opacity(
                            opacity: 0,
                            child: _buildActions(context, ref, c),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Expanded Title (Large) ───────────────────────────────────
                Opacity(
                  opacity: (t * t).clamp(0.0, 1.0),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg, // Tăng thêm khoảng cách từ status bar
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!isPrimary && onBack != null)
                                _BackPill(onTap: onBack!, colors: c),
                              if (!isPrimary && onBack != null)
                                const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppTypography.headline(
                                    fontSize: AppFontSizes.displaySm,
                                    fontWeight: FontWeight.w900,
                                    color: c.text,
                                    letterSpacing: -1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Placeholder for fixed actions
                              Opacity(
                                opacity: 0,
                                child: _buildActions(context, ref, c),
                              ),
                            ],
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              subtitle!,
                              style: AppTypography.body(
                                fontSize: AppFontSizes.bodyMd,
                                color: c.placeholder,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, AppThemeColors c) {
    final isPrimary = variant == HanzifyHeaderVariant.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        trailing ?? const SizedBox.shrink(),
        if (trailing == null && showThemeToggle && isPrimary)
          const HanzifyThemeToggle(marginRight: AppSpacing.md),
        if (trailing == null && showAvatar && isPrimary)
          GestureDetector(
            onTap: () {
              HanzifyHaptic.tap();
              ref
                  .read(navigationProvider.notifier)
                  .navigate(AppRoutes.profile);
            },
            child: HanzifyIconAvatar.person(
              size: HanzifyAvatarSize.md,
              colors: c,
            ),
          ),
      ],
    );
  }
}

class _CollapsedTitle extends StatelessWidget {
  final String title;
  final HanzifyHeaderVariant variant;
  final VoidCallback? onBack;

  const _CollapsedTitle({
    required this.title,
    required this.variant,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    return Row(
      children: [
        if (variant == HanzifyHeaderVariant.detail && onBack != null)
          GestureDetector(
            onTap: () {
              HanzifyHaptic.tap();
              onBack!();
            },
            child: Icon(Icons.arrow_back_rounded, color: c.text, size: 22),
          ),
        if (variant == HanzifyHeaderVariant.detail && onBack != null)
          const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            title,
            style: AppTypography.headline(
              fontSize: AppFontSizes.headlineSm,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  final AppThemeColors colors;

  const _BackPill({required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HanzifyHaptic.tap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: colors.primary,
          size: 22,
        ),
      ),
    );
  }
}
