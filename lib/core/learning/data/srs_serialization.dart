import '../domain/fsrs.dart';

extension SrsCardJson on SrsCard {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetType': targetType,
      'targetId': targetId,
      'cardType': cardType,
      'state': state.name,
      'dueAt': dueAt?.toIso8601String(),
      'stability': stability,
      'difficulty': difficulty,
      'elapsedDays': elapsedDays,
      'scheduledDays': scheduledDays,
      'reps': reps,
      'lapses': lapses,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncPending': syncPending,
    };
  }

  static SrsCard fromJson(Map<String, dynamic> json) {
    return SrsCard(
      id: json['id'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      cardType: json['cardType'] as String,
      state: SrsCardState.values.byName(json['state'] as String),
      dueAt: _date(json['dueAt']),
      stability: (json['stability'] as num?)?.toDouble(),
      difficulty: (json['difficulty'] as num?)?.toDouble(),
      elapsedDays: json['elapsedDays'] as int? ?? 0,
      scheduledDays: json['scheduledDays'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      lapses: json['lapses'] as int? ?? 0,
      lastReviewedAt: _date(json['lastReviewedAt']),
      updatedAt: _date(json['updatedAt']),
      syncPending: json['syncPending'] as bool? ?? true,
    );
  }
}

extension SrsReviewLogJson on SrsReviewLog {
  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'rating': rating.name,
      'reviewedAt': reviewedAt.toIso8601String(),
      'algorithm': algorithm,
      'clientReviewId': clientReviewId,
      'stabilityBefore': stabilityBefore,
      'difficultyBefore': difficultyBefore,
      'stabilityAfter': stabilityAfter,
      'difficultyAfter': difficultyAfter,
    };
  }

  static SrsReviewLog fromJson(Map<String, dynamic> json) {
    return SrsReviewLog(
      cardId: json['cardId'] as String,
      rating: SrsRating.values.byName(json['rating'] as String),
      reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      algorithm: json['algorithm'] as String,
      clientReviewId: json['clientReviewId'] as String?,
      stabilityBefore: (json['stabilityBefore'] as num?)?.toDouble(),
      difficultyBefore: (json['difficultyBefore'] as num?)?.toDouble(),
      stabilityAfter: (json['stabilityAfter'] as num?)?.toDouble(),
      difficultyAfter: (json['difficultyAfter'] as num?)?.toDouble(),
    );
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}
