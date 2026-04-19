import 'package:drift/drift.dart';

import '../database/app_database_stub.dart'
    if (dart.library.io) '../database/app_database.dart';
import '../providers/auth_provider.dart';

class SyncService {
  final AppDatabase _db;
  SyncService(this._db);

  /// Push all locally modified vocab SRS data to Supabase.
  /// Marks pushed rows as needsSync=false on success.
  Future<void> pushPendingChanges(String userId) async {
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
        }).toList();

    await supabase
        .from('user_vocab_progress')
        .upsert(data, onConflict: 'user_id,vocab_id');

    final ids = rows.map((r) => r.id).toList();
    await (_db.update(_db.vocabsTable)
          ..where((t) => t.id.isIn(ids)))
        .write(const VocabsTableCompanion(needsSync: Value(false)));
  }

  /// Pull remote SRS progress and apply to local rows where there are no
  /// pending local changes (needsSync=false). Local wins on conflict.
  Future<void> pullUserProgress(String userId) async {
    final remote = await supabase
        .from('user_vocab_progress')
        .select()
        .eq('user_id', userId);

    for (final row in remote as List<dynamic>) {
      final vocabId = row['vocab_id'] as String;

      // Only apply if local row exists AND has no pending local change
      final local = await (_db.select(_db.vocabsTable)
            ..where((t) => t.id.equals(vocabId) & t.needsSync.equals(false)))
          .getSingleOrNull();

      if (local == null) continue;

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
            needsSync: const Value(false),
          ));
    }
  }
}
