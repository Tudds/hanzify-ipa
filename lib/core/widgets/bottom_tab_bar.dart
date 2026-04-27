import 'package:hanzify/core/navigation/app_navigation_destinations.dart';
import 'package:flutter/material.dart';

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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final selectedIndex = appPrimaryDestinations.indexWhere(
      (tab) => tab.route == currentScreen,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomInset),
        child: Container(
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
            onDestinationSelected: (index) =>
                onNavigate(appPrimaryDestinations[index].route),
            destinations: appPrimaryDestinations
                .map(
                  (tab) => NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
