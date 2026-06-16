import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/tab_provider.dart';
import '../core/providers/user_profile_provider.dart';
import '../core/widgets/deferred_widget.dart';
import '../core/widgets/root_scaffold.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
// Shorts is the initial tab — keep it in the main bundle for instant first paint.
import '../features/shorts/presentation/shorts_feed_screen.dart';
// The other four tabs are deferred: each becomes its own code chunk that is only
// downloaded the first time the user opens that tab (see DeferredWidget).
import '../features/dictionary/presentation/dictionary_screen.dart'
    deferred as dictionary;
import '../features/quiz/presentation/quiz_screen.dart' deferred as quiz;
import '../features/chat/presentation/chat_screen.dart' deferred as chat;
import '../features/review_session/presentation/due_review_screen.dart'
    deferred as review;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppTab.shorts.path,
    redirect: (context, state) {
      // ref.read giữ router instance ổn định; sau completeOnboarding luôn có
      // context.go tường minh nên không cần refreshListenable.
      final onboardingComplete = ref
          .read(userProfileProvider)
          .onboardingComplete;
      final atOnboarding = state.matchedLocation == OnboardingScreen.path;
      if (!onboardingComplete) {
        return atOnboarding ? null : OnboardingScreen.path;
      }
      return atOnboarding ? AppTab.shorts.path : null;
    },
    routes: [
      GoRoute(
        path: OnboardingScreen.path,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // A single persistent shell hosts the 5 tabs. The scaffold + bottom bar are
      // built once (no reload on tab switch); each branch keeps its own state.
      StatefulShellRoute(
        builder: (context, state, navigationShell) => navigationShell,
        navigatorContainerBuilder: (context, navigationShell, children) =>
            RootScaffold(navigationShell: navigationShell, children: children),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.shorts.path,
                builder: (context, state) => const ShortsFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.dictionary.path,
                builder: (context, state) => DeferredWidget(
                  dictionary.loadLibrary,
                  () => dictionary.DictionaryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.quiz.path,
                builder: (context, state) =>
                    DeferredWidget(quiz.loadLibrary, () => quiz.QuizScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.chat.path,
                builder: (context, state) =>
                    DeferredWidget(chat.loadLibrary, () => chat.ChatScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.review.path,
                builder: (context, state) => DeferredWidget(
                  review.loadLibrary,
                  () => review.DueReviewScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
