import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/widgets/app_navigation_rail.dart';
import 'package:hanzify/core/widgets/bottom_tab_bar.dart';
import 'package:hanzify/features/dashboard/presentation/widgets/hanzify_speed_dial.dart';

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({
    super.key,
    required this.child,
    required this.currentScreen,
    required this.onNavigate,
    required this.useRail,
    required this.showPrimaryNav,
    required this.isNavVisible,
    required this.dueCount,
  });

  final Widget child;
  final String currentScreen;
  final ValueChanged<String> onNavigate;
  final bool useRail;
  final bool showPrimaryNav;
  final bool isNavVisible;
  final int dueCount;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    if (!showPrimaryNav) return child;

    if (useRail) {
      return Row(
        children: [
          AppNavigationRail(
            currentScreen: currentScreen,
            onNavigate: onNavigate,
            header: HanzifyRailQuickActions(dueCount: dueCount),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      );
    }

    return Stack(
      children: [
        child,
        Positioned(
          right: 16,
          bottom: (isNavVisible ? 96 : 16) + bottomInset,
          child: AnimatedContainer(
            duration: AppDurations.normal,
            curve: Curves.easeInOutCubic,
            child: HanzifyQuickActionsFab(dueCount: dueCount),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: isNavVisible ? Offset.zero : const Offset(0, 1.2),
            duration: AppDurations.normal,
            curve: Curves.easeInOutCubic,
            child: BottomTabBarWidget(
              currentScreen: currentScreen,
              onNavigate: onNavigate,
            ),
          ),
        ),
      ],
    );
  }
}
