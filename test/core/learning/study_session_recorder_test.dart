import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/application/study_session_controller.dart';
import 'package:hanzify/core/learning/application/study_session_recorder.dart';
import 'package:hanzify/core/learning/domain/fsrs.dart';
import 'package:hanzify/core/learning/study_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<StudySessionStore> store() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return StudySessionStore(preferences: prefs);
  }

  test('record persists a card and reuses it on the next answer', () async {
    final recorder = StudySessionRecorder(store: await store());

    await recorder.record(
      targetType: 'vocab',
      targetId: 'hsk2_学习',
      rating: SrsRating.good,
    );
    await recorder.record(
      targetType: 'vocab',
      targetId: 'hsk2_学习',
      rating: SrsRating.good,
    );

    final snapshot = await StudySessionStore(
      preferences: await SharedPreferences.getInstance(),
    ).load();
    expect(snapshot.cards.keys.single, 'vocab:hsk2_学习:recognition');
    expect(snapshot.cards.values.single.reps, 2);
  });

  test('record load-merges so it never drops existing cards', () async {
    final sharedStore = await store();
    // Mô phỏng tab Ôn tập đã tạo sẵn một thẻ khác.
    await sharedStore.save(
      StudySessionSnapshot(
        cards: {
          'vocab:hsk1_茶:recognition': SrsCard(
            id: 'vocab:hsk1_茶:recognition',
            targetType: 'vocab',
            targetId: 'hsk1_茶',
            cardType: 'recognition',
            state: SrsCardState.review,
          ),
        },
        logs: const [],
        reviewedCount: 0,
      ),
    );

    await StudySessionRecorder(store: sharedStore).record(
      targetType: 'vocab',
      targetId: 'hsk2_学习',
      rating: SrsRating.good,
    );

    final snapshot = await sharedStore.load();
    expect(
      snapshot.cards.keys,
      containsAll(<String>{
        'vocab:hsk1_茶:recognition',
        'vocab:hsk2_学习:recognition',
      }),
    );
  });

  test('concurrent records are serialized and all land', () async {
    final recorder = StudySessionRecorder(store: await store());

    await Future.wait([
      for (var i = 0; i < 5; i++)
        recorder.record(
          targetType: 'vocab',
          targetId: 'hsk2_word$i',
          rating: SrsRating.good,
        ),
    ]);

    final snapshot = await StudySessionStore(
      preferences: await SharedPreferences.getInstance(),
    ).load();
    expect(snapshot.cards.length, 5);
  });
}
