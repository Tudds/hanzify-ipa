// ============================================================================
// HanzifyBackButton — 统一的后退按钮组件
// 替代在多个屏幕中重复定义的后退按钮:
//   - VocabDetailScreen: 圆角方形 + box shadow back button
//   - GrammarDetailScreen: 同上
//   - FlashcardScreen: 药丸形 "← Về" / "← Thoát" 文字按钮
//   - QuizModeSelection: 同上 "← Về"
//   - QuizQuestionView: "← Thoát" 药丸按钮
//   - GrammarScreen: 箭头+文字 "Grammar Library"
//   - CharacterDetailScreen: IconButton 形式
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/theme_state.dart';

/// 后退按钮样式
enum HanzifyBackButtonStyle {
  /// 圆角方形带阴影 — 用于详情页面 (VocabDetail, GrammarDetail)
  rounded,

  /// 药丸形文字按钮 — 用于功能页面 (Flashcard, Quiz)
  pill,

  /// 简约 IconButton — 用于 CharacterDetail
  iconOnly,
}

class HanzifyBackButton extends StatelessWidget {
  /// 按钮样式
  final HanzifyBackButtonStyle style;

  /// 按钮文字 (pill 样式时使用)
  /// 默认为 "← Quay lại"
  final String label;

  /// 文字颜色 (如果不指定则使用 theme)
  final Color? color;

  /// 背景色 (rounded 样式时使用)
  final Color? backgroundColor;

  /// 阴影 (rounded 样式时使用)
  final List<BoxShadow>? boxShadow;

  /// 点击回调
  final VoidCallback? onTap;

  const HanzifyBackButton({
    super.key,
    this.style = HanzifyBackButtonStyle.rounded,
    this.label = '← Quay lại',
    this.color,
    this.backgroundColor,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case HanzifyBackButtonStyle.rounded:
        return _buildRounded(context);
      case HanzifyBackButtonStyle.pill:
        return _buildPill(context);
      case HanzifyBackButtonStyle.iconOnly:
        return _buildIconOnly(context);
    }
  }

  Widget _buildRounded(BuildContext context) {
    final c = color ?? Theme.of(context).extension<AppThemeExtension>()?.colors.text
        ?? const Color(0xFF0e1d25);
    final bg = backgroundColor ??
        Theme.of(context).extension<AppThemeExtension>()?.colors.surfaceLowest
        ?? Colors.white;

    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: boxShadow,
        ),
        child: Icon(Icons.arrow_back_rounded, color: c, size: 22),
      ),
    );
  }

  Widget _buildPill(BuildContext context) {
    final c = color ??
        Theme.of(context).extension<AppThemeExtension>()?.colors.primary
        ?? const Color(0xFF005236);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ),
    );
  }

  Widget _buildIconOnly(BuildContext context) {
    final c = color ??
        Theme.of(context).extension<AppThemeExtension>()?.colors.text
        ?? const Color(0xFF0e1d25);

    return IconButton(
      onPressed: onTap ?? () => Navigator.of(context).pop(),
      icon: Icon(Icons.arrow_back_rounded, color: c),
      tooltip: 'Quay lại',
    );
  }
}
