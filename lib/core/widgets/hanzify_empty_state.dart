import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/providers/performance_provider.dart';

enum HanzifyEmptyStateVariant {
  standard,
  character,
  celebration,
  error,
}

class HanzifyEmptyState extends ConsumerWidget {
  final HanzifyEmptyStateVariant variant;
  final IconData? icon;
  final String? emoji;
  final String? title;
  final String? subtitle;
  final Widget? actionButton;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final Color? titleColor;
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final reducedMotion = ref.watch(performanceProvider) ||
        MediaQuery.disableAnimationsOf(context);

    final leading = _buildLeading(theme, cs);
    final shouldFloat = !reducedMotion &&
        (variant == HanzifyEmptyStateVariant.standard ||
            variant == HanzifyEmptyStateVariant.celebration);

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            shouldFloat ? _FloatingIcon(child: leading) : leading,
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: subtitleColor ?? cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 32),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(ThemeData theme, ColorScheme cs) {
    final size = iconSize ?? 64;

    switch (variant) {
      case HanzifyEmptyStateVariant.standard:
        return Icon(
          icon ?? Icons.inbox_rounded,
          size: size,
          color: cs.outlineVariant,
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
                color: cs.onSurface,
              ),
            ),
          ),
        );

      case HanzifyEmptyStateVariant.celebration:
        return Text(
          emoji ?? '🎉',
          style: const TextStyle(fontSize: 64),
        );

      case HanzifyEmptyStateVariant.error:
        return Text(
          emoji ?? '⚠️',
          style: const TextStyle(fontSize: 64),
        );
    }
  }
}

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
