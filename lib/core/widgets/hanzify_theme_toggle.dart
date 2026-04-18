// ============================================================================
// HanzifyThemeToggle — 统一的主题切换按钮
// 替代在 HomeScreen 和 VocabListScreen 中重复定义的 theme toggle
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HanzifyThemeToggle extends ConsumerWidget {
  /// 按钮大小 (padding)
  final double size;

  /// 外边距 (右侧)
  final double marginRight;

  const HanzifyThemeToggle({
    super.key,
    this.size = 8,
    this.marginRight = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;

    final icon = switch (themeMode) {
      AppThemeMode.dark => Icons.light_mode_rounded,
      AppThemeMode.sepia => Icons.auto_awesome_rounded,
      AppThemeMode.light => Icons.dark_mode_rounded,
    };

    final bgColor = switch (themeMode) {
      AppThemeMode.dark => c.surfaceLow,
      _ => c.primary.withValues(alpha: 0.1),
    };

    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).cycleTheme(),
      child: Container(
        padding: EdgeInsets.all(size),
        margin: EdgeInsets.only(right: marginRight),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: c.primary,
          size: 20,
        ),
      ),
    );
  }
}
