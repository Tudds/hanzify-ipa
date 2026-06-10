enum LearningUnitKind { lesson, checkpoint }

enum LearningUnitStatus { locked, available, started, completed, retry }

class LearningUnitProgress {
  const LearningUnitProgress({
    required this.unitId,
    required this.unitKind,
    required this.stageId,
    required this.moduleId,
    required this.status,
    this.score,
    this.startedAt,
    this.completedAt,
    this.lastOpenedAt,
    this.updatedAt,
    this.syncPending = true,
  });

  factory LearningUnitProgress.fromJson(Map<String, dynamic> json) {
    return LearningUnitProgress(
      unitId: json['unitId'] as String,
      unitKind: LearningUnitKind.values.byName(json['unitKind'] as String),
      stageId: json['stageId'] as String,
      moduleId: json['moduleId'] as String,
      status: LearningUnitStatus.values.byName(json['status'] as String),
      score: json['score'] as int?,
      startedAt: _date(json['startedAt']),
      completedAt: _date(json['completedAt']),
      lastOpenedAt: _date(json['lastOpenedAt']),
      updatedAt: _date(json['updatedAt']),
      syncPending: json['syncPending'] as bool? ?? true,
    );
  }

  final String unitId;
  final LearningUnitKind unitKind;
  final String stageId;
  final String moduleId;
  final LearningUnitStatus status;
  final int? score;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastOpenedAt;
  final DateTime? updatedAt;
  final bool syncPending;

  Map<String, dynamic> toJson() {
    return {
      'unitId': unitId,
      'unitKind': unitKind.name,
      'stageId': stageId,
      'moduleId': moduleId,
      'status': status.name,
      'score': score,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncPending': syncPending,
    };
  }

  LearningUnitProgress copyWith({
    LearningUnitStatus? status,
    int? score,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastOpenedAt,
    DateTime? updatedAt,
    bool? syncPending,
  }) {
    return LearningUnitProgress(
      unitId: unitId,
      unitKind: unitKind,
      stageId: stageId,
      moduleId: moduleId,
      status: status ?? this.status,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncPending: syncPending ?? this.syncPending,
    );
  }
}

class LearningProgressSnapshot {
  const LearningProgressSnapshot({required this.units});

  final Map<String, LearningUnitProgress> units;

  LearningUnitProgress? unit(String unitId) => units[unitId];
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}
