import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../learning/data/study_session_store.dart';
import '../learning_path/learning_progress_store.dart';
import 'learning_sync_data_source.dart';
import 'learning_sync_models.dart';
import 'learning_sync_trigger.dart';

class LearningSyncService {
  LearningSyncService({
    required LearningProgressStore progressStore,
    required StudySessionStore studySessionStore,
    required LearningSyncDataSource dataSource,
  }) : _progressStore = progressStore,
       _studySessionStore = studySessionStore,
       _dataSource = dataSource;

  factory LearningSyncService.supabase({
    LearningProgressStore progressStore = const LearningProgressStore(),
    StudySessionStore studySessionStore = const StudySessionStore(),
    SupabaseClient? client,
  }) {
    return LearningSyncService(
      progressStore: progressStore,
      studySessionStore: studySessionStore,
      dataSource: SupabaseLearningSyncDataSource(
        client ?? Supabase.instance.client,
      ),
    );
  }

  final LearningProgressStore _progressStore;
  final StudySessionStore _studySessionStore;
  final LearningSyncDataSource _dataSource;

  Future<void> sync() async {
    try {
      await _dataSource.updateStatus('pulling', null);
      final remote = await _dataSource.pull();
      final localProgress = await _progressStore.load();
      final localStudy = await _studySessionStore.load();

      final mergedProgress = LearningSyncMerge.mergeProgress(
        localProgress,
        remote.progressUnits,
      );
      final mergedStudy = LearningSyncMerge.mergeStudySession(
        localStudy,
        remote.srsCards,
        remote.reviewLogs,
      );

      await LearningSyncTrigger.suppress(() async {
        await _progressStore.save(mergedProgress);
        await _studySessionStore.save(mergedStudy);
      });

      await _dataSource.updateStatus('pushing', null);
      final pendingUnits = mergedProgress.units.values
          .where((unit) => unit.syncPending)
          .toList();
      final pendingCards = mergedStudy.cards.values
          .where((card) => card.syncPending)
          .toList();
      await _dataSource.pushProgress(pendingUnits);
      await _progressStore.markSynced(
        unitIds: pendingUnits.map((unit) => unit.unitId),
      );
      await _dataSource.pushCards(pendingCards);
      await _studySessionStore.markSynced(
        cardIds: pendingCards.map((card) => card.id),
      );
      await _dataSource.pushReviewLogs(mergedStudy.logs);
      await _dataSource.updateStatus('idle', null);
    } catch (error, stackTrace) {
      debugPrint('[LearningSync] sync failed: $error\n$stackTrace');
      try {
        await _dataSource.updateStatus('error', error.toString());
      } catch (statusError) {
        debugPrint('[LearningSync] status update failed: $statusError');
      }
    }
  }
}
