import 'package:flutter/material.dart';
import 'hanzify_back_button.dart';

export 'hanzify_back_button.dart' show HanzifyBackButtonStyle;

enum HanzifyAppBarVariant {
  standard,
  centered,
  backOnly,
  titleOnly,
}

class HanzifyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HanzifyAppBarVariant variant;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? trailing;
  final Color? backgroundColor;
  final VoidCallback? onBackTap;
  final Widget? bottom;
  final double? progress;
  
  // Legacy compatibility parameters
  final HanzifyBackButtonStyle? backStyle;
  final String? backLabel;

  const HanzifyAppBar({
    super.key,
    this.variant = HanzifyAppBarVariant.standard,
    this.title,
    this.titleStyle,
    this.trailing,
    this.backgroundColor,
    this.onBackTap,
    this.bottom,
    this.progress,
    this.backStyle,
    this.backLabel,
  });

  @override
  Size get preferredSize {
    final bottomHeight = bottom != null ? 56.0 : 0.0;
    final progressHeight = progress != null ? 4.0 : 0.0;
    return Size.fromHeight(56.0 + bottomHeight + progressHeight);
  }

  @override
  Widget build(BuildContext context) {

    final bottomWidget = bottom;
    final progressValue = progress;

    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: variant == HanzifyAppBarVariant.centered || variant == HanzifyAppBarVariant.titleOnly,
      title: title != null ? Text(title!, style: titleStyle ?? const TextStyle(fontWeight: FontWeight.bold)) : null,
      leading: (variant != HanzifyAppBarVariant.titleOnly)
          ? HanzifyBackButton(
              style: backStyle ?? HanzifyBackButtonStyle.iconOnly,
              label: backLabel ?? 'Quay lại',
              onTap: onBackTap,
            )
          : null,
      actions: trailing != null ? [trailing!] : null,
      bottom: (bottomWidget != null || progressValue != null)
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomWidget != null ? 56 : 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bottomWidget ?? const SizedBox.shrink(),
                  if (progressValue != null)
                    LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 4,
                    ),
                ],
              ),
            )
          : null,
    );
  }
}
