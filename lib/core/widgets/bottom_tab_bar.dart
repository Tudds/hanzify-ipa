import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/navigation/app_routes.dart';

import 'package:flutter/cupertino.dart';

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

class BottomTabBarWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceLowest.withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: colors.disabled.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) => _buildTabItem(tab)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(AppTab tab) {
    final isActive = currentScreen == tab.key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onNavigate(tab.key),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? tab.activeIcon : tab.icon,
              size: 24,
              color: isActive ? colors.primary : colors.placeholder,
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? colors.primary : colors.placeholder,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


