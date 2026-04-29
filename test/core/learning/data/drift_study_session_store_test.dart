import 'dart:ffi';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/database/app_database.dart';
import 'package:hanzify/core/learning/application/study_session_controller.dart';
import 'package:hanzify/core/learning/data/drift/drift_study_session_store.dart';
import 'package:hanzify/core/learning/domain/fsrs.dart';

void main() {
  final sqliteAvailable = _sqliteAvailable();
  late AppDatabase database;
  late DriftStudySessionStore store;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    store = DriftStudySessionStore(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'saves and loads SRS cards with review logs',
    () async {
      final reviewedAt = DateTime(2026, 4, 27, 8);
      final snapshot = StudySessionSnapshot(
        cards: {
          'card-1': SrsCard(
            id: 'card-1',
            targetType: 'word',
            targetId: '你好',
            cardType: 'recognition',
            state: SrsCardState.review,
            dueAt: reviewedAt.add(const Duration(days: 1)),
            stability: 3.2,
            difficulty: 4.1,
            elapsedDays: 1,
            scheduledDays: 1,
            reps: 2,
            lapses: 0,
            lastReviewedAt: reviewedAt,
          ),
        },
        logs: [
          SrsReviewLog(
            cardId: 'card-1',
            rating: SrsRating.good,
            reviewedAt: reviewedAt,
            algorithm: FsrsScheduler.algorithm,
            stabilityBefore: 2.1,
            difficultyBefore: 4.4,
            stabilityAfter: 3.2,
            difficultyAfter: 4.1,
          ),
        ],
        reviewedCount: 1,
      );

      await store.save(snapshot);
      final loaded = await store.load();

      expect(loaded.cards, hasLength(1));
      expect(loaded.cards['card-1']?.targetId, '你好');
      expect(loaded.cards['card-1']?.state, SrsCardState.review);
      expect(loaded.logs.single.rating, SrsRating.good);
      expect(loaded.reviewedCount, 1);
    },
    skip: sqliteAvailable
        ? null
        : 'libsqlite3 is not available in this environment',
  );
}

bool _sqliteAvailable() {
  try {
    DynamicLibrary.open('libsqlite3.so');
    return true;
  } catch (_) {
    return false;
  }
}
