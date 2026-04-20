import 'package:flutter/material.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';

class HanzifyDetailFrame extends StatelessWidget {
  final String? title;
  final Widget? appBarTrailing;
  final VoidCallback? onBack;
  final String? watermarkHanzi;
  final Widget hero;
  final List<Widget> slivers;
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          HanzifyScreenHeader(
            title: title ?? '',
            variant: HanzifyHeaderVariant.detail,
            onBack: onBack,
            trailing: appBarTrailing,
          ),
          SliverToBoxAdapter(
            child: hero,
          ),
          ...slivers,
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
