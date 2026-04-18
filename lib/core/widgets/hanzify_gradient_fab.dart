// ============================================================================
// HanzifyGradientFab — 统一的渐变浮动操作按钮
// 替代在 HomeScreen 中重复定义的 gradient FAB
// 可复用于任何需要 FAB 的页面
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HanzifyGradientFab extends StatelessWidget {
  /// FAB 图标
  final IconData icon;

  /// 图标颜色 (默认白色)
  final Color? iconColor;

  /// FAB 大小 (默认 60)
  final double size;

  /// 点击回调
  final VoidCallback? onTap;

  /// 自定义渐变 (不指定则使用 theme primaryGradient)
  final Gradient? gradient;

  /// 自定义阴影
  final List<BoxShadow>? boxShadow;

  const HanzifyGradientFab({
    super.key,
    required this.icon,
    this.iconColor,
    this.size = 60,
    this.onTap,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient ?? c.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
