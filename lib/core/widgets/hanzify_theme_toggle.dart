import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HanzifyThemeToggle extends ConsumerWidget {
  const HanzifyThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    final icon = switch (themeMode) {
      AppThemeMode.dark => Icons.light_mode_rounded,
      AppThemeMode.sepia => Icons.auto_awesome_rounded,
      AppThemeMode.light => Icons.dark_mode_rounded,
    };

    return IconButton.filledTonal(
      onPressed: () => ref.read(themeProvider.notifier).cycleTheme(),
      icon: Icon(icon, size: 20),
    );
  }
}
