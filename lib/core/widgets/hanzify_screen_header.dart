import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/core/widgets/hanzify_icon_avatar.dart';
import 'package:hanzify/core/widgets/hanzify_theme_toggle.dart';
import 'package:hanzify/core/theme/typography.dart';

enum HanzifyHeaderVariant {
  primary,
  detail,
}

class HanzifyScreenHeader extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final HanzifyHeaderVariant variant;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showAvatar;
  final bool showThemeToggle;

  const HanzifyScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.variant = HanzifyHeaderVariant.primary,
    this.onBack,
    this.trailing,
    this.showAvatar = true,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isPrimary = variant == HanzifyHeaderVariant.primary;

    final trailingWidget = trailing;

    if (!isPrimary) {
      return SliverAppBar(
        pinned: true,
        title: Text(title, style: AppTypography.headline(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack ?? () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              ref.read(navigationProvider.notifier).goBack();
            }
          },
        ),
        actions: trailingWidget != null ? [trailingWidget] : null,
        backgroundColor: cs.surface,
        scrolledUnderElevation: 2,
      );
    }

    return SliverAppBar.large(
      pinned: true,
      title: Text(title, style: AppTypography.headline(fontWeight: FontWeight.w900, fontSize: 28)),
      backgroundColor: cs.surface,
      scrolledUnderElevation: 2,
      actions: [
        if (showThemeToggle) const HanzifyThemeToggle(),
        if (showAvatar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                HanzifyHaptic.tap();
                ref.read(navigationProvider.notifier).navigate(AppRoutes.profile);
              },
              child: HanzifyIconAvatar.person(
                size: HanzifyAvatarSize.sm,
              ),
            ),
          ),
        trailingWidget ?? const SizedBox.shrink(),
      ],
    );
  }
}
