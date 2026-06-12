import 'dart:math' as math;

enum SrsRating { again, hard, good, easy }

enum SrsCardState { newCard, learning, review, relearning, suspended, buried }

class SrsCard {
  const SrsCard({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.cardType,
    required this.state,
    this.dueAt,
    this.stability,
    this.difficulty,
    this.elapsedDays = 0,
    this.scheduledDays = 0,
    this.reps = 0,
    this.lapses = 0,
    this.lastReviewedAt,
    this.updatedAt,
    this.syncPending = true,
  });

  final String id;
  final String targetType;
  final String targetId;
  final String cardType;
  final SrsCardState state;
  final DateTime? dueAt;
  final double? stability;
  final double? difficulty;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final DateTime? lastReviewedAt;
  final DateTime? updatedAt;
  final bool syncPending;

  SrsCard copyWith({
    SrsCardState? state,
    DateTime? dueAt,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? scheduledDays,
    int? reps,
    int? lapses,
    DateTime? lastReviewedAt,
    DateTime? updatedAt,
    bool? syncPending,
  }) {
    return SrsCard(
      id: id,
      targetType: targetType,
      targetId: targetId,
      cardType: cardType,
      state: state ?? this.state,
      dueAt: dueAt ?? this.dueAt,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncPending: syncPending ?? this.syncPending,
    );
  }
}

class SrsReviewLog {
  const SrsReviewLog({
    required this.cardId,
    required this.rating,
    required this.reviewedAt,
    required this.algorithm,
    this.clientReviewId,
    this.stabilityBefore,
    this.difficultyBefore,
    this.stabilityAfter,
    this.difficultyAfter,
  });

  final String cardId;
  final SrsRating rating;
  final DateTime reviewedAt;
  final String algorithm;
  final String? clientReviewId;
  final double? stabilityBefore;
  final double? difficultyBefore;
  final double? stabilityAfter;
  final double? difficultyAfter;
}

class SrsReviewResult {
  const SrsReviewResult({required this.card, required this.log});

  final SrsCard card;
  final SrsReviewLog log;
}

class FsrsScheduler {
  const FsrsScheduler({this.requestRetention = 0.9});

  final double requestRetention;

  static const algorithm = 'fsrs_local_v1';
  static const _decay = -0.5;
  static const _factor = 19 / 81;
  static const _weights = <double>[
    0.4,
    1.2,
    3.0,
    5.8,
    4.93,
    0.94,
    0.86,
    0.01,
    1.49,
    0.14,
    0.94,
    2.18,
    0.05,
    0.34,
    1.26,
    0.29,
    2.61,
    0.57,
    0.24,
  ];

  SrsReviewResult review(SrsCard card, SrsRating rating, DateTime now) {
    final elapsedDays = _elapsedDays(card, now);
    final stabilityBefore = card.stability;
    final difficultyBefore = card.difficulty;
    final next = _nextCard(card, rating, now, elapsedDays);

    return SrsReviewResult(
      card: next,
      log: SrsReviewLog(
        cardId: card.id,
        rating: rating,
        reviewedAt: now,
        algorithm: algorithm,
        clientReviewId: '${card.id}:${now.microsecondsSinceEpoch}',
        stabilityBefore: stabilityBefore,
        difficultyBefore: difficultyBefore,
        stabilityAfter: next.stability,
        difficultyAfter: next.difficulty,
      ),
    );
  }

  List<SrsCard> dueCards(Iterable<SrsCard> cards, DateTime now) {
    final due = cards.where((card) {
      if (card.state == SrsCardState.suspended ||
          card.state == SrsCardState.buried) {
        return false;
      }
      return card.dueAt == null || !card.dueAt!.isAfter(now);
    }).toList();
    due.sort(
      (a, b) => (a.dueAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        b.dueAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    return due;
  }

  SrsCard _nextCard(
    SrsCard card,
    SrsRating rating,
    DateTime now,
    int elapsedDays,
  ) {
    final firstReview =
        card.reps == 0 || card.stability == null || card.difficulty == null;
    final nextDifficulty = firstReview
        ? _initDifficulty(rating)
        : _nextDifficulty(card.difficulty!, rating);
    final retrievability = firstReview
        ? 0.0
        : _forgettingCurve(elapsedDays, card.stability!);
    final nextStability = firstReview
        ? _initStability(rating)
        : rating == SrsRating.again
        ? _nextForgetStability(
            card.difficulty!,
            card.stability!,
            retrievability,
          )
        : _nextRecallStability(
            card.difficulty!,
            card.stability!,
            retrievability,
            rating,
          );
    final scheduledDays = _nextInterval(nextStability, rating);
    final nextState = _nextState(card.state, rating);

    return card.copyWith(
      state: nextState,
      dueAt: now.add(Duration(days: scheduledDays)),
      stability: _clamp(nextStability, 0.1, 36500),
      difficulty: _clamp(nextDifficulty, 1, 10),
      elapsedDays: elapsedDays,
      scheduledDays: scheduledDays,
      reps: card.reps + 1,
      lapses: card.lapses + (rating == SrsRating.again && !firstReview ? 1 : 0),
      lastReviewedAt: now,
    );
  }

  int _elapsedDays(SrsCard card, DateTime now) {
    final last = card.lastReviewedAt;
    if (last == null) return 0;
    return math.max(0, now.difference(last).inDays);
  }

  double _initStability(SrsRating rating) => _weights[rating.index];

  double _initDifficulty(SrsRating rating) {
    // FSRS v4: D0(G) = w4 − (G − 3)·w5 với G = rating.index + 1 (1..4).
    // Bộ _weights ở trên là tham số v4 nên phải dùng dạng tuyến tính này;
    // dạng mũ của FSRS-4.5 với weights v4 sẽ làm Good/Easy bị clamp về 1.0.
    return _clamp(_weights[4] - (rating.index - 2) * _weights[5], 1, 10);
  }

  double _forgettingCurve(int elapsedDays, double stability) {
    return math.pow(1 + _factor * elapsedDays / stability, _decay).toDouble();
  }

  double _nextDifficulty(double difficulty, SrsRating rating) {
    final delta = _weights[6] * (rating.index - 2);
    final next = difficulty - delta;
    final easyMean = _initDifficulty(SrsRating.easy);
    return _clamp(_weights[7] * easyMean + (1 - _weights[7]) * next, 1, 10);
  }

  double _nextRecallStability(
    double difficulty,
    double stability,
    double retrievability,
    SrsRating rating,
  ) {
    final hardPenalty = rating == SrsRating.hard ? _weights[15] : 1.0;
    final easyBonus = rating == SrsRating.easy ? _weights[16] : 1.0;
    final growth =
        math.exp(_weights[8]) *
        (11 - difficulty) *
        math.pow(stability, -_weights[9]) *
        (math.exp((1 - retrievability) * _weights[10]) - 1) *
        hardPenalty *
        easyBonus;
    return stability * (1 + growth);
  }

  double _nextForgetStability(
    double difficulty,
    double stability,
    double retrievability,
  ) {
    return _weights[11] *
        math.pow(difficulty, -_weights[12]) *
        (math.pow(stability + 1, _weights[13]) - 1) *
        math.exp((1 - retrievability) * _weights[14]);
  }

  int _nextInterval(double stability, SrsRating rating) {
    if (rating == SrsRating.again) return 0;
    final interval =
        stability / _factor * (math.pow(requestRetention, 1 / _decay) - 1);
    return _clamp(interval.roundToDouble(), 1, 36500).toInt();
  }

  SrsCardState _nextState(SrsCardState state, SrsRating rating) {
    if (rating == SrsRating.again) {
      return state == SrsCardState.review
          ? SrsCardState.relearning
          : SrsCardState.learning;
    }
    return SrsCardState.review;
  }

  double _clamp(double value, double min, double max) =>
      math.min(max, math.max(min, value));
}
