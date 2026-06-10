import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../learning_progress.dart';

class DriftLearningProgressStore {
  const DriftLearningProgressStore(this.database);

  final AppDatabase database;

  Future<LearningProgressSnapshot> load() async {
    final rows = await database
        .select(database.learningUnitProgressTable)
        .get();
    final units = <String, LearningUnitProgress>{};
    for (final row in rows) {
      final progress = LearningUnitProgress(
        unitId: row.unitId,
        unitKind: LearningUnitKind.values.byName(row.unitKind),
        stageId: row.stageId,
        moduleId: row.moduleId,
        status: LearningUnitStatus.values.byName(row.status),
        score: row.score,
        startedAt: row.startedAt,
        completedAt: row.completedAt,
        lastOpenedAt: row.lastOpenedAt,
        updatedAt: row.updatedAt,
        syncPending: row.syncPending,
      );
      units[progress.unitId] = progress;
    }
    return LearningProgressSnapshot(units: units);
  }

  Future<void> save(LearningProgressSnapshot snapshot) async {
    await database.transaction(() async {
      await database.delete(database.learningUnitProgressTable).go();
      for (final progress in snapshot.units.values) {
        await upsert(progress);
      }
    });
  }

  Future<void> upsert(LearningUnitProgress progress) async {
    final now = DateTime.now();
    await database
        .into(database.learningUnitProgressTable)
        .insertOnConflictUpdate(
          LearningUnitProgressTableCompanion.insert(
            unitId: progress.unitId,
            unitKind: progress.unitKind.name,
            stageId: progress.stageId,
            moduleId: progress.moduleId,
            status: progress.status.name,
            score: Value(progress.score),
            startedAt: Value(progress.startedAt),
            completedAt: Value(progress.completedAt),
            lastOpenedAt: Value(progress.lastOpenedAt),
            updatedAt: Value(progress.updatedAt ?? now),
            syncPending: Value(progress.syncPending),
          ),
        );
  }

  Future<void> markSynced({required Iterable<String> unitIds}) async {
    for (final unitId in unitIds) {
      await (database.update(database.learningUnitProgressTable)
            ..where((table) => table.unitId.equals(unitId)))
          .write(
            const LearningUnitProgressTableCompanion(syncPending: Value(false)),
          );
    }
  }

  Future<void> clear() async {
    await database.delete(database.learningUnitProgressTable).go();
  }
}
