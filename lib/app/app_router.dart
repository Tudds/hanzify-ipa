import 'package:go_router/go_router.dart';

import '../core/providers/tab_provider.dart';
import '../core/widgets/root_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: AppTab.shorts.path,
  routes: [
    GoRoute(
      path: AppTab.shorts.path,
      builder: (context, state) => const RootScaffold(tab: AppTab.shorts),
    ),
    GoRoute(
      path: AppTab.dictionary.path,
      builder: (context, state) => const RootScaffold(tab: AppTab.dictionary),
    ),
    GoRoute(
      path: AppTab.quiz.path,
      builder: (context, state) => const RootScaffold(tab: AppTab.quiz),
    ),
    GoRoute(
      path: AppTab.chat.path,
      builder: (context, state) => const RootScaffold(tab: AppTab.chat),
    ),
    GoRoute(
      path: AppTab.review.path,
      builder: (context, state) => const RootScaffold(tab: AppTab.review),
    ),
  ],
);
