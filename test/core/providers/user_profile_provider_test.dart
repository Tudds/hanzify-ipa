import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/profile/user_profile.dart';
import 'package:hanzify/core/providers/user_profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/profile_overrides.dart';

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
}) async {
  final container = ProviderContainer(
    overrides: await profileTestOverrides(prefs: prefs),
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to HSK2, 10 minutes, vocabulary, onboarding incomplete', () async {
    final container = await _container();
    final profile = container.read(userProfileProvider);

    expect(profile.activeLevel, 2);
    expect(profile.dailyMinutes, 10);
    expect(profile.priority, LearningPriority.vocabulary);
    expect(profile.onboardingComplete, isFalse);
    expect(profile.sessionSize, 20);
  });

  test('reads persisted profile values', () async {
    final container = await _container(
      prefs: {
        'profile_active_level': 3,
        'profile_daily_minutes': 5,
        'profile_priority': 'listening',
        'profile_onboarding_complete': true,
      },
    );
    final profile = container.read(userProfileProvider);

    expect(profile.activeLevel, 3);
    expect(profile.dailyMinutes, 5);
    expect(profile.priority, LearningPriority.listening);
    expect(profile.onboardingComplete, isTrue);
    expect(profile.sessionSize, 10);
  });

  test('completeOnboarding persists choices and flips flag', () async {
    final container = await _container();
    container
        .read(userProfileProvider.notifier)
        .completeOnboarding(
          activeLevel: 3,
          dailyMinutes: 20,
          priority: LearningPriority.writing,
        );

    final profile = container.read(userProfileProvider);
    expect(profile.activeLevel, 3);
    expect(profile.dailyMinutes, 20);
    expect(profile.priority, LearningPriority.writing);
    expect(profile.onboardingComplete, isTrue);
    expect(profile.sessionSize, 35);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('profile_active_level'), 3);
    expect(prefs.getInt('profile_daily_minutes'), 20);
    expect(prefs.getString('profile_priority'), 'writing');
    expect(prefs.getBool('profile_onboarding_complete'), isTrue);
  });

  test('setActiveLevel clamps to valid HSK range', () async {
    final container = await _container();
    final notifier = container.read(userProfileProvider.notifier);

    notifier.setActiveLevel(9);
    expect(container.read(userProfileProvider).activeLevel, 4);

    notifier.setActiveLevel(0);
    expect(container.read(userProfileProvider).activeLevel, 1);
  });

  test('invalid persisted priority falls back to vocabulary', () async {
    final container = await _container(
      prefs: {'profile_priority': 'unknown_value'},
    );
    expect(
      container.read(userProfileProvider).priority,
      LearningPriority.vocabulary,
    );
  });
}
