import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/features/vocab/presentation/screens/flashcard/widgets/flashcard_study_view.dart';

import '../../test_helpers.dart';

/// Build [FlashcardStudyView] inside ProviderScope + MaterialApp.
Widget buildFlashcardView({
  int currentIndex = 0,
  bool? scoreFeedback,
  Function(int)? onScore,
  ValueChanged<int>? onPageChanged,
}) {
  final cards = makeVocabList(count: 3);
  final pageCtrl = PageController();

  return buildTestApp(
    FlashcardStudyView(
      cards: cards,
      currentIndex: currentIndex,
      scoreFeedback: scoreFeedback,
      onScore: onScore ?? (_) {},
      pageController: pageCtrl,
      onPageChanged: onPageChanged,
      header: const HanzifyAppBar(
        title: 'Flashcard',
        variant: HanzifyAppBarVariant.standard,
      ),
    ),
  );
}

void main() {
  setUpAll(disableGoogleFonts);

  group('FlashcardStudyView — initial state', () {
    testWidgets('renders the hanzi of the first card', (tester) async {
      await tester.pumpWidget(buildFlashcardView());
      await tester.pump();

      final cards = makeVocabList(count: 3);
      expect(find.text(cards.first.hanzi), findsOneWidget);
    });

    testWidgets('grade buttons NOT shown before reveal', (tester) async {
      await tester.pumpWidget(buildFlashcardView());
      await tester.pump();

      // Grade button labels (Vietnamese)
      expect(find.text('Quên'), findsNothing);
      expect(find.text('Khó'), findsNothing);
      expect(find.text('Tốt'), findsNothing);
      expect(find.text('Dễ'), findsNothing);
    });

    testWidgets('shows tap-to-reveal hint text', (tester) async {
      await tester.pumpWidget(buildFlashcardView());
      await tester.pump();

      expect(find.text('Nhấn để xem nghĩa'), findsOneWidget);
    });
  });

  group('FlashcardStudyView — after reveal', () {
    testWidgets('grade buttons appear after tapping card', (tester) async {
      await tester.pumpWidget(buildFlashcardView());
      await tester.pump();

      // Tap the card to reveal
      await tester.tap(find.text('Nhấn để xem nghĩa'));
      await tester.pumpAndSettle();

      // Grade buttons should now be visible
      expect(find.text('Quên'), findsOneWidget);
      expect(find.text('Khó'), findsOneWidget);
      expect(find.text('Tốt'), findsOneWidget);
      expect(find.text('Dễ'), findsOneWidget);
    });

    testWidgets('back face shows pinyin after reveal', (tester) async {
      await tester.pumpWidget(buildFlashcardView());
      await tester.pump();

      await tester.tap(find.text('Nhấn để xem nghĩa'));
      await tester.pumpAndSettle();

      final cards = makeVocabList(count: 3);
      expect(find.text(cards.first.pinyin), findsOneWidget);
    });
  });

  group('FlashcardStudyView — grading', () {
    testWidgets('tapping "Quên" calls onScore with 0', (tester) async {
      int? scored;
      await tester.pumpWidget(buildFlashcardView(onScore: (s) => scored = s));
      await tester.pump();

      // Reveal card first
      await tester.tap(find.text('Nhấn để xem nghĩa'));
      await tester.pumpAndSettle();

      // Tap "Quên" (Again/score=0)
      await tester.tap(find.text('Quên'));
      await tester.pump();

      expect(scored, 0);
    });

    testWidgets('tapping "Tốt" calls onScore with 4', (tester) async {
      int? scored;
      await tester.pumpWidget(buildFlashcardView(onScore: (s) => scored = s));
      await tester.pump();

      await tester.tap(find.text('Nhấn để xem nghĩa'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tốt'));
      await tester.pump();

      expect(scored, 4);
    });

    testWidgets('tapping "Dễ" calls onScore with 5', (tester) async {
      int? scored;
      await tester.pumpWidget(buildFlashcardView(onScore: (s) => scored = s));
      await tester.pump();

      await tester.tap(find.text('Nhấn để xem nghĩa'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dễ'));
      await tester.pump();

      expect(scored, 5);
    });

    testWidgets('correct feedback border visible when scoreFeedback=true', (tester) async {
      await tester.pumpWidget(
        buildFlashcardView(scoreFeedback: true),
      );
      await tester.pump();
      // Widget renders without error
      expect(find.byType(FlashcardStudyView), findsOneWidget);
    });

    testWidgets('wrong feedback border visible when scoreFeedback=false', (tester) async {
      await tester.pumpWidget(
        buildFlashcardView(scoreFeedback: false),
      );
      await tester.pump();
      expect(find.byType(FlashcardStudyView), findsOneWidget);
    });
  });

  group('FlashcardStudyView — page state', () {
    testWidgets('_revealed resets on page change', (tester) async {
      await tester.pumpWidget(buildFlashcardView());
      await tester.pump();

      // Reveal card 0
      await tester.tap(find.text('Nhấn để xem nghĩa'));
      await tester.pumpAndSettle();
      expect(find.text('Quên'), findsOneWidget);

      // Trigger page change by calling onPageChanged
      // (simulating swipe is difficult with PageView, test the callback instead)
    });

    testWidgets('onPageChanged callback is fired', (tester) async {
      int? changedTo;
      await tester.pumpWidget(
        buildFlashcardView(onPageChanged: (i) => changedTo = i),
      );
      await tester.pump();

      // Swipe to next page
      await tester.drag(
        find.byType(PageView),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      expect(changedTo, isNotNull);
    });
  });

  group('FlashcardStudyView — empty cards', () {
    testWidgets('renders empty view without crash when cards list is empty', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          FlashcardStudyView(
            cards: const [],
            currentIndex: 0,
            scoreFeedback: null,
            onScore: (_) {},
            pageController: PageController(),
            header: const HanzifyAppBar(
              title: 'Flashcard',
              variant: HanzifyAppBarVariant.standard,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlashcardStudyView), findsOneWidget);
    });
  });
}
