import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../application/study_session_controller.dart';
import '../../domain/fsrs.dart';

class DriftStudySessionStore {
  const DriftStudySessionStore(this.database);

  final AppDatabase database;

  Future<StudySessionSnapshot> load() async {
    final cardsRows = await database.select(database.srsCardsTable).get();
    final logRows = await database.select(database.srsReviewLogsTable).get();
    final cards = <String, SrsCard>{};
    for (final row in cardsRows) {
      final card = SrsCard(
        id: row.id,
        targetType: row.targetType,
        targetId: row.targetId,
        cardType: row.cardType,
        state: SrsCardState.values.byName(row.state),
        dueAt: row.dueAt,
        stability: row.stability,
        difficulty: row.difficulty,
        elapsedDays: row.elapsedDays,
        scheduledDays: row.scheduledDays,
        reps: row.reps,
        lapses: row.lapses,
        lastReviewedAt: row.lastReviewedAt,
        updatedAt: row.updatedAt,
        syncPending: row.syncPending,
      );
      cards[card.id] = card;
    }
    final logs = logRows.map((row) {
      return SrsReviewLog(
        cardId: row.cardId,
        rating: SrsRating.values.byName(row.rating),
        reviewedAt: row.reviewedAt,
        algorithm: row.algorithm,
        clientReviewId: row.clientReviewId,
        stabilityBefore: row.stabilityBefore,
        difficultyBefore: row.difficultyBefore,
        stabilityAfter: row.stabilityAfter,
        difficultyAfter: row.difficultyAfter,
      );
    }).toList();
    return StudySessionSnapshot(
      cards: cards,
      logs: logs,
      reviewedCount: logs.length,
    );
  }

  Future<void> save(StudySessionSnapshot snapshot) async {
    final now = DateTime.now();
    await database.transaction(() async {
      await database.delete(database.srsReviewLogsTable).go();
      await database.delete(database.srsCardsTable).go();
      for (final card in snapshot.cards.values) {
        await database
            .into(database.srsCardsTable)
            .insert(
              SrsCardsTableCompanion.insert(
                id: card.id,
                targetType: card.targetType,
                targetId: card.targetId,
                cardType: card.cardType,
                state: card.state.name,
                dueAt: Value(card.dueAt),
                stability: Value(card.stability),
                difficulty: Value(card.difficulty),
                elapsedDays: Value(card.elapsedDays),
                scheduledDays: Value(card.scheduledDays),
                reps: Value(card.reps),
                lapses: Value(card.lapses),
                lastReviewedAt: Value(card.lastReviewedAt),
                updatedAt: Value(card.updatedAt ?? now),
                syncPending: Value(card.syncPending),
              ),
            );
      }
      for (final log in snapshot.logs) {
        await database
            .into(database.srsReviewLogsTable)
            .insert(
              SrsReviewLogsTableCompanion.insert(
                cardId: log.cardId,
                rating: log.rating.name,
                reviewedAt: log.reviewedAt,
                algorithm: log.algorithm,
                clientReviewId: Value(log.clientReviewId),
                stabilityBefore: Value(log.stabilityBefore),
                difficultyBefore: Value(log.difficultyBefore),
                stabilityAfter: Value(log.stabilityAfter),
                difficultyAfter: Value(log.difficultyAfter),
              ),
            );
      }
    });
  }

  Future<void> clear() async {
    await database.transaction(() async {
      await database.delete(database.srsReviewLogsTable).go();
      await database.delete(database.srsCardsTable).go();
    });
  }

  Future<void> markSynced({required Iterable<String> cardIds}) async {
    for (final id in cardIds) {
      await (database.update(database.srsCardsTable)
            ..where((table) => table.id.equals(id)))
          .write(const SrsCardsTableCompanion(syncPending: Value(false)));
    }
  }
}
