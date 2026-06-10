import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hsk_levels.dart';
import '../profile/user_profile.dart';
import 'shared_preferences_provider.dart';

class UserProfileNotifier extends Notifier<UserProfile> {
  static const _activeLevelKey = 'profile_active_level';
  static const _dailyMinutesKey = 'profile_daily_minutes';
  static const _priorityKey = 'profile_priority';
  static const _onboardingCompleteKey = 'profile_onboarding_complete';

  @override
  UserProfile build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return UserProfile(
      activeLevel: (prefs.getInt(_activeLevelKey) ?? 2).clamp(
        kMinHskLevel,
        kMaxHskLevel,
      ),
      dailyMinutes: prefs.getInt(_dailyMinutesKey) ?? 10,
      priority: LearningPriority.parse(prefs.getString(_priorityKey)),
      onboardingComplete: prefs.getBool(_onboardingCompleteKey) ?? false,
    );
  }

  void setActiveLevel(int level) {
    state = state.copyWith(activeLevel: level);
    _persist();
  }

  void setDailyMinutes(int minutes) {
    state = state.copyWith(dailyMinutes: minutes);
    _persist();
  }

  void setPriority(LearningPriority priority) {
    state = state.copyWith(priority: priority);
    _persist();
  }

  void completeOnboarding({
    required int activeLevel,
    required int dailyMinutes,
    required LearningPriority priority,
  }) {
    state = state.copyWith(
      activeLevel: activeLevel,
      dailyMinutes: dailyMinutes,
      priority: priority,
      onboardingComplete: true,
    );
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    unawaited(prefs.setInt(_activeLevelKey, state.activeLevel));
    unawaited(prefs.setInt(_dailyMinutesKey, state.dailyMinutes));
    unawaited(prefs.setString(_priorityKey, state.priority.name));
    unawaited(prefs.setBool(_onboardingCompleteKey, state.onboardingComplete));
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);
