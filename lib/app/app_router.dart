import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/tab_provider.dart';
import '../core/providers/user_profile_provider.dart';
import '../core/widgets/root_scaffold.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';

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
});
