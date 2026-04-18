// ============================================================================
// HanzifyProgressBar — 统一的进度条组件
// 替代在多个屏幕中重复定义的进度条:
//   - QuizQuestionView: 渐变背景 + AnimatedFractionallySizedBox
//   - FlashcardStudyView: 同上
//   - QuizResultsView: 静态 FractionallySizedBox
//   - HomeScreen: ClipRRect + LinearProgressIndicator (白色)
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';

class HanzifyProgressBar extends StatelessWidget {
  /// 进度值 0.0 ~ 1.0
  final double progress;

  /// 进度条高度
  final double height;

  /// 是否使用动画过渡
  final bool animated;

  /// 进度条颜色 (不指定则使用 theme primaryGradient)
  final Color? barColor;

  /// 背景颜色 (不指定则使用 theme disabled)
  final Color? backgroundColor;

  /// 圆角半径
  final double? borderRadius;

  /// 外边距
  final EdgeInsets? margin;

  const HanzifyProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.animated = true,
    this.barColor,
    this.backgroundColor,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final bg = backgroundColor ?? c.disabled.withValues(alpha: 0.15);
    final radius = borderRadius ?? height / 2;

    final child = Container(
      decoration: BoxDecoration(
        gradient: barColor != null
            ? LinearGradient(colors: [barColor!, barColor!])
            : LinearGradient(colors: [c.primary, c.accent]),
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: animated
            ? AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                widthFactor: progress.clamp(0.0, 1.0),
                child: child,
              )
            : FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: child,
              ),
      ),
    );
  }
}
