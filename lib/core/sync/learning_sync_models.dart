import '../learning/application/study_session_controller.dart';
import '../learning/domain/fsrs.dart';
import '../learning_path/learning_progress.dart';

class LearningSyncSnapshot {
  const LearningSyncSnapshot({
    required this.progressUnits,
    required this.srsCards,
    required this.reviewLogs,
  });

  final List<LearningUnitProgress> progressUnits;
  final List<SrsCard> srsCards;
  final List<SrsReviewLog> reviewLogs;
}

class LearningSyncMerge {
  const LearningSyncMerge._();

  static LearningProgressSnapshot mergeProgress(
    LearningProgressSnapshot local,
    Iterable<LearningUnitProgress> remote,
  ) {
    final units = Map<String, LearningUnitProgress>.from(local.units);
    for (final remoteUnit in remote) {
      final localUnit = units[remoteUnit.unitId];
      units[remoteUnit.unitId] = localUnit == null
          ? remoteUnit.copyWith(syncPending: false)
          : _pickProgress(localUnit, remoteUnit);
    }
    return LearningProgressSnapshot(units: units);
  }

  static StudySessionSnapshot mergeStudySession(
    StudySessionSnapshot local,
    Iterable<SrsCard> remoteCards,
    Iterable<SrsReviewLog> remoteLogs,
  ) {
    final cards = Map<String, SrsCard>.from(local.cards);
    for (final remoteCard in remoteCards) {
      final localCard = cards[remoteCard.id];
      cards[remoteCard.id] = localCard == null
          ? remoteCard.copyWith(syncPending: false)
          : _pickCard(localCard, remoteCard);
    }

    final logs = <SrsReviewLog>[];
    final keys = <String>{};
    for (final log in [...local.logs, ...remoteLogs]) {
      final key = log.clientReviewId ?? '${log.cardId}:${log.reviewedAt.toIso8601String()}';
      if (keys.add(key)) logs.add(log);
    }

    return StudySessionSnapshot(
      cards: cards,
      logs: logs,
      reviewedCount: logs.length,
    );
  }

  static LearningUnitProgress _pickProgress(
    LearningUnitProgress local,
    LearningUnitProgress remote,
  ) {
    final comparison = _compareNullableDates(local.updatedAt, remote.updatedAt);
    if (comparison > 0) return local;
    if (comparison < 0) return remote.copyWith(syncPending: false);
    if (_statusRank(local.status) >= _statusRank(remote.status)) return local;
    return remote.copyWith(syncPending: false);
  }

  static SrsCard _pickCard(SrsCard local, SrsCard remote) {
    final reviewComparison = _compareNullableDates(
      local.lastReviewedAt,
      remote.lastReviewedAt,
    );
    if (reviewComparison > 0) return local;
    if (reviewComparison < 0) return remote.copyWith(syncPending: false);
    final updateComparison = _compareNullableDates(local.updatedAt, remote.updatedAt);
    if (updateComparison >= 0) return local;
    return remote.copyWith(syncPending: false);
  }

  static int _compareNullableDates(DateTime? left, DateTime? right) {
    if (left == null && right == null) return 0;
    if (left == null) return -1;
    if (right == null) return 1;
    return left.compareTo(right);
  }

  static int _statusRank(LearningUnitStatus status) {
    switch (status) {
      case LearningUnitStatus.locked:
        return 0;
      case LearningUnitStatus.available:
        return 1;
      case LearningUnitStatus.started:
        return 2;
      case LearningUnitStatus.retry:
        return 3;
      case LearningUnitStatus.completed:
        return 4;
    }
  }
}
