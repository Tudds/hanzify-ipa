import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nav_visibility_provider.dart';
import '../providers/performance_provider.dart';
import 'hanzify_haptic.dart';

class BottomTabBarWidget extends ConsumerWidget {
  const BottomTabBarWidget({
    super.key,
    required this.activeIndex,
    required this.onSelect,
  });

  /// Index of the active tab — must match the branch order in [_items].
  final int activeIndex;
  final ValueChanged<int> onSelect;

  static const _items = <_TabItem>[
    _TabItem(Icons.smart_display_rounded, 'Short'),
    _TabItem(Icons.manage_search_rounded, 'Từ điển'),
    _TabItem(Icons.quiz_rounded, 'Quiz'),
    _TabItem(Icons.forum_rounded, 'Chat'),
    _TabItem(Icons.refresh_rounded, 'Ôn tập'),
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
                horizontal: compact ? 8 : 12,
                vertical: compact ? 8 : 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _TabButton(
                      item: _items[i],
                      active: activeIndex == i,
                      compact: compact,
                      onTap: () {
                        if (activeIndex == i) return;
                        HanzifyHaptic.selection();
                        onSelect(i);
                      },
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
  const _TabItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _TabButton extends StatefulWidget {
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
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeColor = colors.primary;
    final inactiveColor = colors.onSurfaceVariant;
    final icon = Icon(
      widget.item.icon,
      color: widget.active ? activeColor : inactiveColor,
      size: widget.compact
          ? (widget.active ? 24 : 22)
          : (widget.active ? 26 : 24),
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
            horizontal: widget.active ? (widget.compact ? 12 : 14) : 10,
            vertical: widget.compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: widget.active
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
          ),
          // AnimatedSize lets the pill grow/shrink as the label appears for the
          // active tab and collapses to an icon-only chip for inactive tabs.
          child: AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (widget.active) ...[
                  SizedBox(width: widget.compact ? 6 : 8),
                  Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: activeColor,
                      fontSize: widget.compact ? 12 : 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
