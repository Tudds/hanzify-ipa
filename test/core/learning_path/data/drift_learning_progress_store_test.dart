import 'dart:ffi';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/database/app_database.dart';
import 'package:hanzify/core/learning_path/data/drift/drift_learning_progress_store.dart';
import 'package:hanzify/core/learning_path/learning_progress.dart';

void main() {
  final sqliteAvailable = _sqliteAvailable();
  late AppDatabase database;
  late DriftLearningProgressStore store;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    store = DriftLearningProgressStore(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'upserts and loads learning unit progress',
    () async {
      final openedAt = DateTime(2026, 4, 27, 9);
      await store.upsert(
        LearningUnitProgress(
          unitId: 'hsk1_lesson_001',
          unitKind: LearningUnitKind.lesson,
          stageId: 'hsk1',
          moduleId: 'greeting',
          status: LearningUnitStatus.completed,
          score: 95,
          startedAt: openedAt.subtract(const Duration(minutes: 5)),
          completedAt: openedAt,
          lastOpenedAt: openedAt,
        ),
      );

      final loaded = await store.load();

      expect(loaded.units, hasLength(1));
      expect(
        loaded.units['hsk1_lesson_001']?.status,
        LearningUnitStatus.completed,
      );
      expect(loaded.units['hsk1_lesson_001']?.score, 95);
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
