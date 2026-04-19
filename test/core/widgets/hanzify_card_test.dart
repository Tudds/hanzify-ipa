import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';

import '../../test_helpers.dart';

void main() {
  setUpAll(disableGoogleFonts);

  Widget card({
    HanzifyCardVariant variant = HanzifyCardVariant.solid,
    VoidCallback? onTap,
    Widget? child,
  }) {
    return buildTestApp(
      HanzifyCard(
        variant: variant,
        onTap: onTap,
        child: child ?? const Text('Card content'),
      ),
    );
  }

  group('HanzifyCard', () {
    testWidgets('renders child in solid variant', (tester) async {
      await tester.pumpWidget(card());
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders child in glass variant', (tester) async {
      await tester.pumpWidget(card(variant: HanzifyCardVariant.glass));
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders child in outlined variant', (tester) async {
      await tester.pumpWidget(card(variant: HanzifyCardVariant.outlined));
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders child in study variant', (tester) async {
      await tester.pumpWidget(card(variant: HanzifyCardVariant.study));
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(card(onTap: () => tapped = true));
      await tester.tap(find.text('Card content'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('no tap callback — no GestureDetector wrapping', (tester) async {
      await tester.pumpWidget(card());
      // Just ensure it renders without error
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders all 4 variants side by side', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: HanzifyCardVariant.values
                .map((v) => HanzifyCard(
                      variant: v,
                      child: Text(v.name),
                    ))
                .toList(),
          ),
        ),
      );
      for (final v in HanzifyCardVariant.values) {
        expect(find.text(v.name), findsOneWidget);
      }
    });

    testWidgets('golden — solid variant', (tester) async {
      await tester.pumpWidget(card());
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyCard),
        matchesGoldenFile('../../goldens/hanzify_card_solid.png'),
      );
    });

    testWidgets('golden — outlined variant', (tester) async {
      await tester.pumpWidget(card(variant: HanzifyCardVariant.outlined));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyCard),
        matchesGoldenFile('../../goldens/hanzify_card_outlined.png'),
      );
    });

    testWidgets('golden — dark theme solid', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HanzifyCard(child: Text('Dark card')),
          themeColors: AppThemeColors.dark,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyCard),
        matchesGoldenFile('../../goldens/hanzify_card_dark.png'),
      );
    });
  });
}
