import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/domain/fsrs.dart';

/// Pin giá trị tham chiếu của FSRS v4 (weights mặc định, retention 0.9).
/// Đây là regression guard: nếu ai đổi công thức/weights, các giá trị này
/// phải được tính lại CÓ CHỦ ĐÍCH chứ không trôi âm thầm.
void main() {
  const scheduler = FsrsScheduler();
  final now = DateTime(2026, 1, 1);

  SrsCard newCard(String id) => SrsCard(
    id: id,
    targetType: 'vocab',
    targetId: id,
    cardType: 'recognition',
    state: SrsCardState.newCard,
  );

  test('first review: initial stability = w[0..3] per rating', () {
    final expected = {
      SrsRating.again: 0.4,
      SrsRating.hard: 1.2,
      SrsRating.good: 3.0,
      SrsRating.easy: 5.8,
    };
    for (final entry in expected.entries) {
      final result = scheduler.review(newCard('s'), entry.key, now);
      expect(
        result.card.stability,
        closeTo(entry.value, 1e-9),
        reason: 'stability for ${entry.key.name}',
      );
    }
  });

  test('first review: initial difficulty follows FSRS v4 linear D0', () {
    // D0(G) = w4 − (G − 3)·w5 = 4.93 − (rating.index − 2)·0.94
    final expected = {
      SrsRating.again: 6.81,
      SrsRating.hard: 5.87,
      SrsRating.good: 4.93,
      SrsRating.easy: 3.99,
    };
    for (final entry in expected.entries) {
      final result = scheduler.review(newCard('d'), entry.key, now);
      expect(
        result.card.difficulty,
        closeTo(entry.value, 1e-9),
        reason: 'difficulty for ${entry.key.name}',
      );
    }
  });

  test('interval at retention 0.9 equals stability (FSRS factor design)', () {
    // factor = 19/81 và decay = −0.5 được chọn để interval = S khi R = 0.9.
    final good = scheduler.review(newCard('i'), SrsRating.good, now);
    expect(good.card.scheduledDays, 3); // S = 3.0
    final easy = scheduler.review(newCard('i2'), SrsRating.easy, now);
    expect(easy.card.scheduledDays, 6); // round(5.8)
    final again = scheduler.review(newCard('i3'), SrsRating.again, now);
    expect(again.card.scheduledDays, 0); // học lại ngay trong phiên
  });

  test('lower request retention stretches intervals', () {
    const relaxed = FsrsScheduler(requestRetention: 0.8);
    final good = relaxed.review(newCard('r'), SrsRating.good, now);
    expect(good.card.scheduledDays, 7); // so với 3 ngày ở retention 0.9
  });

  test('Good → Good → Again sequence: stability, states and lapses', () {
    // Review đúng hạn (đúng ngày due) → R = 0.9 đúng bằng thiết kế.
    final first = scheduler.review(newCard('seq'), SrsRating.good, now).card;
    expect(first.state, SrsCardState.review);

    final second = scheduler
        .review(first, SrsRating.good, now.add(const Duration(days: 3)))
        .card;
    expect(second.stability, closeTo(9.828280030507877, 1e-6));
    expect(second.difficulty, closeTo(4.9206, 1e-6));
    expect(second.scheduledDays, 10);

    final lapsed = scheduler
        .review(second, SrsRating.again, now.add(const Duration(days: 13)))
        .card;
    expect(lapsed.state, SrsCardState.relearning);
    expect(lapsed.lapses, 1);
    expect(lapsed.scheduledDays, 0);
    expect(lapsed.stability, closeTo(2.8544582315910563, 1e-6));
    // Quên làm stability giảm mạnh nhưng không về 0.
    expect(lapsed.stability, lessThan(second.stability!));
    expect(lapsed.stability, greaterThan(0));
  });

  test('again on a new card goes to learning without counting a lapse', () {
    final result = scheduler.review(newCard('l'), SrsRating.again, now);
    expect(result.card.state, SrsCardState.learning);
    expect(result.card.lapses, 0);
  });
}
