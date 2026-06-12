import 'package:supabase_flutter/supabase_flutter.dart';

import '../learning/domain/fsrs.dart';
import '../learning_path/learning_progress.dart';
import 'learning_sync_models.dart';

abstract class LearningSyncDataSource {
  /// Sync chỉ chạy khi đã đăng nhập — [LearningSyncService] kiểm tra cờ này
  /// trước khi pull/push để không crash lúc chưa có user.
  bool get hasUser;

  Future<LearningSyncSnapshot> pull();
  Future<void> pushProgress(List<LearningUnitProgress> units);
  Future<void> pushCards(List<SrsCard> cards);
  Future<void> pushReviewLogs(List<SrsReviewLog> logs);
  Future<void> updateStatus(String status, String? error);
}

class SupabaseLearningSyncDataSource implements LearningSyncDataSource {
  const SupabaseLearningSyncDataSource(this.client);

  final SupabaseClient client;

  @override
  bool get hasUser => client.auth.currentUser != null;

  String get _userId {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Sync requires a signed-in user');
    }
    return user.id;
  }

  @override
  Future<LearningSyncSnapshot> pull() async {
    final progressRows = await client
        .from('user_learning_unit_progress')
        .select()
        .eq('user_id', _userId);
    final cardRows = await client
        .from('user_srs_cards')
        .select()
        .eq('user_id', _userId);
    final logRows = await client
        .from('user_srs_review_logs')
        .select()
        .eq('user_id', _userId);

    return LearningSyncSnapshot(
      progressUnits: (progressRows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_progressFromSupabase)
          .toList(),
      srsCards: (cardRows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_cardFromSupabase)
          .toList(),
      reviewLogs: (logRows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_logFromSupabase)
          .toList(),
    );
  }

  @override
  Future<void> pushProgress(List<LearningUnitProgress> units) async {
    if (units.isEmpty) return;
    await client.from('user_learning_unit_progress').upsert(
      units.map(_progressToSupabase).toList(),
      onConflict: 'user_id,unit_id',
    );
  }

  @override
  Future<void> pushCards(List<SrsCard> cards) async {
    if (cards.isEmpty) return;
    await client.from('user_srs_cards').upsert(
      cards.map(_cardToSupabase).toList(),
      onConflict: 'user_id,card_id',
    );
  }

  @override
  Future<void> pushReviewLogs(List<SrsReviewLog> logs) async {
    final pushable = logs.where((log) => log.clientReviewId != null).toList();
    if (pushable.isEmpty) return;
    await client.from('user_srs_review_logs').upsert(
      pushable.map(_logToSupabase).toList(),
      onConflict: 'user_id,client_review_id',
    );
  }

  @override
  Future<void> updateStatus(String status, String? error) async {
    await client.from('user_sync_state').upsert({
      'user_id': _userId,
      'sync_status': status,
      'last_error': error,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Map<String, dynamic> _progressToSupabase(LearningUnitProgress progress) {
    return {
      'user_id': _userId,
      'unit_id': progress.unitId,
      'unit_kind': progress.unitKind.name,
      'stage_id': progress.stageId,
      'module_id': progress.moduleId,
      'status': progress.status.name,
      'score': progress.score,
      'best_score': progress.score,
      'last_score': progress.score,
      'started_at': _date(progress.startedAt),
      'completed_at': _date(progress.completedAt),
      'last_opened_at': _date(progress.lastOpenedAt),
      'local_updated_at': _date(progress.updatedAt ?? DateTime.now()),
    };
  }

  Map<String, dynamic> _cardToSupabase(SrsCard card) {
    return {
      'user_id': _userId,
      'card_id': card.id,
      'target_type': card.targetType,
      'target_id': card.targetId,
      'card_type': card.cardType,
      'state': _cardStateToSupabase(card.state),
      'due_at': _date(card.dueAt),
      'stability': card.stability,
      'difficulty': card.difficulty,
      'elapsed_days': card.elapsedDays,
      'scheduled_days': card.scheduledDays,
      'reps': card.reps,
      'lapses': card.lapses,
      'last_reviewed_at': _date(card.lastReviewedAt),
      'local_updated_at': _date(card.updatedAt ?? DateTime.now()),
    };
  }

  Map<String, dynamic> _logToSupabase(SrsReviewLog log) {
    final parts = log.cardId.split(':');
    return {
      'user_id': _userId,
      'client_review_id': log.clientReviewId,
      'card_id': log.cardId,
      'target_type': parts.isNotEmpty ? parts[0] : null,
      'target_id': parts.length > 1 ? parts[1] : null,
      'card_type': parts.length > 2 ? parts[2] : null,
      'rating': log.rating.index + 1,
      'elapsed_days': 0,
      'scheduled_days': 0,
      'reviewed_at': _date(log.reviewedAt),
      'algorithm': log.algorithm,
      'stability_before': log.stabilityBefore,
      'difficulty_before': log.difficultyBefore,
      'stability_after': log.stabilityAfter,
      'difficulty_after': log.difficultyAfter,
      'local_created_at': _date(log.reviewedAt),
    };
  }
}

LearningUnitProgress _progressFromSupabase(Map<String, dynamic> row) {
  return LearningUnitProgress(
    unitId: row['unit_id'] as String,
    unitKind: LearningUnitKind.values.byName(row['unit_kind'] as String),
    stageId: row['stage_id'] as String,
    moduleId: row['module_id'] as String,
    status: LearningUnitStatus.values.byName(row['status'] as String),
    score: row['score'] as int?,
    startedAt: _parseDate(row['started_at']),
    completedAt: _parseDate(row['completed_at']),
    lastOpenedAt: _parseDate(row['last_opened_at']),
    updatedAt: _parseDate(
      row['server_updated_at'] ?? row['local_updated_at'] ?? row['updated_at'],
    ),
    syncPending: false,
  );
}

SrsCard _cardFromSupabase(Map<String, dynamic> row) {
  return SrsCard(
    id: row['card_id'] as String,
    targetType: row['target_type'] as String,
    targetId: row['target_id'] as String,
    cardType: row['card_type'] as String,
    state: _cardStateFromSupabase(row['state'] as String),
    dueAt: _parseDate(row['due_at']),
    stability: (row['stability'] as num?)?.toDouble(),
    difficulty: (row['difficulty'] as num?)?.toDouble(),
    elapsedDays: row['elapsed_days'] as int? ?? 0,
    scheduledDays: row['scheduled_days'] as int? ?? 0,
    reps: row['reps'] as int? ?? 0,
    lapses: row['lapses'] as int? ?? 0,
    lastReviewedAt: _parseDate(row['last_reviewed_at']),
    updatedAt: _parseDate(row['server_updated_at'] ?? row['local_updated_at']),
    syncPending: false,
  );
}

SrsReviewLog _logFromSupabase(Map<String, dynamic> row) {
  return SrsReviewLog(
    cardId: row['card_id'] as String,
    rating: SrsRating.values[(row['rating'] as int) - 1],
    reviewedAt: _parseDate(row['reviewed_at'])!,
    algorithm: row['algorithm'] as String,
    clientReviewId: row['client_review_id'] as String?,
    stabilityBefore: (row['stability_before'] as num?)?.toDouble(),
    difficultyBefore: (row['difficulty_before'] as num?)?.toDouble(),
    stabilityAfter: (row['stability_after'] as num?)?.toDouble(),
    difficultyAfter: (row['difficulty_after'] as num?)?.toDouble(),
  );
}

String? _date(DateTime? value) => value?.toUtc().toIso8601String();

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}

String _cardStateToSupabase(SrsCardState state) {
  switch (state) {
    case SrsCardState.newCard:
      return 'new';
    case SrsCardState.learning:
      return 'learning';
    case SrsCardState.review:
      return 'review';
    case SrsCardState.relearning:
      return 'relearning';
    case SrsCardState.suspended:
      return 'suspended';
    case SrsCardState.buried:
      return 'buried';
  }
}

SrsCardState _cardStateFromSupabase(String state) {
  if (state == 'new') return SrsCardState.newCard;
  return SrsCardState.values.byName(state);
}
