import 'package:flutter/material.dart';
import 'package:hanzify/core/navigation/app_navigation_destinations.dart';

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    this.header,
  });

  final String currentScreen;
  final ValueChanged<String> onNavigate;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedIndex = appPrimaryDestinations.indexWhere(
      (destination) => destination.route == currentScreen,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: Column(
          children: [
            if (header != null) ...[
              header!,
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                color: cs.surfaceContainerLow,
                child: NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: selectedIndex != -1 ? selectedIndex : 0,
                  onDestinationSelected: (index) =>
                      onNavigate(appPrimaryDestinations[index].route),
                  labelType: NavigationRailLabelType.all,
                  destinations: appPrimaryDestinations
                      .map(
                        (destination) => NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
