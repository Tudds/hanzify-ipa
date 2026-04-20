import 'package:hanzify/core/navigation/app_routes.dart';
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
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  AppTab(
    key: AppRoutes.vocabList,
    label: 'Từ điển',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
  ),
  AppTab(
    key: AppRoutes.progress,
    label: 'Ôn tập',
    icon: Icons.bolt_outlined,
    activeIcon: Icons.bolt_rounded,
  ),
  AppTab(
    key: AppRoutes.profile,
    label: 'Cá nhân',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];

class BottomTabBarWidget extends StatelessWidget {
  final String currentScreen;
  final ValueChanged<String> onNavigate;

  const BottomTabBarWidget({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    @Deprecated('Use theme instead') dynamic colors,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final int selectedIndex = _tabs.indexWhere((tab) => tab.key == currentScreen);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorShape: const StadiumBorder(),
        selectedIndex: selectedIndex != -1 ? selectedIndex : 0,
        onDestinationSelected: (index) => onNavigate(_tabs[index].key),
        destinations: _tabs.map((tab) => NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: Icon(tab.activeIcon),
          label: tab.label,
        )).toList(),
      ),
    );
  }
}
