import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/theme_state.dart';

import 'core/theme/app_durations.dart';
import 'core/widgets/app_navigation_shell.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/nav_visibility_provider.dart';
import 'core/providers/performance_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/sync_provider.dart';
import 'core/providers/guest_mode_provider.dart';
import 'core/navigation/app_routes.dart';
import 'core/providers/user_preferences_provider.dart';
import 'features/auth/presentation/screens/auth_screen.dart';

// Conditional import: web → platform_web, native → platform_native
// This ensures dart2js never sees dart:io / drift/native.dart / sqlite3 FFI.
import 'core/platform/platform_web.dart'
    if (dart.library.io) 'core/platform/platform_native.dart';

// Import screens from new locations
import 'features/dashboard/presentation/screens/home_screen.dart';
import 'features/vocab/presentation/screens/vocab_list_screen.dart';
import 'features/vocab/presentation/screens/flashcard_screen.dart';
import 'features/vocab/presentation/screens/quiz_screen.dart';
import 'features/dashboard/presentation/screens/progress_screen.dart';
import 'features/grammar/presentation/screens/grammar_screen.dart';
import 'features/grammar/presentation/screens/grammar_detail_screen.dart';
import 'features/conversation/presentation/screens/conversation_screen.dart';
import 'features/conversation/presentation/screens/conversation_detail_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/character/presentation/screens/character_detail_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/vocab/presentation/screens/vocab_detail_screen.dart';
import 'features/vocab/domain/entities/vocab.dart';
import 'features/vocab/presentation/providers/vocab_state.dart';
import 'features/grammar/domain/entities/grammar_point.dart';
import 'features/conversation/domain/entities/conversation_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final app = await createProviderScope(const HSKApp());

  runApp(app);
}

class HSKApp extends ConsumerWidget {
  const HSKApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state để rebuild khi theme thay đổi. `.notifier` chỉ subscribe
    // khi instance notifier đổi, không rebuild khi state đổi.
    ref.watch(themeProvider);
    final themeData = ref.read(themeProvider.notifier).themeData;

    return MaterialApp(
      title: 'Hanzify',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth gate: chưa đăng nhập & chưa bật guest mode → AuthScreen
    // Eagerly init SyncNotifier so it listens to auth + connectivity events
    ref.watch(syncProvider);

    final authAsync = ref.watch(authStateChangesProvider);
    final hasSession =
        authAsync.whenOrNull(data: (state) => state.session != null) ??
        (Supabase.instance.client.auth.currentSession != null);
    final isGuest = ref.watch(guestModeProvider);

    if (!hasSession && !isGuest) {
      final showOnboarding = ref.watch(showOnboardingProvider);
      if (showOnboarding) {
        return OnboardingScreen(
          onFinish: () => ref.read(showOnboardingProvider.notifier).complete(),
        );
      }

      return authAsync.when(
        data: (_) => const AuthScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const AuthScreen(),
      );
    }

    final c = ref.watch(themeColorsProvider);
    final nav = ref.watch(navigationProvider);
    final isNavVisible = ref.watch(navVisibilityProvider);
    final isReduced = ref.watch(performanceProvider);
    final screen = nav.screen;
    final dueCount = ref.watch(dueVocabProvider).asData?.value.length ?? 0;
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 840;

    Widget buildScreen() {
      switch (screen) {
        case AppRoutes.vocabList:
          return const VocabListScreen();
        case AppRoutes.flashcard:
          return const FlashcardScreen();
        case AppRoutes.grammar:
          return const GrammarScreen();
        case AppRoutes.conversation:
          return const ConversationScreen();
        case AppRoutes.quiz:
          return const QuizScreen();
        case AppRoutes.progress:
          return const ProgressScreen();
        case AppRoutes.profile:
          return const ProfileScreen();
        case AppRoutes.charDetail:
          final char = nav.arg;
          return CharacterDetailScreen(char: char is String ? char : '');
        case AppRoutes.vocabDetail:
          final vocab = nav.arg;
          return vocab is Vocab
              ? VocabDetailScreen(vocab: vocab)
              : const HomeScreen();
        case AppRoutes.grammarDetail:
          final grammar = nav.arg;
          return grammar is GrammarPoint
              ? GrammarDetailScreen(grammar: grammar)
              : const GrammarScreen();
        case AppRoutes.conversationDetail:
          final conversation = nav.arg;
          return conversation is ConversationContext
              ? ConversationDetailScreen(conversation: conversation)
              : const ConversationScreen();
        default:
          return const HomeScreen();
      }
    }

    final showPrimaryNav = AppRoutes.tabBarScreens.contains(screen);

    return Scaffold(
      backgroundColor: c.background,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          final direction = notification.direction;
          if (direction == ScrollDirection.reverse) {
            ref.read(navVisibilityProvider.notifier).hide();
          } else if (direction == ScrollDirection.forward) {
            ref.read(navVisibilityProvider.notifier).show();
          }
          return true;
        },
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: isReduced ? AppDurations.fast : AppDurations.slow,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                if (isReduced) {
                  return FadeTransition(opacity: animation, child: child);
                }
                final scale = Tween<double>(begin: 0.97, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeIn,
                  ),
                  child: ScaleTransition(scale: scale, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<(String, Object?)>((nav.screen, nav.arg)),
                child: AppNavigationShell(
                  currentScreen: screen,
                  onNavigate: (s) =>
                      ref.read(navigationProvider.notifier).navigate(s),
                  useRail: useRail,
                  showPrimaryNav: showPrimaryNav,
                  isNavVisible: isNavVisible,
                  dueCount: dueCount,
                  child: buildScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
