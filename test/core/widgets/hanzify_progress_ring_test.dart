import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/widgets/hanzify_progress_ring.dart';

import '../../test_helpers.dart';

void main() {
  setUpAll(disableGoogleFonts);

  Widget ring({
    double progress = 0.5,
    String? label,
    String? sublabel,
    double size = 80,
  }) {
    return buildTestApp(
      HanzifyProgressRing(
        progress: progress,
        size: size,
        label: label,
        sublabel: sublabel,
      ),
    );
  }

  group('HanzifyProgressRing', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(ring(label: '10', sublabel: 'thẻ'));
      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);
      expect(find.text('thẻ'), findsOneWidget);
    });

    testWidgets('renders without label', (tester) async {
      await tester.pumpWidget(ring());
      await tester.pumpAndSettle();
      // No label → no text widget
      expect(find.byType(HanzifyProgressRing), findsOneWidget);
    });

    testWidgets('progress=0 renders empty ring', (tester) async {
      await tester.pumpWidget(ring(progress: 0.0, label: '0'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('progress=1 renders full ring', (tester) async {
      await tester.pumpWidget(ring(progress: 1.0, label: '20'));
      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('clamps progress > 1 to 1', (tester) async {
      // Should not throw
      await tester.pumpWidget(ring(progress: 1.5, label: 'max'));
      await tester.pumpAndSettle();
      expect(find.text('max'), findsOneWidget);
    });

    testWidgets('updates ring when progress changes', (tester) async {
      await tester.pumpWidget(ring(progress: 0.3, label: '6'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(ring(progress: 0.8, label: '16'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('16'), findsOneWidget);
    });

    testWidgets('renders custom size', (tester) async {
      await tester.pumpWidget(ring(size: 120, label: 'big'));
      await tester.pumpAndSettle();
      final sized = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(AnimatedBuilder),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sized.width, 120);
      expect(sized.height, 120);
    });

    testWidgets('renders custom center widget', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HanzifyProgressRing(
            progress: 0.5,
            center: const Icon(Icons.star),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('golden — 50% progress with label', (tester) async {
      await tester.pumpWidget(ring(progress: 0.5, label: '10', sublabel: '/20'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyProgressRing),
        matchesGoldenFile('../../goldens/progress_ring_half.png'),
      );
    });

    testWidgets('golden — full progress', (tester) async {
      await tester.pumpWidget(ring(progress: 1.0, label: '20', sublabel: '/20'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HanzifyProgressRing),
        matchesGoldenFile('../../goldens/progress_ring_full.png'),
      );
    });
  });
}
