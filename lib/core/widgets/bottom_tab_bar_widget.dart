import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/nav_visibility_provider.dart';
import '../providers/performance_provider.dart';
import '../providers/tab_provider.dart';
import 'hanzify_haptic.dart';

class BottomTabBarWidget extends ConsumerWidget {
  const BottomTabBarWidget({super.key, required this.activeTab});

  final AppTab activeTab;

  static const _items = <_TabItem>[
    _TabItem(AppTab.shorts, Icons.smart_display_rounded, 'Short'),
    _TabItem(AppTab.dictionary, Icons.manage_search_rounded, 'Từ điển'),
    _TabItem(AppTab.quiz, Icons.quiz_rounded, 'Quiz'),
    _TabItem(AppTab.chat, Icons.forum_rounded, 'Chat'),
    _TabItem(AppTab.review, Icons.refresh_rounded, 'Ôn tập'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(navVisibilityProvider);
    final performance = readPerformance(ref);
    final colors = Theme.of(context).colorScheme;

    final bar = LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : fallbackWidth;
        final compact = width < 420;
        final horizontalInset = (width * 0.05).clamp(10.0, 20.0).toDouble();
        final radius = compact ? 22.0 : 28.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalInset,
            0,
            horizontalInset,
            compact ? 10 : 16,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 6 : 12,
                vertical: compact ? 8 : 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final item in _items)
                    Expanded(
                      child: _TabButton(
                        item: item,
                        active: activeTab == item.tab,
                        compact: compact,
                        onTap: () {
                          if (activeTab == item.tab) return;
                          HanzifyHaptic.selection();
                          context.go(item.tab.path);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (performance) {
      return AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 1.4),
        duration: const Duration(milliseconds: 200),
        child: bar,
      );
    }

    return bar
        .animate(target: visible ? 1 : 0)
        .slideY(
          begin: 1.4,
          end: 0,
          duration: 280.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 200.ms);
  }
}

class _TabItem {
  const _TabItem(this.tab, this.icon, this.label);

  final AppTab tab;
  final IconData icon;
  final String label;
}

class _TabButton extends ConsumerStatefulWidget {
  const _TabButton({
    required this.item,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  final _TabItem item;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  ConsumerState<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends ConsumerState<_TabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeColor = colors.primary;
    final inactiveColor = colors.onSurfaceVariant;
    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: Icon(
        widget.item.icon,
        key: ValueKey(widget.active),
        color: widget.active ? activeColor : inactiveColor,
        size: widget.compact
            ? (widget.active ? 24 : 22)
            : (widget.active ? 26 : 24),
      ),
    );
    final label = AnimatedOpacity(
      opacity: widget.active ? 1 : 0.72,
      duration: const Duration(milliseconds: 180),
      child: Text(
        widget.item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: widget.active ? activeColor : inactiveColor,
          fontSize: widget.compact ? 10 : 11,
          fontWeight: widget.active ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 6 : (widget.active ? 10 : 8),
            vertical: widget.compact ? 7 : 10,
          ),
          decoration: BoxDecoration(
            color: widget.active
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
          ),
          child: widget.compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(height: 2),
                    FittedBox(fit: BoxFit.scaleDown, child: label),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: 6),
                    Flexible(child: label),
                  ],
                ),
        ),
      ),
    );
  }
}
