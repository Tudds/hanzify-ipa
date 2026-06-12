import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/application/study_session_controller.dart';
import 'package:hanzify/core/learning/domain/fsrs.dart';
import 'package:hanzify/core/learning/study_session_store.dart';
import 'package:hanzify/core/learning_path/learning_progress.dart';
import 'package:hanzify/core/learning_path/learning_progress_store.dart';
import 'package:hanzify/core/sync/learning_sync_data_source.dart';
import 'package:hanzify/core/sync/learning_sync_models.dart';
import 'package:hanzify/core/sync/learning_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('sync pulls remote, merges local, and pushes pending records', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progressStore = LearningProgressStore(preferences: preferences);
    final studyStore = StudySessionStore(preferences: preferences);
    final dataSource = _FakeLearningSyncDataSource(
      remote: LearningSyncSnapshot(
        progressUnits: [
          _progress(
            status: LearningUnitStatus.completed,
            updatedAt: DateTime(2026, 1, 2),
            syncPending: false,
          ),
        ],
        srsCards: [],
        reviewLogs: [],
      ),
    );

    await progressStore.upsert(
      _progress(
        status: LearningUnitStatus.started,
        updatedAt: DateTime(2026, 1, 1),
        syncPending: true,
      ),
    );
    await studyStore.save(
      StudySessionSnapshot(
        cards: {
          'vocab:ni3:recognition': _card(syncPending: true),
        },
        logs: [_log()],
        reviewedCount: 1,
      ),
    );

    await LearningSyncService(
      progressStore: progressStore,
      studySessionStore: studyStore,
      dataSource: dataSource,
    ).sync();

    final progress = await progressStore.load();
    expect(progress.units['lesson-1']!.status, LearningUnitStatus.completed);
    expect(dataSource.pushedCards.single.id, 'vocab:ni3:recognition');
    expect(dataSource.pushedLogs.single.clientReviewId, 'review-1');
    expect(dataSource.statuses.last, 'idle');
  });

  test('sync swallows data source failures', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dataSource = _FakeLearningSyncDataSource(
      remote: const LearningSyncSnapshot(
        progressUnits: [],
        srsCards: [],
        reviewLogs: [],
      ),
      failPull: true,
    );

    await LearningSyncService(
      progressStore: LearningProgressStore(preferences: preferences),
      studySessionStore: StudySessionStore(preferences: preferences),
      dataSource: dataSource,
    ).sync();

    expect(dataSource.statuses, contains('error'));
  });

  test('sync is a silent no-op when signed out', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dataSource = _FakeLearningSyncDataSource(
      remote: const LearningSyncSnapshot(
        progressUnits: [],
        srsCards: [],
        reviewLogs: [],
      ),
      hasUser: false,
    );
    final phases = <LearningSyncPhase>[];

    await LearningSyncService(
      progressStore: LearningProgressStore(preferences: preferences),
      studySessionStore: StudySessionStore(preferences: preferences),
      dataSource: dataSource,
      observer: (phase, {error}) => phases.add(phase),
    ).sync();

    expect(dataSource.pullCount, 0);
    expect(dataSource.statuses, isEmpty);
    expect(phases, isEmpty);
  });

  test('observer reports started then failed on pull error', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dataSource = _FakeLearningSyncDataSource(
      remote: const LearningSyncSnapshot(
        progressUnits: [],
        srsCards: [],
        reviewLogs: [],
      ),
      failPull: true,
    );
    final phases = <LearningSyncPhase>[];
    String? reportedError;

    await LearningSyncService(
      progressStore: LearningProgressStore(preferences: preferences),
      studySessionStore: StudySessionStore(preferences: preferences),
      dataSource: dataSource,
      observer: (phase, {error}) {
        phases.add(phase);
        reportedError ??= error;
      },
    ).sync();

    expect(phases, [LearningSyncPhase.started, LearningSyncPhase.failed]);
    expect(reportedError, contains('offline'));
  });
}

class _FakeLearningSyncDataSource implements LearningSyncDataSource {
  _FakeLearningSyncDataSource({
    required this.remote,
    this.failPull = false,
    this.hasUser = true,
  });

  final LearningSyncSnapshot remote;
  final bool failPull;
  final statuses = <String>[];
  final pushedProgress = <LearningUnitProgress>[];
  final pushedCards = <SrsCard>[];
  final pushedLogs = <SrsReviewLog>[];

  @override
  final bool hasUser;

  var pullCount = 0;

  @override
  Future<LearningSyncSnapshot> pull() async {
    pullCount += 1;
    if (failPull) throw StateError('offline');
    return remote;
  }

  @override
  Future<void> pushCards(List<SrsCard> cards) async {
    pushedCards.addAll(cards);
  }

  @override
  Future<void> pushProgress(List<LearningUnitProgress> units) async {
    pushedProgress.addAll(units);
  }

  @override
  Future<void> pushReviewLogs(List<SrsReviewLog> logs) async {
    pushedLogs.addAll(logs);
  }

  @override
  Future<void> updateStatus(String status, String? error) async {
    statuses.add(status);
  }
}

LearningUnitProgress _progress({
  required LearningUnitStatus status,
  required DateTime updatedAt,
  required bool syncPending,
}) {
  return LearningUnitProgress(
    unitId: 'lesson-1',
    unitKind: LearningUnitKind.lesson,
    stageId: 'HSK2',
    moduleId: 'module-1',
    status: status,
    updatedAt: updatedAt,
    syncPending: syncPending,
  );
}

SrsCard _card({required bool syncPending}) {
  return SrsCard(
    id: 'vocab:ni3:recognition',
    targetType: 'vocab',
    targetId: 'ni3',
    cardType: 'recognition',
    state: SrsCardState.review,
    lastReviewedAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    syncPending: syncPending,
  );
}

SrsReviewLog _log() {
  return SrsReviewLog(
    cardId: 'vocab:ni3:recognition',
    rating: SrsRating.good,
    reviewedAt: DateTime(2026, 1, 1),
    algorithm: FsrsScheduler.algorithm,
    clientReviewId: 'review-1',
  );
}
