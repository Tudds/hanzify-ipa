import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/application/study_session_controller.dart';
import 'package:hanzify/core/learning/domain/fsrs.dart';
import 'package:hanzify/core/learning_path/learning_progress.dart';
import 'package:hanzify/core/sync/learning_sync_models.dart';

void main() {
  test('merge progress keeps newer local unit', () {
    final localTime = DateTime(2026, 1, 2);
    final remoteTime = DateTime(2026, 1, 1);
    final local = LearningProgressSnapshot(
      units: {
        'lesson-1': _progress(
          status: LearningUnitStatus.completed,
          updatedAt: localTime,
        ),
      },
    );

    final merged = LearningSyncMerge.mergeProgress(local, [
      _progress(status: LearningUnitStatus.started, updatedAt: remoteTime),
    ]);

    expect(merged.units['lesson-1']!.status, LearningUnitStatus.completed);
    expect(merged.units['lesson-1']!.syncPending, isTrue);
  });

  test('merge progress uses newer remote unit as synced', () {
    final local = LearningProgressSnapshot(
      units: {
        'lesson-1': _progress(
          status: LearningUnitStatus.started,
          updatedAt: DateTime(2026, 1, 1),
        ),
      },
    );

    final merged = LearningSyncMerge.mergeProgress(local, [
      _progress(
        status: LearningUnitStatus.completed,
        updatedAt: DateTime(2026, 1, 2),
      ),
    ]);

    expect(merged.units['lesson-1']!.status, LearningUnitStatus.completed);
    expect(merged.units['lesson-1']!.syncPending, isFalse);
  });

  test('merge study session dedupes review logs by client id', () {
    final reviewedAt = DateTime(2026, 1, 1);
    final local = StudySessionSnapshot(
      cards: {
        'vocab:ni3:recognition': _card(
          lastReviewedAt: DateTime(2026, 1, 2),
          syncPending: true,
        ),
      },
      logs: [_log(reviewedAt: reviewedAt, clientReviewId: 'review-1')],
      reviewedCount: 1,
    );

    final merged = LearningSyncMerge.mergeStudySession(
      local,
      [
        _card(
          lastReviewedAt: DateTime(2026, 1, 1),
          syncPending: false,
        ),
      ],
      [_log(reviewedAt: reviewedAt, clientReviewId: 'review-1')],
    );

    expect(merged.cards['vocab:ni3:recognition']!.syncPending, isTrue);
    expect(merged.logs, hasLength(1));
  });
}

LearningUnitProgress _progress({
  required LearningUnitStatus status,
  required DateTime updatedAt,
}) {
  return LearningUnitProgress(
    unitId: 'lesson-1',
    unitKind: LearningUnitKind.lesson,
    stageId: 'HSK2',
    moduleId: 'module-1',
    status: status,
    updatedAt: updatedAt,
    syncPending: true,
  );
}

SrsCard _card({required DateTime lastReviewedAt, required bool syncPending}) {
  return SrsCard(
    id: 'vocab:ni3:recognition',
    targetType: 'vocab',
    targetId: 'ni3',
    cardType: 'recognition',
    state: SrsCardState.review,
    lastReviewedAt: lastReviewedAt,
    updatedAt: lastReviewedAt,
    syncPending: syncPending,
  );
}

SrsReviewLog _log({required DateTime reviewedAt, required String clientReviewId}) {
  return SrsReviewLog(
    cardId: 'vocab:ni3:recognition',
    rating: SrsRating.good,
    reviewedAt: reviewedAt,
    algorithm: FsrsScheduler.algorithm,
    clientReviewId: clientReviewId,
  );
}
