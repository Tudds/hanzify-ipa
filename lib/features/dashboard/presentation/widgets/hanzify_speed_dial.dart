import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/navigation/app_navigation_destinations.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';

class HanzifyQuickActionsFab extends ConsumerWidget {
  final int dueCount;

  const HanzifyQuickActionsFab({
    super.key,
    required this.dueCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      key: const ValueKey('quick_actions_fab'),
      heroTag: 'quick_actions_fab',
      onPressed: () async {
        HanzifyHaptic.action();
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => _QuickActionSheet(
            onNavigate: (route) {
              Navigator.of(sheetContext).pop();
              ref.read(navigationProvider.notifier).navigate(route);
            },
          ),
        );
      },
      icon: const Icon(Icons.bolt_rounded),
      label: Text(dueCount > 0 ? 'Ôn tập ($dueCount)' : 'Truy cập nhanh'),
    );
  }
}

class HanzifyRailQuickActions extends ConsumerWidget {
  const HanzifyRailQuickActions({
    super.key,
    required this.dueCount,
  });

  final int dueCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      menuChildren: appQuickActionDestinations
          .map(
            (destination) => MenuItemButton(
              leadingIcon: Icon(destination.icon),
              onPressed: () {
                HanzifyHaptic.tap();
                ref
                    .read(navigationProvider.notifier)
                    .navigate(destination.route);
              },
              child: Text(destination.label),
            ),
          )
          .toList(),
      builder: (context, controller, _) {
        return FilledButton.tonalIcon(
          key: const ValueKey('rail_quick_actions_button'),
          onPressed: () {
            HanzifyHaptic.action();
            controller.isOpen ? controller.close() : controller.open();
          },
          icon: const Icon(Icons.apps_rounded),
          label: Text(
            dueCount > 0 ? 'Nhanh ($dueCount)' : 'Truy cập nhanh',
          ),
        );
      },
    );
  }
}

class _QuickActionSheet extends StatelessWidget {
  const _QuickActionSheet({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Truy cập nhanh',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...appQuickActionDestinations.map(
              (destination) => ListTile(
                leading: Icon(destination.icon),
                title: Text(destination.label),
                onTap: () => onNavigate(destination.route),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
