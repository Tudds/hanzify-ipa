import '../constants/hsk_levels.dart';

enum LearningPriority {
  listening,
  vocabulary,
  conversation,
  writing;

  String get labelVi => switch (this) {
    listening => 'Nghe hiểu',
    vocabulary => 'Từ vựng',
    conversation => 'Hội thoại',
    writing => 'Viết & dịch',
  };

  static LearningPriority parse(String? raw) {
    return LearningPriority.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => LearningPriority.vocabulary,
    );
  }
}

class UserProfile {
  const UserProfile({
    this.activeLevel = 2,
    this.dailyMinutes = 10,
    this.priority = LearningPriority.vocabulary,
    this.onboardingComplete = false,
  });

  final int activeLevel;
  final int dailyMinutes;
  final LearningPriority priority;
  final bool onboardingComplete;

  /// Số thẻ mỗi phiên ôn tập, suy ra từ thời lượng học mỗi ngày.
  int get sessionSize => switch (dailyMinutes) {
    <= 5 => 10,
    <= 10 => 20,
    _ => 35,
  };

  UserProfile copyWith({
    int? activeLevel,
    int? dailyMinutes,
    LearningPriority? priority,
    bool? onboardingComplete,
  }) {
    return UserProfile(
      activeLevel: (activeLevel ?? this.activeLevel).clamp(
        kMinHskLevel,
        kMaxHskLevel,
      ),
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      priority: priority ?? this.priority,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfile &&
        other.activeLevel == activeLevel &&
        other.dailyMinutes == dailyMinutes &&
        other.priority == priority &&
        other.onboardingComplete == onboardingComplete;
  }

  @override
  int get hashCode =>
      Object.hash(activeLevel, dailyMinutes, priority, onboardingComplete);
}
