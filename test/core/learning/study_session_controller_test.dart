import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/fsrs.dart';
import 'package:hanzify/core/learning/quiz_generator.dart';
import 'package:hanzify/core/learning/study_session_controller.dart';

void main() {
  const quiz = LearningQuiz(
    id: 'q1',
    type: QuizType.vocabRecognition,
    prompt: '我学习中文。',
    answer: 'Tôi học tiếng Trung.',
    choices: ['Hôm nay rất nóng.', 'Tôi học tiếng Trung.'],
    sourceCollocationId: 'c1',
    targetId: 'hsk2_中文',
  );

  test('correct answer creates vocab recognition card with good rating', () {
    final controller = StudySessionController(
      clock: () => DateTime.utc(2026, 1, 1),
    );

    final result = controller.answer(quiz, 'Tôi học tiếng Trung.');
    final snapshot = controller.snapshot();

    expect(result.isCorrect, isTrue);
    expect(result.rating, SrsRating.good);
    expect(snapshot.cards.length, 1);
    expect(snapshot.logs.length, 1);
    expect(snapshot.cards.keys.single, 'vocab:hsk2_中文:recognition');
    expect(snapshot.cards.values.single.reps, 1);
  });

  test('wrong answer logs again rating and keeps same card id', () {
    final controller = StudySessionController(
      clock: () => DateTime.utc(2026, 1, 1),
    );

    final result = controller.answer(quiz, 'Hôm nay rất nóng.');
    final snapshot = controller.snapshot();

    expect(result.isCorrect, isFalse);
    expect(result.rating, SrsRating.again);
    expect(snapshot.cards.keys.single, 'vocab:hsk2_中文:recognition');
    expect(snapshot.logs.single.rating, SrsRating.again);
  });
}
