import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/widgets/hanzify_streak_badge.dart';

import '../../test_helpers.dart';

void main() {
  setUpAll(disableGoogleFonts);

  Widget badge({int count = 5, bool compact = false, bool animate = false}) {
    return buildTestApp(
      HanzifyStreakBadge(count: count, compact: compact, animate: animate),
    );
  }

  group('HanzifyStreakBadge', () {
    testWidgets('displays streak count', (tester) async {
      await tester.pumpWidget(badge(count: 7));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('displays fire emoji', (tester) async {
      await tester.pumpWidget(badge());
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('renders in compact mode', (tester) async {
      await tester.pumpWidget(badge(compact: true));
      await tester.pumpAndSettle();
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders in normal mode', (tester) async {
      await tester.pumpWidget(badge(compact: false));
      await tester.pumpAndSettle();
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('count 0 renders', (tester) async {
      await tester.pumpWidget(badge(count: 0));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('count 99 renders', (tester) async {
      await tester.pumpWidget(badge(count: 99));
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('animation plays when animate=true', (tester) async {
      await tester.pumpWidget(badge(animate: true));
      // Just ensure it doesn't throw during animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('celebration animates when count increases', (tester) async {
      await tester.pumpWidget(badge(count: 3));
      await tester.pumpAndSettle();

      // Rebuild with higher count should trigger celebration
      await tester.pumpWidget(badge(count: 4));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('golden — normal badge', (tester) async {
      await tester.pumpWidget(badge(count: 15));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyStreakBadge),
        matchesGoldenFile('../../goldens/streak_badge_normal.png'),
      );
    });

    testWidgets('golden — compact badge', (tester) async {
      await tester.pumpWidget(badge(count: 15, compact: true));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyStreakBadge),
        matchesGoldenFile('../../goldens/streak_badge_compact.png'),
      );
    });
  });
}
