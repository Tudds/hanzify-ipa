import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/nav_visibility_provider.dart';
import 'bottom_tab_bar_widget.dart';

/// Persistent shell for the 5 primary tabs.
///
/// Built once by the [StatefulShellRoute] container, so the bottom bar and its
/// entrance animation no longer replay on every tab switch. The tab content is
/// hosted in a horizontal [PageView] so the user can swipe between tabs with the
/// content following their finger; the bottom bar drives the same branch.
class RootScaffold extends ConsumerStatefulWidget {
  const RootScaffold({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;

  /// One widget per branch (the branch navigators), supplied by the shell.
  final List<Widget> children;

  @override
  ConsumerState<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends ConsumerState<RootScaffold> {
  late final PageController _pageController = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );

  // A branch is only built the first time it becomes visible (kept lazy so a
  // tab's deferred chunk isn't downloaded until you swipe/tap toward it). Once
  // activated it is kept alive so swiping away and back preserves its state.
  late final List<bool> _activated = List<bool>.filled(
    widget.children.length,
    false,
  );

  @override
  void initState() {
    super.initState();
    _activated[widget.navigationShell.currentIndex] = true;
    // While dragging, the neighbour the finger is heading toward becomes
    // visible before the swipe settles — activate it so it isn't blank.
    _pageController.addListener(_activateVisiblePages);
  }

  @override
  void didUpdateWidget(covariant RootScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.navigationShell.currentIndex;
    _activated[index] = true;
    if (!_pageController.hasClients) return;
    final current = _pageController.page?.round();
    if (current == index) return;
    // A bottom-bar tap (or deep link) changed the branch. Slide for an adjacent
    // tab; jump for a distant one — animating across would fire onPageChanged
    // for each page swept and churn goBranch (and build every tab in between).
    if (current != null && (current - index).abs() == 1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_activateVisiblePages);
    _pageController.dispose();
    super.dispose();
  }

  void _activateVisiblePages() {
    final page = _pageController.page;
    if (page == null) return;
    final lower = page.floor();
    final upper = page.ceil();
    var changed = false;
    for (final i in [lower, upper]) {
      if (i >= 0 && i < _activated.length && !_activated[i]) {
        _activated[i] = true;
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  void _onPageChanged(int index) {
    if (index == widget.navigationShell.currentIndex) return;
    widget.navigationShell.goBranch(index);
  }

  void _onSelectTab(int index) {
    widget.navigationShell.goBranch(
      index,
      // Re-tapping the active tab returns it to its initial route.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          // Ignore the horizontal tab PageView — only content scroll (vertical)
          // should hide/show the bottom bar.
          if (notification.metrics.axis != Axis.vertical) return false;
          final notifier = ref.read(navVisibilityProvider.notifier);
          if (notification.direction == ScrollDirection.reverse) {
            notifier.hide();
          } else if (notification.direction == ScrollDirection.forward) {
            notifier.show();
          }
          return false;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                onPageChanged: _onPageChanged,
                itemCount: widget.children.length,
                itemBuilder: (context, index) {
                  if (!_activated[index]) return const SizedBox.shrink();
                  return _KeepAlivePage(child: widget.children[index]);
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: BottomTabBarWidget(
                  activeIndex: widget.navigationShell.currentIndex,
                  onSelect: _onSelectTab,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps a [PageView] page (a branch navigator) alive once visited so swiping
/// away and back preserves its scroll position and navigation stack.
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
