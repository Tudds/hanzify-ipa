import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database_stub.dart'
    if (dart.library.io) '../database/app_database.dart';
import '../providers/auth_provider.dart';

class SyncService {
  final AppDatabase _db;
  SyncService(this._db);

  // ==========================================================================
  // VOCAB SYNC
  // ==========================================================================

  /// Push all locally modified vocab SRS data to Supabase.
  /// Marks pushed rows as needsSync=false on success.
  Future<void> pushVocabChanges(String userId) async {
    final rows = await (_db.select(_db.vocabsTable)
          ..where((t) => t.needsSync.equals(true)))
        .get();

    if (rows.isEmpty) return;

    final data = rows.map((r) => {
          'user_id': userId,
          'vocab_id': r.id,
          'repetitions': r.repetitions,
          'ease_factor': r.easeFactor,
          'interval': r.interval,
          'next_review': r.nextReview.toUtc().toIso8601String(),
          'is_bookmarked': r.isBookmarked,
          'is_mastered': r.isMastered,
          'updated_at': r.updatedAt.toUtc().toIso8601String(),
        }).toList();

    await supabase
        .from('user_vocab_progress')
        .upsert(data, onConflict: 'user_id,vocab_id');

    final ids = rows.map((r) => r.id).toList();
    await (_db.update(_db.vocabsTable)
          ..where((t) => t.id.isIn(ids)))
        .write(const VocabsTableCompanion(needsSync: Value(false)));

    debugPrint('[Sync] Pushed ${rows.length} vocab changes');
  }

  /// Pull remote vocab SRS progress and apply using Last-Write-Wins.
  /// Compares updated_at timestamps to determine which version is newer.
  Future<void> pullVocabProgress(String userId) async {
    final remote = await supabase
        .from('user_vocab_progress')
        .select()
        .eq('user_id', userId);

    int applied = 0;
    int skipped = 0;

    for (final row in remote as List<dynamic>) {
      final vocabId = row['vocab_id'] as String;

      final local = await (_db.select(_db.vocabsTable)
            ..where((t) => t.id.equals(vocabId)))
          .getSingleOrNull();

      if (local == null) continue;

      final remoteUpdatedAt = row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0);
      final localUpdatedAt = local.updatedAt;

      // Last-Write-Wins: nếu local có pending changes VÀ mới hơn → skip
      if (local.needsSync && localUpdatedAt.isAfter(remoteUpdatedAt)) {
        skipped++;
        continue;
      }

      // Remote mới hơn hoặc local không có pending changes → apply remote
      final nextReview = row['next_review'] != null
          ? DateTime.parse(row['next_review'] as String).toLocal()
          : local.nextReview;

      await (_db.update(_db.vocabsTable)
            ..where((t) => t.id.equals(vocabId)))
          .write(VocabsTableCompanion(
            repetitions: Value(row['repetitions'] as int? ?? local.repetitions),
            easeFactor: Value(
                (row['ease_factor'] as num?)?.toDouble() ?? local.easeFactor),
            interval: Value(row['interval'] as int? ?? local.interval),
            nextReview: Value(nextReview),
            isBookmarked:
                Value(row['is_bookmarked'] as bool? ?? local.isBookmarked),
            isMastered: Value(row['is_mastered'] as bool? ?? local.isMastered),
            updatedAt: Value(remoteUpdatedAt),
            needsSync: const Value(false),
          ));
      applied++;
    }

    debugPrint('[Sync] Pulled vocab: $applied applied, $skipped skipped (local wins)');
  }

  // ==========================================================================
  // GRAMMAR SYNC
  // ==========================================================================

  /// Push locally modified grammar bookmark/mastered to Supabase.
  Future<void> pushGrammarChanges(String userId) async {
    final rows = await (_db.select(_db.grammarPointsTable)
          ..where((t) => t.needsSync.equals(true)))
        .get();

    if (rows.isEmpty) return;

    final data = rows.map((r) => {
          'user_id': userId,
          'grammar_id': r.id,
          'is_bookmarked': r.isBookmarked,
          'is_mastered': r.isMastered,
          'updated_at': r.updatedAt.toUtc().toIso8601String(),
        }).toList();

    await supabase
        .from('user_grammar_progress')
        .upsert(data, onConflict: 'user_id,grammar_id');

    final ids = rows.map((r) => r.id).toList();

    // Cần update từng row vì GrammarPointsTable không có API batch write
    // đơn giản như VocabsTable — dùng raw SQL
    for (final id in ids) {
      await (_db.update(_db.grammarPointsTable)
            ..where((t) => t.id.equals(id)))
          .write(const GrammarPointsTableCompanion(
            needsSync: Value(false),
          ));
    }

    debugPrint('[Sync] Pushed ${rows.length} grammar changes');
  }

  /// Pull remote grammar progress and apply using Last-Write-Wins.
  Future<void> pullGrammarProgress(String userId) async {
    final remote = await supabase
        .from('user_grammar_progress')
        .select()
        .eq('user_id', userId);

    int applied = 0;
    int skipped = 0;

    for (final row in remote as List<dynamic>) {
      final grammarId = row['grammar_id'] as String;

      final local = await (_db.select(_db.grammarPointsTable)
            ..where((t) => t.id.equals(grammarId)))
          .getSingleOrNull();

      if (local == null) continue;

      final remoteUpdatedAt = row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0);
      final localUpdatedAt = local.updatedAt;

      // Last-Write-Wins: nếu local có pending changes VÀ mới hơn → skip
      if (local.needsSync && localUpdatedAt.isAfter(remoteUpdatedAt)) {
        skipped++;
        continue;
      }

      // Remote mới hơn → apply
      await (_db.update(_db.grammarPointsTable)
            ..where((t) => t.id.equals(grammarId)))
          .write(GrammarPointsTableCompanion(
            isBookmarked:
                Value(row['is_bookmarked'] as bool? ?? local.isBookmarked),
            isMastered: Value(row['is_mastered'] as bool? ?? local.isMastered),
            updatedAt: Value(remoteUpdatedAt),
            needsSync: const Value(false),
          ));
      applied++;
    }

    debugPrint('[Sync] Pulled grammar: $applied applied, $skipped skipped (local wins)');
  }

  // ==========================================================================
  // COMBINED SYNC (backward compatibility)
  // ==========================================================================

  /// Push all pending changes (vocab + grammar).
  Future<void> pushPendingChanges(String userId) async {
    await pushVocabChanges(userId);
    await pushGrammarChanges(userId);
  }

  /// Pull all remote progress (vocab + grammar).
  Future<void> pullUserProgress(String userId) async {
    await pullVocabProgress(userId);
    await pullGrammarProgress(userId);
  }
}
