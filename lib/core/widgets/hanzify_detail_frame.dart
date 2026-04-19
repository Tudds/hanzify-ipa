import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';

/// Unified detail screen frame for Vocab, Grammar, Conversation, Character.
///
/// Handles: background color, optional watermark hanzi, safe-area padding,
/// [HanzifyAppBar], hero section, and scrollable content slivers.
class HanzifyDetailFrame extends StatelessWidget {
  /// AppBar title (optional).
  final String? title;

  /// Trailing widget in AppBar (bookmark button, etc.).
  final Widget? appBarTrailing;

  /// Back button tap override. Defaults to Navigator.pop.
  final VoidCallback? onBack;

  /// Optional hanzi string shown as faded watermark at bottom-right.
  final String? watermarkHanzi;

  /// Hero content placed directly below the AppBar.
  final Widget hero;

  /// Content sections. Each item should be a [SliverToBoxAdapter] or
  /// any other Sliver widget.
  final List<Widget> slivers;

  /// Optional scroll controller (e.g. ConversationDetail needs one).
  final ScrollController? scrollController;

  const HanzifyDetailFrame({
    super.key,
    this.title,
    this.appBarTrailing,
    this.onBack,
    this.watermarkHanzi,
    required this.hero,
    required this.slivers,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          if (watermarkHanzi != null) _buildWatermark(c),
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + AppSpacing.sm,
                ),
              ),
              SliverToBoxAdapter(
                child: HanzifyAppBar(
                  backStyle: HanzifyBackButtonStyle.rounded,
                  backBoxShadow: c.cardShadow,
                  title: title,
                  trailing: appBarTrailing,
                  safeAreaTop: false,
                  onBackTap: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
              SliverToBoxAdapter(child: hero),
              ...slivers,
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + AppSpacing.xxxl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatermark(AppThemeColors c) {
    return Positioned(
      bottom: -40,
      right: -20,
      child: Text(
        watermarkHanzi!,
        style: AppTypography.hanziDisplay(
          fontSize: 240,
          color: c.text.withValues(alpha: 0.04),
        ),
      ),
    );
  }
}
