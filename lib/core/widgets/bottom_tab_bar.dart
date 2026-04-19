import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTab {
  final String key;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const AppTab({
    required this.key,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

const _tabs = [
  AppTab(
    key: AppRoutes.home,
    label: 'Học tập',
    icon: CupertinoIcons.house,
    activeIcon: CupertinoIcons.house_fill,
  ),
  AppTab(
    key: AppRoutes.vocabList,
    label: 'Từ điển',
    icon: CupertinoIcons.book,
    activeIcon: CupertinoIcons.book_fill,
  ),
  AppTab(
    key: AppRoutes.progress,
    label: 'Ôn tập',
    icon: CupertinoIcons.bolt_horizontal_circle,
    activeIcon: CupertinoIcons.bolt_horizontal_circle_fill,
  ),
];

class BottomTabBarWidget extends ConsumerWidget {
  final String currentScreen;
  final ValueChanged<String> onNavigate;
  final AppThemeColors colors;

  const BottomTabBarWidget({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceLowest,
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(color: colors.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) => _TabItem(
              tab: tab,
              isActive: currentScreen == tab.key,
              onTap: () => onNavigate(tab.key),
              colors: colors,
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatefulWidget {
  final AppTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final AppThemeColors colors;

  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 160),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final isActive = widget.isActive;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _ctrl.reverse().then((_) => _ctrl.forward());
          widget.onTap();
        },
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) => _ctrl.forward(),
        onTapCancel: () => _ctrl.forward(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: isActive ? c.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? widget.tab.activeIcon : widget.tab.icon,
                    key: ValueKey(isActive),
                    size: 20,
                    color: isActive ? c.onPrimary : c.placeholder,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.tab.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.onPrimary,
                        letterSpacing: 0,
                      ),
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
