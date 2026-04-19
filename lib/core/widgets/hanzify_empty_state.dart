// ============================================================================
// HanzifyEmptyState — Unified empty state / no data placeholder widget
// Replaces duplicated empty state patterns across 6+ screens:
//   - GrammarScreen: search "Không tìm thấy kết quả"
//   - VocabListScreen: search "Không tìm thấy từ vựng nào"
//   - CharacterDetailScreen: "Chưa có dữ liệu cho chữ này" + error view
//   - FlashcardScreen: "Không có từ nào cần ôn!" + action button
//   - VocabListScreen: loading/error states
//   - General use: any screen needing an empty placeholder
// ============================================================================
import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/providers/performance_provider.dart';

/// Empty state style variants
enum HanzifyEmptyStateVariant {
  /// Default: icon + title + subtitle
  /// Used for search results, no data found
  standard,

  /// Character display: large hanzi character + subtitle
  /// Used in CharacterDetail "Chưa có dữ liệu cho chữ này"
  character,

  /// Success celebration: emoji + title + subtitle + action button
  /// Used in FlashcardScreen "Không có từ nào cần ôn!"
  celebration,

  /// Error state: warning icon + error message
  /// Used in CharacterDetail "Lỗi tải dữ liệu"
  error,
}

class HanzifyEmptyState extends ConsumerWidget {
  /// Style variant
  final HanzifyEmptyStateVariant variant;

  /// Icon (for standard/error variants)
  final IconData? icon;

  /// Emoji or text character (for celebration/character variants)
  final String? emoji;

  /// Title text
  final String? title;

  /// Subtitle / description text
  final String? subtitle;

  /// Optional action button widget (for celebration variant)
  final Widget? actionButton;

  /// Icon/emoji size
  final double? iconSize;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  /// Text color override
  final Color? titleColor;

  /// Subtitle color override
  final Color? subtitleColor;

  const HanzifyEmptyState({
    super.key,
    this.variant = HanzifyEmptyStateVariant.standard,
    this.icon,
    this.emoji,
    this.title,
    this.subtitle,
    this.actionButton,
    this.iconSize,
    this.padding,
    this.titleColor,
    this.subtitleColor,
  });

  /// Convenience constructor for search "no results" state
  const HanzifyEmptyState.searchNoResults({
    super.key,
    String titleText = 'Không tìm thấy kết quả',
    String subtitleText = 'Thử tìm với từ khóa khác nhé!',
  })  : variant = HanzifyEmptyStateVariant.standard,
        icon = Icons.search_off_rounded,
        emoji = null,
        title = titleText,
        subtitle = subtitleText,
        actionButton = null,
        iconSize = null,
        padding = null,
        titleColor = null,
        subtitleColor = null;

  /// Convenience constructor for "no vocabulary found" state
  const HanzifyEmptyState.noVocab({
    super.key,
    String titleText = 'Không tìm thấy từ vựng nào',
  })  : variant = HanzifyEmptyStateVariant.standard,
        icon = Icons.menu_book_rounded,
        emoji = null,
        title = titleText,
        subtitle = null,
        actionButton = null,
        iconSize = null,
        padding = null,
        titleColor = null,
        subtitleColor = null;

  /// Convenience constructor for character "no data" state
  const HanzifyEmptyState.noCharacterData({
    super.key,
    required String character,
    String subtitleText = 'Chưa có dữ liệu cho chữ này',
  })  : variant = HanzifyEmptyStateVariant.character,
        icon = null,
        emoji = character,
        title = null,
        subtitle = subtitleText,
        actionButton = null,
        iconSize = null,
        padding = null,
        titleColor = null,
        subtitleColor = null;

  /// Convenience constructor for celebration state (e.g., all cards reviewed)
  const HanzifyEmptyState.celebration({
    super.key,
    required String emojiText,
    required String titleText,
    String? subtitleText,
    Widget? action,
  })  : variant = HanzifyEmptyStateVariant.celebration,
        icon = null,
        emoji = emojiText,
        title = titleText,
        subtitle = subtitleText,
        actionButton = action,
        iconSize = null,
        padding = null,
        titleColor = null,
        subtitleColor = null;

  /// Convenience constructor for error state
  const HanzifyEmptyState.errorState({
    super.key,
    String errorText = 'Lỗi tải dữ liệu',
  })  : variant = HanzifyEmptyStateVariant.error,
        icon = null,
        emoji = '⚠️',
        title = errorText,
        subtitle = null,
        actionButton = null,
        iconSize = null,
        padding = null,
        titleColor = null,
        subtitleColor = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final reducedMotion = ref.watch(performanceProvider) ||
        MediaQuery.disableAnimationsOf(context);

    final leading = _buildLeading(c);
    final shouldFloat = !reducedMotion &&
        (variant == HanzifyEmptyStateVariant.standard ||
            variant == HanzifyEmptyStateVariant.celebration);

    return Center(
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl,
              vertical: AppSpacing.xxl,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            shouldFloat ? _FloatingIcon(child: leading) : leading,
            const SizedBox(height: AppSpacing.lg),
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: variant == HanzifyEmptyStateVariant.celebration
                      ? 22
                      : AppFontSizes.titleLg,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? c.text,
                ),
                textAlign: TextAlign.center,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AppFontSizes.bodyMd,
                  color: subtitleColor ?? c.placeholder,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(AppThemeColors c) {
    final size = iconSize ?? 56;

    switch (variant) {
      case HanzifyEmptyStateVariant.standard:
        return Icon(
          icon ?? Icons.inbox_rounded,
          size: size,
          color: c.disabled,
        );

      case HanzifyEmptyStateVariant.character:
        return Hero(
          tag: 'char_$emoji',
          child: Material(
            color: Colors.transparent,
            child: Text(
              emoji ?? '',
              style: AppTypography.hanziDisplay(
                fontSize: 80,
                color: c.text,
              ),
            ),
          ),
        );

      case HanzifyEmptyStateVariant.celebration:
        return Text(
          emoji ?? '🎉',
          style: const TextStyle(fontSize: 48),
        );

      case HanzifyEmptyStateVariant.error:
        return Text(
          emoji ?? '⚠️',
          style: const TextStyle(fontSize: 48),
        );
    }
  }
}

/// Gentle Y-axis float animation (±4px sine, 2s loop) for empty state icons.
class _FloatingIcon extends StatefulWidget {
  final Widget child;
  const _FloatingIcon({required this.child});

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (_, child) {
        final dy = sin(_controller.value * 2 * pi) * 4.0;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
    );
  }
}
