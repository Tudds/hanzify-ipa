import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_state.dart';

import 'core/theme/app_durations.dart';
import 'core/widgets/bottom_tab_bar.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/nav_visibility_provider.dart';
import 'core/navigation/app_routes.dart';

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
import 'features/conversation/presentation/screens/conversation_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/character/presentation/screens/character_detail_screen.dart';

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
    final c = ref.watch(themeColorsProvider);
    final nav = ref.watch(navigationProvider);
    final isNavVisible = ref.watch(navVisibilityProvider);
    final screen = nav.screen;

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
          return CharacterDetailScreen(char: nav.arg ?? '');
        default:
          return const HomeScreen();
      }
    }

    final showTabBar = AppRoutes.tabBarScreens.contains(screen);

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
            Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppDurations.slow,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
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
                      key: ValueKey<String>('${nav.screen}_${nav.arg}'),
                      child: buildScreen(),
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Navigation - Autohide
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: (isNavVisible && showTabBar) ? Offset.zero : const Offset(0, 1),
                duration: AppDurations.normal,
                curve: Curves.easeInOutCubic,
                child: BottomTabBarWidget(
                  currentScreen: screen,
                  onNavigate: (s) =>
                      ref.read(navigationProvider.notifier).navigate(s),
                  colors: c,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


