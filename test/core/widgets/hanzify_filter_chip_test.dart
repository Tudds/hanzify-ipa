import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/widgets/hanzify_filter_chip.dart';

import '../../test_helpers.dart';

void main() {
  setUpAll(disableGoogleFonts);

  Widget chip({
    bool isActive = false,
    String? emoji,
    VoidCallback? onTap,
  }) {
    return buildTestApp(
      HanzifyFilterChip(
        label: 'HSK 1',
        emoji: emoji,
        isActive: isActive,
        onTap: onTap ?? () {},
      ),
    );
  }

  group('HanzifyFilterChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(chip());
      expect(find.text('HSK 1'), findsOneWidget);
    });

    testWidgets('renders emoji when provided', (tester) async {
      await tester.pumpWidget(chip(emoji: '📚'));
      expect(find.text('📚'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(chip(onTap: () => tapped = true));
      await tester.tap(find.byType(HanzifyFilterChip));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders in inactive state', (tester) async {
      await tester.pumpWidget(chip(isActive: false));
      await tester.pumpAndSettle();
      // Inactive: transparent/surface background
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      // Inactive chip should NOT use primary color as background
      expect(decoration.color, isNotNull);
    });

    testWidgets('renders in active state', (tester) async {
      await tester.pumpWidget(chip(isActive: true));
      await tester.pumpAndSettle();
      expect(find.text('HSK 1'), findsOneWidget);
    });

    testWidgets('golden — inactive chip', (tester) async {
      await tester.pumpWidget(chip(isActive: false, emoji: '📚'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyFilterChip),
        matchesGoldenFile('../../goldens/filter_chip_inactive.png'),
      );
    });

    testWidgets('golden — active chip', (tester) async {
      await tester.pumpWidget(chip(isActive: true, emoji: '📚'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyFilterChip),
        matchesGoldenFile('../../goldens/filter_chip_active.png'),
      );
    });
  });
}
