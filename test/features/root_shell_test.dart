import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/app/app_router.dart';
import 'package:hanzify/features/shorts/domain/shorts_session.dart';
import 'package:hanzify/features/shorts/presentation/shorts_feed_screen.dart';

import '../support/profile_overrides.dart';

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: [
      // Shorts is the initial tab and stays alive in the shell's PageView. Its
      // real feed spins up per-card countdown/reveal timers; an empty session
      // keeps this shell test focused (and timer-free) while Shorts still
      // renders inside the shell.
      shortsSessionLoaderProvider.overrideWith(
        (ref) async => const ShortsSession(items: []),
      ),
      ...overrides,
    ],
    child: Consumer(
      builder: (context, ref, child) =>
          MaterialApp.router(routerConfig: ref.watch(appRouterProvider)),
    ),
  );
}

/// Pumps enough frames for the active tab to settle. Dictionary/Quiz/Chat/Review
/// are deferred-loaded (`loadLibrary`), so the extra pumps render the screen
/// after the deferred future completes and triggers a rebuild.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(); // placeholder + kick off loadLibrary
  await tester.pump(const Duration(seconds: 1)); // deferred future completes
  await tester.pump(); // rebuild mounts the real screen
  await tester.pump(const Duration(seconds: 1)); // drain entrance animations
}

/// Switches tabs the way a user would: tapping the bottom-bar icon. Inactive
/// tabs are icon-only, so they're reliably found by their [IconData].
Future<void> _tapTab(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(icon));
  await _settle(tester);
}

void main() {
  testWidgets('root shell uses five primary tabs', (tester) async {
    // performance_mode disables flutter_animate header entrances so the
    // always-alive tabs don't leave animation timers pending at teardown.
    final overrides = await profileTestOverrides(
      prefs: {...onboardedPrefs(), 'performance_mode': true},
    );

    await tester.pumpWidget(_wrap(overrides));
    await _settle(tester);

    // Initial tab is Shorts: its label is visible, the other four are icon-only.
    expect(find.text('Short'), findsWidgets);
    expect(find.byIcon(Icons.manage_search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.quiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.forum_rounded), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await _tapTab(tester, Icons.manage_search_rounded);
    expect(find.text('Từ điển'), findsWidgets);
    expect(find.text('Từ vựng'), findsOneWidget);
    expect(find.text('Ngữ pháp'), findsOneWidget);

    await _tapTab(tester, Icons.quiz_rounded);
    expect(find.text('Quiz'), findsWidgets);
    expect(find.text('Chọn từ'), findsWidgets);
    expect(find.text('Sắp xếp'), findsWidgets);

    await _tapTab(tester, Icons.forum_rounded);
    expect(find.text('Chat'), findsWidgets);
    expect(find.textContaining('GenUI local'), findsWidgets);

    await _tapTab(tester, Icons.refresh_rounded);
    expect(find.text('Ôn tập'), findsWidgets);
  });
}
