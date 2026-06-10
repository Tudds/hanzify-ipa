import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/providers/tab_provider.dart';
import 'package:hanzify/core/widgets/root_scaffold.dart';

import '../support/profile_overrides.dart';

Widget _wrap(AppTab tab, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: RootScaffold(tab: tab)),
  );
}

/// Pumps enough frames for a tab to settle. Dictionary/Quiz/Chat/Review are
/// deferred-loaded (`loadLibrary`), so the final pump renders the screen after
/// the deferred future completes and triggers a rebuild.
Future<void> _showTab(
  WidgetTester tester,
  AppTab tab,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_wrap(tab, overrides));
  await tester.pump(); // placeholder + kick off loadLibrary
  await tester.pump(const Duration(seconds: 1)); // deferred future completes
  await tester.pump(); // rebuild mounts the real screen (flutter_animate starts)
  await tester.pump(const Duration(seconds: 1)); // drain entrance-animation timers
}

void main() {
  testWidgets('root shell uses five primary tabs', (tester) async {
    final overrides = await profileTestOverrides();

    await _showTab(tester, AppTab.shorts, overrides);
    expect(find.text('Short'), findsWidgets);
    expect(find.byIcon(Icons.manage_search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.quiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.forum_rounded), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await _showTab(tester, AppTab.dictionary, overrides);
    expect(find.text('Từ điển'), findsWidgets);
    expect(find.text('Từ vựng'), findsOneWidget);
    expect(find.text('Ngữ pháp'), findsOneWidget);

    await _showTab(tester, AppTab.quiz, overrides);
    expect(find.text('Quiz'), findsWidgets);
    expect(find.text('Chọn từ'), findsWidgets);
    expect(find.text('Sắp xếp'), findsWidgets);

    await _showTab(tester, AppTab.chat, overrides);
    expect(find.text('Chat'), findsWidgets);
    expect(find.textContaining('Chat GenUI local'), findsWidgets);

    await _showTab(tester, AppTab.review, overrides);
    expect(find.text('Ôn tập'), findsWidgets);
  });
}
