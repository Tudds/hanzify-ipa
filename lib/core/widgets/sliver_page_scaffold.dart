import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../motion/motion_tokens.dart';
import '../providers/performance_provider.dart';

class SliverPageScaffold extends ConsumerWidget {
  const SliverPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.slivers,
    this.headerAssetPath,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final String? headerAssetPath;
  final Widget? leading;
  final List<Widget> actions;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performance = readPerformance(ref);
    final colors = Theme.of(context).colorScheme;
    Widget buildHeader(bool expanded) {
      final header = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (expanded) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ],
      );
      return performance
          ? header
          : header
                .animate()
                .fadeIn(duration: MotionTokens.fast)
                .slideY(begin: 0.08, end: 0, duration: MotionTokens.medium);
    }

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: colors.surface.withValues(alpha: 0.96),
            leading: leading,
            actions: actions,
            expandedHeight: 112,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final expanded = constraints.maxHeight > 96;
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  background: headerAssetPath == null
                      ? null
                      : _HeaderIllustration(assetPath: headerAssetPath!),
                  title: buildHeader(expanded),
                );
              },
            ),
          ),
          ...slivers,
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _HeaderIllustration extends StatelessWidget {
  const _HeaderIllustration({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Opacity(
            opacity: 0.46,
            child: _DecorativeAsset(
              assetPath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.surface,
                colors.surface.withValues(alpha: 0.88),
                colors.surface.withValues(alpha: 0.56),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SliverSectionHeader extends StatelessWidget {
  const SliverSectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SliverStateMessage extends StatelessWidget {
  const SliverStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.illustrationAssetPath,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? illustrationAssetPath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (illustrationAssetPath == null)
                Icon(icon, size: 54, color: colors.primary)
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _DecorativeAsset(
                    illustrationAssetPath!,
                    height: 132,
                    width: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.thumbnailAssetPath,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? thumbnailAssetPath;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: thumbnailAssetPath == null
                  ? Icon(icon, color: colors.primary)
                  : _DecorativeAsset(
                      thumbnailAssetPath!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _DecorativeAsset extends StatelessWidget {
  const _DecorativeAsset(
    this.assetPath, {
    required this.fit,
    this.width,
    this.height,
  });

  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        excludeFromSemantics: true,
      );
    }
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
  }
}
