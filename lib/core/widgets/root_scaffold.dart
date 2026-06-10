import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nav_visibility_provider.dart';
import '../providers/tab_provider.dart';
// Shorts is the initial tab — keep it in the main bundle for instant first paint.
import '../../features/shorts/presentation/shorts_feed_screen.dart';
// The other four tabs are deferred: each becomes its own code chunk that is only
// downloaded the first time the user opens that tab (see DeferredWidget).
import '../../features/dictionary/presentation/dictionary_screen.dart'
    deferred as dictionary;
import '../../features/quiz/presentation/quiz_screen.dart' deferred as quiz;
import '../../features/chat/presentation/chat_screen.dart' deferred as chat;
import '../../features/review_session/presentation/due_review_screen.dart'
    deferred as review;
import 'bottom_tab_bar_widget.dart';
import 'deferred_widget.dart';

class RootScaffold extends ConsumerWidget {
  const RootScaffold({super.key, required this.tab});

  final AppTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = AppTab.values.indexOf(tab);

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
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
              child: _LazyIndexedStack(
                index: tabIndex,
                itemBuilders: const [
                  _buildShorts,
                  _buildDictionary,
                  _buildQuiz,
                  _buildChat,
                  _buildReview,
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(child: BottomTabBarWidget(activeTab: tab)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildShorts(BuildContext _) => const ShortsFeedScreen();
Widget _buildDictionary(BuildContext _) =>
    DeferredWidget(dictionary.loadLibrary, () => dictionary.DictionaryScreen());
Widget _buildQuiz(BuildContext _) =>
    DeferredWidget(quiz.loadLibrary, () => quiz.QuizScreen());
Widget _buildChat(BuildContext _) =>
    DeferredWidget(chat.loadLibrary, () => chat.ChatScreen());
Widget _buildReview(BuildContext _) =>
    DeferredWidget(review.loadLibrary, () => review.DueReviewScreen());

/// An [IndexedStack] that only instantiates a tab the first time it becomes
/// active, then keeps it alive (state preserved) like a normal IndexedStack.
///
/// This keeps cold-start work to just the initial tab instead of eagerly
/// building all five screens on the first frame, while preserving the
/// "switch tabs without losing scroll/state" behaviour.
class _LazyIndexedStack extends StatefulWidget {
  const _LazyIndexedStack({required this.index, required this.itemBuilders});

  final int index;
  final List<WidgetBuilder> itemBuilders;

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late final List<bool> _activated =
      List<bool>.filled(widget.itemBuilders.length, false);

  @override
  void initState() {
    super.initState();
    _activated[widget.index] = true;
  }

  @override
  void didUpdateWidget(covariant _LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activated[widget.index] = true;
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.itemBuilders.length; i++)
          if (_activated[i])
            widget.itemBuilders[i](context)
          else
            const SizedBox.shrink(),
      ],
    );
  }
}
