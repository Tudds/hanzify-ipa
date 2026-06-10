import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hanzify/core/providers/shared_preferences_provider.dart';

export 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

/// Cài SharedPreferences mock với [prefs] và trả về overrides cần thiết cho
/// các provider đọc prefs đồng bộ (userProfileProvider, quizLevelProvider...).
Future<List<Override>> profileTestOverrides({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  return [sharedPreferencesProvider.overrideWithValue(instance)];
}

/// Prefs đánh dấu đã hoàn tất onboarding với level cho trước.
Map<String, Object> onboardedPrefs({int activeLevel = 2}) {
  return {
    'profile_onboarding_complete': true,
    'profile_active_level': activeLevel,
  };
}
