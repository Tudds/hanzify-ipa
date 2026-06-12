import 'dart:math' as math;

import '../domain/fsrs.dart';

class LearningSession {
  const LearningSession({required this.reviewCards, required this.newCards});

  final List<SrsCard> reviewCards;
  final List<SrsCard> newCards;

  List<SrsCard> get cards {
    final result = <SrsCard>[];
    final review = List<SrsCard>.from(reviewCards);
    final fresh = List<SrsCard>.from(newCards);
    while (review.isNotEmpty || fresh.isNotEmpty) {
      if (review.isNotEmpty) result.add(review.removeAt(0));
      if (review.isNotEmpty) result.add(review.removeAt(0));
      if (fresh.isNotEmpty) result.add(fresh.removeAt(0));
    }
    return result;
  }
}

class SessionBuilder {
  const SessionBuilder({this.sessionSize = 20, this.reviewRatio = 0.7});

  final int sessionSize;
  final double reviewRatio;

  bool shouldPauseNewLessons(int dueReviewCount) =>
      dueReviewCount > sessionSize * 2;

  LearningSession build({
    required List<SrsCard> dueCards,
    required List<SrsCard> newCards,
  }) {
    final pauseNew = shouldPauseNewLessons(dueCards.length);
    var reviewCount = pauseNew
        ? sessionSize
        : (sessionSize * reviewRatio).floor();
    var newCount = pauseNew ? 0 : sessionSize - reviewCount;
    // Backfill: nguồn nào thiếu thẻ thì nhường quota cho nguồn còn lại,
    // để phiên luôn đầy khi tổng thẻ có sẵn còn đủ (ví dụ review-only).
    if (newCards.length < newCount) {
      reviewCount += newCount - newCards.length;
      newCount = newCards.length;
    }
    if (dueCards.length < reviewCount) {
      newCount = math.min(
        newCards.length,
        newCount + reviewCount - dueCards.length,
      );
    }
    return LearningSession(
      reviewCards: dueCards.take(reviewCount).toList(),
      newCards: newCards.take(newCount).toList(),
    );
  }
}
