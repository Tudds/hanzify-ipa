import 'package:flutter/material.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';

class HanzifyTabbedFrame extends StatelessWidget {
  final String? title;
  final Widget? appBarTrailing;
  final VoidCallback? onBack;
  final Widget hero;
  final List<String> tabLabels;
  final List<List<Widget>> tabSlivers;
  final int initialIndex;

  const HanzifyTabbedFrame({
    super.key,
    this.title,
    this.appBarTrailing,
    this.onBack,
    required this.hero,
    required this.tabLabels,
    required this.tabSlivers,
    this.initialIndex = 0,
  }) : assert(tabLabels.length == tabSlivers.length,
            'tabLabels and tabSlivers must have the same length');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DefaultTabController(
      length: tabLabels.length,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              HanzifyScreenHeader(
                title: title ?? '',
                variant: HanzifyHeaderVariant.detail,
                onBack: onBack,
                trailing: appBarTrailing,
              ),
              SliverToBoxAdapter(
                child: hero,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    isScrollable: tabLabels.length > 3,
                    tabAlignment: tabLabels.length > 3 ? TabAlignment.start : TabAlignment.fill,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: theme.textTheme.titleSmall,
                    tabs: tabLabels.map((label) => Tab(text: label)).toList(),
                  ),
                  cs.surface,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: tabSlivers.map((slivers) {
              return CustomScrollView(
                slivers: [
                  const SliverPadding(padding: EdgeInsets.only(top: 16)),
                  ...slivers,
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;

  _SliverAppBarDelegate(this._tabBar, this._backgroundColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
