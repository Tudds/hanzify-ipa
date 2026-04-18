// ============================================================================
// AppThemeHelper —统一的主题颜色访问方式
// 解决问题: 不同屏幕使用不同的方式访问theme colors
//   - 有些用 Theme.of(context).`extension<AppThemeExtension>`()?.colors
//   - 有些用 ref.watch(themeColorsProvider)
//   - 有些手动 fallback AppThemeColors.light
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/theme_state.dart';

/// 在 BuildContext 中获取当前主题颜色
/// 替代: `Theme.of(context).extension<AppThemeExtension>()?.colors ?? AppThemeColors.light`
AppThemeColors themeColorsOf(BuildContext context) {
  return Theme.of(context).extension<AppThemeExtension>()?.colors ??
      AppThemeColors.light;
}

/// 在 ConsumerWidget/ConsumerStatefulWidget 中获取当前主题颜色 (via ref)
/// 替代: ref.watch(themeColorsProvider)
AppThemeColors themeColorsOfRef(WidgetRef ref) {
  return ref.watch(themeColorsProvider);
}
