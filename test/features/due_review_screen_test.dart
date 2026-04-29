import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/learning/fsrs.dart';
import 'package:hanzify/core/learning/study_session_controller.dart';
import 'package:hanzify/core/learning/study_session_store.dart';
import 'package:hanzify/features/review_session/presentation/due_review_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('due review screen rates due card and completes review', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = StudySessionStore(preferences: preferences);
    await store.save(
      StudySessionSnapshot(
        cards: {
          'vocab:hsk2_中文:recognition': SrsCard(
            id: 'vocab:hsk2_中文:recognition',
            targetType: 'vocab',
            targetId: 'hsk2_中文',
            cardType: 'recognition',
            state: SrsCardState.review,
            dueAt: DateTime(2020),
            stability: 1,
            difficulty: 5,
            reps: 1,
            lastReviewedAt: DateTime(2020),
          ),
        },
        logs: const [],
        reviewedCount: 0,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(child: DueReviewScreen(studySessionStore: store)),
      ),
    );
    await tester.pump();

    expect(find.text('hsk2_中文'), findsOneWidget);
    expect(find.textContaining('Due reviews: 1'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Review complete'), findsOneWidget);
    final saved = await store.load();
    expect(saved.logs.length, 1);
    expect(saved.logs.single.rating, SrsRating.good);
  });
}
