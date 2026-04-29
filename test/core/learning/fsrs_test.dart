import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/fsrs.dart';
import 'package:hanzify/core/learning/session_builder.dart';

void main() {
  test('FSRS review updates scheduling fields and log', () {
    final scheduler = FsrsScheduler();
    final now = DateTime.utc(2026, 1, 1);
    const card = SrsCard(
      id: 'vocab:hsk2_中文:recognition',
      targetType: 'vocab',
      targetId: 'hsk2_中文',
      cardType: 'recognition',
      state: SrsCardState.newCard,
    );

    final result = scheduler.review(card, SrsRating.good, now);

    expect(result.card.state, SrsCardState.review);
    expect(result.card.dueAt, isNotNull);
    expect(result.card.dueAt!.isAfter(now), isTrue);
    expect(result.card.stability, greaterThan(0));
    expect(result.card.difficulty, inInclusiveRange(1, 10));
    expect(result.card.reps, 1);
    expect(result.log.algorithm, FsrsScheduler.algorithm);
    expect(result.log.stabilityAfter, result.card.stability);
  });

  test('due cards are sorted and suspended cards are excluded', () {
    final scheduler = FsrsScheduler();
    final now = DateTime.utc(2026, 1, 10);
    final due = scheduler.dueCards([
      SrsCard(
        id: 'b',
        targetType: 'vocab',
        targetId: 'b',
        cardType: 'recognition',
        state: SrsCardState.review,
        dueAt: DateTime.utc(2026, 1, 9),
      ),
      SrsCard(
        id: 'a',
        targetType: 'vocab',
        targetId: 'a',
        cardType: 'recognition',
        state: SrsCardState.review,
        dueAt: DateTime.utc(2026, 1, 8),
      ),
      SrsCard(
        id: 'c',
        targetType: 'vocab',
        targetId: 'c',
        cardType: 'recognition',
        state: SrsCardState.suspended,
        dueAt: DateTime.utc(2026, 1, 1),
      ),
    ], now);

    expect(due.map((card) => card.id), ['a', 'b']);
  });

  test(
    'session builder uses 70 percent review and pauses new lessons on review debt',
    () {
      final due = List.generate(
        50,
        (index) => SrsCard(
          id: 'due_$index',
          targetType: 'vocab',
          targetId: '$index',
          cardType: 'recognition',
          state: SrsCardState.review,
        ),
      );
      final fresh = List.generate(
        20,
        (index) => SrsCard(
          id: 'new_$index',
          targetType: 'vocab',
          targetId: '$index',
          cardType: 'recognition',
          state: SrsCardState.newCard,
        ),
      );

      const builder = SessionBuilder(sessionSize: 20);
      final reviewOnly = builder.build(dueCards: due, newCards: fresh);
      expect(reviewOnly.reviewCards.length, 20);
      expect(reviewOnly.newCards, isEmpty);

      final mixed = builder.build(
        dueCards: due.take(10).toList(),
        newCards: fresh,
      );
      expect(mixed.reviewCards.length, 10);
      expect(mixed.newCards.length, 6);
    },
  );
}
