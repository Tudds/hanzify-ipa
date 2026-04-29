import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/fsrs.dart';
import 'package:hanzify/core/learning/study_session_controller.dart';
import 'package:hanzify/core/learning/study_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('study session store saves and loads cards and logs', () async {
    SharedPreferences.setMockInitialValues({});
    const store = StudySessionStore();
    final now = DateTime.utc(2026, 1, 1);
    final snapshot = StudySessionSnapshot(
      cards: {
        'vocab:hsk2_中文:recognition': SrsCard(
          id: 'vocab:hsk2_中文:recognition',
          targetType: 'vocab',
          targetId: 'hsk2_中文',
          cardType: 'recognition',
          state: SrsCardState.review,
          dueAt: now.add(const Duration(days: 1)),
          stability: 3,
          difficulty: 5,
          reps: 1,
          lastReviewedAt: now,
        ),
      },
      logs: [
        SrsReviewLog(
          cardId: 'vocab:hsk2_中文:recognition',
          rating: SrsRating.good,
          reviewedAt: now,
          algorithm: FsrsScheduler.algorithm,
          stabilityAfter: 3,
          difficultyAfter: 5,
        ),
      ],
      reviewedCount: 1,
    );

    await store.save(snapshot);
    final loaded = await store.load();

    expect(loaded.cards.length, 1);
    expect(loaded.logs.length, 1);
    expect(loaded.cards.values.single.targetId, 'hsk2_中文');
    expect(loaded.logs.single.rating, SrsRating.good);
  });
}
