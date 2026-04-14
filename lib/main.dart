import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'core/theme/theme_state.dart';
import 'core/widgets/bottom_tab_bar.dart';
import 'core/providers/navigation_provider.dart';

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
    final screen = ref.watch(navigationProvider);

    Widget buildScreen() {
      switch (screen) {
        case 'vocabList': return const VocabListScreen();
        case 'flashcard': return const FlashcardScreen();
        case 'grammar': return const GrammarScreen();
        case 'quiz': return const QuizScreen();
        case 'progress': return const ProgressScreen();
        default: return const HomeScreen();
      }
    }
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: buildScreen()),
            if (['home', 'vocabList', 'progress'].contains(screen))
              BottomTabBarWidget(
                currentScreen: screen,
                onNavigate: (s) => ref.read(navigationProvider.notifier).navigate(s),
                colors: c,
              ),
          ],
        ),
      ),
    );
  }
}
