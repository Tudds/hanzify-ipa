import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning_path/learning_progress.dart';
import 'package:hanzify/core/learning_path/learning_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('learning progress store saves and loads unit progress', () async {
    SharedPreferences.setMockInitialValues({});
    const store = LearningProgressStore();
    final now = DateTime.utc(2026, 1, 1);

    await store.upsert(
      LearningUnitProgress(
        unitId: 'H2-M1-L1',
        unitKind: LearningUnitKind.lesson,
        stageId: 'HSK2',
        moduleId: 'H2-M1',
        status: LearningUnitStatus.completed,
        score: 100,
        completedAt: now,
      ),
    );

    final loaded = await store.load();

    expect(loaded.unit('H2-M1-L1')?.status, LearningUnitStatus.completed);
    expect(loaded.unit('H2-M1-L1')?.score, 100);
  });
}
